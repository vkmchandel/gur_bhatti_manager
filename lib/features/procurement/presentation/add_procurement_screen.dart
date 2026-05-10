import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/domain/payment_status.dart';
import '../domain/models/procurement_model.dart';
import '../../../features/farmer/domain/models/farmer_model.dart';
import '../../../features/farmer/data/farmer_provider.dart';
import '../../../features/procurement/data/procurement_provider.dart';
import '../../../features/session/data/session_provider.dart';

class AddProcurementScreen extends StatefulWidget {
  final String? editProcurementId;

  const AddProcurementScreen({
    super.key,
    this.editProcurementId,
  });

  @override
  State<AddProcurementScreen> createState() => _AddProcurementScreenState();
}

class _AddProcurementScreenState extends State<AddProcurementScreen> {
  final _formKey = GlobalKey<FormState>();

  FarmerModel? _selectedFarmer;
  final _grossController = TextEditingController();
  final _tareController = TextEditingController();
  final _trashController = TextEditingController(text: '0');
  final _rateController = TextEditingController(text: '320');
  final _vehicleController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final List<XFile> _photos = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _grossController.addListener(_updateCalculations);
    _tareController.addListener(_updateCalculations);
    _rateController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.editProcurementId != null) {
        final procurementProvider = Provider.of<ProcurementProvider>(context, listen: false);
        final farmerProvider = Provider.of<FarmerProvider>(context, listen: false);

        final p = await procurementProvider.getProcurementById(widget.editProcurementId!);
        if (p != null) {
          setState(() {
            _selectedFarmer = farmerProvider.getFarmerById(p.farmerId);
            _grossController.text = p.grossWeightQtl.toString();
            _tareController.text = p.tareWeightQtl.toString();
            _trashController.text = p.trashDeductionQtl.toString();
            _rateController.text = p.ratePerQtl.toString();
            _vehicleController.text = p.vehicleNumber;
            _selectedDate = p.date;
            if (p.hasVehiclePhoto) {
              _photos.add(XFile('demo')); // Placeholder for existing photo
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _grossController.dispose();
    _tareController.dispose();
    _trashController.dispose();
    _rateController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    if (!mounted) return;
    final g = _parse(_grossController.text);
    final t = _parse(_tareController.text);
    
    String newTrashValue = '0.00';
    if (g > t) {
      // Logic: 1% of (Gross - Tare), rounded down (floor) to 2 decimal places
      final trash = ((g - t) * 0.01 * 100).floorToDouble() / 100;
      newTrashValue = trash.toStringAsFixed(2);
    }
    
    // Only update if value changed to avoid cursor reset issues if it were editable
    if (_trashController.text != newTrashValue) {
      _trashController.text = newTrashValue;
    }
    
    setState(() {});
  }

  double _parse(String v) => double.tryParse(v.trim()) ?? 0.0;

  double get _netWeight {
    final g = _parse(_grossController.text);
    final t = _parse(_tareController.text);
    final r = _parse(_trashController.text);
    return (g - t - r).clamp(0, double.infinity);
  }

  double get _totalAmount {
    final net = _netWeight;
    final rate = _parse(_rateController.text);
    return net * rate;
  }

  Future<void> _capturePhoto() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) setState(() => _photos.add(file));
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onSave(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFarmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectFarmer), backgroundColor: Colors.red),
      );
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.capturePhotoError), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    final procurementProvider = context.read<ProcurementProvider>();
    final sessionProvider = context.read<SessionProvider>();

    final procurement = ProcurementModel(
      id: widget.editProcurementId ?? const Uuid().v4(),
      sessionId: sessionProvider.activeSessionId,
      farmerId: _selectedFarmer!.id,
      date: _selectedDate,
      vehicleNumber: _vehicleController.text.trim().toUpperCase(),
      grossWeightQtl: _parse(_grossController.text),
      tareWeightQtl: _parse(_tareController.text),
      trashDeductionQtl: _parse(_trashController.text),
      netWeightQtl: _netWeight,
      ratePerQtl: _parse(_rateController.text),
      totalAmount: _totalAmount,
      amountPaid: 0,
      paymentStatus: PaymentStatus.pending,
      hasVehiclePhoto: true,
    );

    if (widget.editProcurementId != null) {
      await procurementProvider.updateProcurement(procurement);
    } else {
      await procurementProvider.addProcurement(procurement);
    }

    await Future.delayed(const Duration(milliseconds: 500)); 
    if (mounted) {
      if (widget.editProcurementId != null) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Entry updated successfully")),
        );
      } else {
        context.replace('/procurement/receipt/${procurement.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.procurementSaved)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B3D2F)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          (widget.editProcurementId != null ? "Edit Entry" : l10n.recordIntake).toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF365E32),
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildSectionLabel(l10n.farmerVehicle),
            const SizedBox(height: 8),
            _buildDatePickerCard(theme, l10n),
            const SizedBox(height: 8),
            _buildFarmerCard(theme, scheme, l10n),
            const SizedBox(height: 8),
            Card(
              elevation: 0.5,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: _vehicleController,
                  decoration: InputDecoration(
                    labelText: l10n.vehicleNumber.toUpperCase(),
                    labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
                    prefixIcon: const Icon(Icons.local_shipping_outlined, color: Color(0xFF64748B), size: 20),
                    hintText: l10n.vehicleHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionLabel(l10n.weightMeasurements),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildWeightField(
                    controller: _grossController,
                    label: l10n.gross,
                    icon: Icons.scale,
                    l10n: l10n,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWeightField(
                    controller: _tareController,
                    label: l10n.tare,
                    icon: Icons.no_sim_outlined,
                    l10n: l10n,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildWeightField(
              controller: _trashController,
              label: l10n.trashDeduction,
              icon: Icons.delete_outline,
              l10n: l10n,
              isReadOnly: true,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Color(0xFF1B5E20)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Auto-calculated at 1% of total weight (Gross - Tare).",
                      style: TextStyle(color: Color(0xFF1B5E20), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSummaryCard(theme, scheme, l10n),

            const SizedBox(height: 24),
            _buildSectionLabel(l10n.securityCapture),
            const SizedBox(height: 8),
            _buildMultiPhotoPicker(theme, scheme, l10n),

            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : () => _onSave(l10n),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isSaving
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(
                      (widget.editProcurementId != null ? "Update Entry" : l10n.confirmSaveEntry).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),

      ),
    );
  }

  Widget _buildDatePickerCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "INTAKE DATE",
                    style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFarmerCard(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return SearchAnchor(
      builder: (context, controller) {
        return Card(
          elevation: 0.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => controller.openView(),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF365E32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.person_outline, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFarmer?.name ?? l10n.selectFarmer,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                        ),
                        if (_selectedFarmer != null)
                          Text(
                            _selectedFarmer!.village.toUpperCase(),
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        );
      },
      suggestionsBuilder: (context, controller) {
        final query = controller.text;
        final farmerProvider = context.read<FarmerProvider>();
        return farmerProvider.searchFarmers(query)
          .map((f) => ListTile(
            title: Text(f.name),
            subtitle: Text(f.village),
            onTap: () {
              setState(() => _selectedFarmer = f);
              controller.closeView(f.name);
            },
          ));
      },
    );
  }

  Widget _buildWeightField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppLocalizations l10n,
    bool isReadOnly = false,
    String? helperText,
    ValueChanged<String>? onChanged,
  }) {
    return Card(
      elevation: 0.5,
      color: isReadOnly ? const Color(0xFFF8FAFC) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              decoration: InputDecoration(
                labelText: label.toUpperCase(),
                labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
                prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
                suffixText: 'Qtl',
                suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (val) {
                if (onChanged != null) onChanged(val);
                setState(() {});
              },
              validator: (v) {
                if (label == l10n.gross && _parse(v ?? '') <= 0) return l10n.required;
                return null;
              },
            ),
            if (helperText != null)
              Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 8),
                child: Text(
                  helperText,
                  style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    final net = _netWeight;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.netWeight.toUpperCase(),
                    style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${net.toStringAsFixed(2)} Qtl',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const Icon(Icons.analytics_outlined, color: Colors.white24, size: 32),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white10, height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ratePerQtl.toUpperCase(),
                      style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    IntrinsicWidth(
                      child: TextFormField(
                        controller: _rateController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.totalPayout.toUpperCase(),
                    style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFFFB300), fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiPhotoPicker(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + 1,
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                return _buildAddPhotoButton(l10n);
              }
              final photo = _photos[index];
              return _buildPhotoThumbnail(photo, index);
            },
          ),
        ),
        if (_photos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              l10n.weightVerificationRequired,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _buildAddPhotoButton(AppLocalizations l10n) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _capturePhoto,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined, color: Color(0xFF365E32)),
              const SizedBox(height: 4),
              const Text("ADD PHOTO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF365E32))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(XFile photo, int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: photo.path == 'demo'
                ? Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.local_shipping, color: Color(0xFF365E32)),
                  )
                : Image.file(File(photo.path), fit: BoxFit.cover),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              onTap: () => setState(() => _photos.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
