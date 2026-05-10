import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../data/auth_provider.dart';
import '../domain/models/bhatti_model.dart';

class BhattiSetupScreen extends StatefulWidget {
  const BhattiSetupScreen({super.key});

  @override
  State<BhattiSetupScreen> createState() => _BhattiSetupScreenState();
}

class _BhattiSetupScreenState extends State<BhattiSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Identity
  final _ownerNameController = TextEditingController();
  final _bhattiNameController = TextEditingController();
  
  // Location
  bool _isAtBhatti = true;
  bool _isLoadingLocation = false;
  bool _isLoadingPincode = false;
  
  final _pincodeController = TextEditingController();
  final _villageController = TextEditingController();
  final _villageFocusNode = FocusNode();
  final _villageScrollController = ScrollController();
  
  String _state = '';
  String _district = '';
  List<String> _villages = [];
  double? _latitude;
  double? _longitude;

  final Color _forestGreen = const Color(0xFF365E32);
  final Color _amberHighlight = Colors.amber;

  @override
  void initState() {
    super.initState();
    _pincodeController.addListener(_onPincodeChanged);
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _bhattiNameController.dispose();
    _pincodeController.dispose();
    _villageController.dispose();
    _villageFocusNode.dispose();
    _villageScrollController.dispose();
    super.dispose();
  }

  void _onPincodeChanged() {
    final pincode = _pincodeController.text;
    if (pincode.length == 6) {
      _fetchPincodeDetails(pincode);
    } else if (pincode.length < 6) {
      if (_state.isNotEmpty || _district.isNotEmpty || _villages.isNotEmpty) {
        setState(() {
          _state = '';
          _district = '';
          _villages = [];
          _villageController.clear();
        });
      }
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled. Please enable them.'))
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.'))
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in settings.'))
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      String detectedPincode = '';
      if (placemarks.isNotEmpty) {
        detectedPincode = placemarks[0].postalCode ?? '';
      }

      // If pincode is not 6 digits (like 94043 on emulator), fallback to 480001 for testing
      if (detectedPincode.length != 6) {
        detectedPincode = '480001';
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _pincodeController.text = detectedPincode;
      });

      // No need to explicitly call _fetchPincodeDetails here
      // because the _pincodeController listener will trigger it.
    } catch (e) {
      debugPrint('Location Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error detecting location: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _fetchPincodeDetails(String pincode) async {
    setState(() => _isLoadingPincode = true);
    try {
      debugPrint('Fetching details for PIN: $pincode');
      final response = await http
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0]['Status'] == 'Success') {
          final List postOffices = data[0]['PostOffice'];
          if (mounted) {
            setState(() {
              _state = postOffices[0]['State'] ?? '';
              _district = postOffices[0]['District'] ?? '';
              _villages = postOffices.map((po) => po['Name'].toString()).toList();

              if (_villages.isEmpty) {
                _villageController.clear();
                _villageFocusNode.requestFocus();
              }
            });
          }
        } else {
          debugPrint('API Error: ${data[0]['Message']}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PIN Code Not Found: ${data[0]['Message'] ?? 'Unknown error'}')),
            );
            setState(() {
              _state = '';
              _district = '';
              _villages = [];
              _villageController.clear();
              _villageFocusNode.requestFocus();
            });
          }
        }
      } else {
        throw 'Server returned status ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Pincode Fetch Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching PIN details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPincode = false);
      }
    }
  }

  bool _isFormValid() {
    return _ownerNameController.text.trim().isNotEmpty &&
        _bhattiNameController.text.trim().isNotEmpty &&
        _villageController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupBhatti),
        backgroundColor: Colors.white,
        foregroundColor: _forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Identity'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ownerNameController,
                label: l10n.ownerName,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bhattiNameController,
                label: l10n.bhattiName,
                icon: Icons.store_outlined,
              ),

              const SizedBox(height: 32),

              _buildSectionTitle('Location Mode'),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Yes, I am here'), icon: Icon(Icons.my_location)),
                  ButtonSegment(value: false, label: Text('No, I am elsewhere'), icon: Icon(Icons.map)),
                ],
                selected: {_isAtBhatti},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isAtBhatti = newSelection.first;
                    if (!_isAtBhatti) {
                      _latitude = 0.0;
                      _longitude = 0.0;
                    }
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: _forestGreen,
                  selectedForegroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              if (_isAtBhatti)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingLocation ? null : _detectLocation,
                    icon: _isLoadingLocation 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.location_searching),
                    label: const Text('📍 Detect Location'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _forestGreen,
                      side: BorderSide(color: _forestGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

              _buildTextField(
                controller: _pincodeController,
                label: 'Pincode',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    if (_isLoadingPincode)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    if (_state.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildReadOnlyField('State', _state, Icons.map_outlined),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('District', _district, Icons.location_city_outlined),
                      
                      if (_villages.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionTitle('Locality/Village/City Discovery'),
                        const SizedBox(height: 8),
                        Theme(
                          data: Theme.of(context).copyWith(
                            scrollbarTheme: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.all(_forestGreen.withValues(alpha: 0.8)),
                              trackColor: WidgetStateProperty.all(Colors.grey[200]),
                              thickness: WidgetStateProperty.all(6),
                              radius: const Radius.circular(10),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Scrollbar(
                              controller: _villageScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              interactive: true,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 160),
                                child: SingleChildScrollView(
                                  controller: _villageScrollController,
                                  padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: _villages.map((village) {
                                      final isSelected = _villageController.text == village;
                                      return ChoiceChip(
                                        label: Text(village),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            _villageController.text = selected ? village : '';
                                          });
                                        },
                                        selectedColor: _amberHighlight.withValues(alpha: 0.3),
                                        checkmarkColor: _forestGreen,
                                        labelStyle: TextStyle(
                                          color: isSelected ? _forestGreen : Colors.black87,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _villageController,
                        focusNode: _villageFocusNode,
                        label: 'Village/City',
                        icon: Icons.location_city_outlined,
                        hint: 'Select from above or type here',
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: _isFormValid() ? _submitSetup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _forestGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  l10n.finishSetup,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 32), // Extra padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  void _submitSetup() {
    final authProvider = context.read<AuthProvider>();
    
    final bhatti = BhattiModel(
      id: const Uuid().v4(),
      ownerName: _ownerNameController.text,
      bhattiName: _bhattiNameController.text,
      mobileNumber: authProvider.tempMobile ?? '',
      pincode: _pincodeController.text,
      state: _state,
      district: _district,
      village: _villageController.text,
      latitude: _latitude,
      longitude: _longitude,
    );

    authProvider.setupBhatti(bhatti);
    context.go('/dashboard');
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: _forestGreen.withValues(alpha: 0.8),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    FocusNode? focusNode,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _forestGreen),
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _forestGreen, width: 2),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: _forestGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
