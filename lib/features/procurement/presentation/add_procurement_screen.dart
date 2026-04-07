import 'dart:io';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/demo_catalog.dart';
import '../../../features/farmer/domain/farmer.dart';

class AddProcurementScreen extends StatefulWidget {
  const AddProcurementScreen({super.key});

  @override
  State<AddProcurementScreen> createState() => _AddProcurementScreenState();
}

class _AddProcurementScreenState extends State<AddProcurementScreen> {
  final _formKey = GlobalKey<FormState>();

  Farmer? _selectedFarmer;
  final _grossController = TextEditingController();
  final _tareController = TextEditingController();
  final _trashController = TextEditingController(text: '0');
  final _rateController = TextEditingController(text: '320');
  final _vehicleController = TextEditingController();

  XFile? _photo;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (DemoCatalog.farmers.isNotEmpty) {
      _selectedFarmer = DemoCatalog.farmers.first;
    }
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
      if (file != null) setState(() => _photo = file);
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _useDemoPhoto() => setState(() => _photo = XFile('demo'));

  void _onSave(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.capturePhotoError), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulating save
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.procurementSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordIntake.toUpperCase()),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionLabel(theme, l10n.farmerVehicle),
            const SizedBox(height: 12),
            _buildFarmerCard(theme, scheme, l10n),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vehicleController,
              decoration: InputDecoration(
                labelText: l10n.vehicleNumber,
                prefixIcon: const Icon(Icons.local_shipping_outlined),
                hintText: l10n.vehicleHint,
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
            ),

            const SizedBox(height: 32),
            _buildSectionLabel(theme, l10n.weightMeasurements),
            const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            _buildWeightField(
              controller: _trashController,
              label: l10n.trashDeduction,
              icon: Icons.delete_outline,
              l10n: l10n,
            ),

            const SizedBox(height: 32),
            _buildSummaryCard(theme, scheme, l10n),

            const SizedBox(height: 32),
            _buildSectionLabel(theme, l10n.securityCapture),
            const SizedBox(height: 12),
            _buildPhotoPicker(theme, scheme, l10n),

            const SizedBox(height: 40),
            FilledButton(
              onPressed: _isSaving ? null : () => _onSave(l10n),
              child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(l10n.confirmSaveEntry.toUpperCase()),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary.withValues(alpha: 0.7),
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFarmerCard(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return SearchAnchor(
      builder: (context, controller) {
        return InkWell(
          onTap: () => controller.openView(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person_outline, color: scheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedFarmer?.name ?? l10n.selectFarmer, style: theme.textTheme.titleMedium),
                      if (_selectedFarmer != null)
                        Text(_selectedFarmer!.village, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: scheme.primary),
              ],
            ),
          ),
        );
      },
      suggestionsBuilder: (context, controller) {
        final query = controller.text.toLowerCase();
        return DemoCatalog.farmers
          .where((f) => f.name.toLowerCase().contains(query) || f.village.toLowerCase().contains(query))
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixText: 'Qtl',
      ),
      onChanged: (_) => setState(() {}),
      validator: (v) {
        if (label == l10n.gross && _parse(v ?? '') <= 0) return l10n.required;
        return null;
      },
    );
  }

  Widget _buildSummaryCard(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    final net = _netWeight;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.netWeight.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
              Text('${net.toStringAsFixed(2)} Qtl', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rateController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: l10n.ratePerQtl,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixText: '₹ ',
                    prefixStyle: const TextStyle(color: Colors.white),
                    filled: false,
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.totalPayout.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('₹${_totalAmount.toStringAsFixed(0)}', style: TextStyle(color: scheme.secondary, fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return InkWell(
      onTap: _capturePhoto,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: _photo == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 40, color: scheme.primary),
                const SizedBox(height: 8),
                Text(l10n.captureVehicleImage, style: theme.textTheme.titleSmall),
                Text(l10n.weightVerificationRequired, style: theme.textTheme.bodySmall),
                if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)
                  TextButton(onPressed: _useDemoPhoto, child: const Text('Simulate Photo')),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _photo!.path == 'demo'
                    ? Container(color: scheme.primary.withValues(alpha: 0.1), child: Icon(Icons.local_shipping, size: 64, color: scheme.primary))
                    : Image.file(File(_photo!.path), fit: BoxFit.cover),
                ),
                Positioned(
                  right: 8, top: 8,
                  child: IconButton.filled(
                    onPressed: () => setState(() => _photo = null),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
