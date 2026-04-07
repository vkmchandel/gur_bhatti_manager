import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../data/demo_catalog.dart';

class RegisterFarmerScreen extends StatefulWidget {
  const RegisterFarmerScreen({super.key, this.farmerId});

  final String? farmerId;

  @override
  State<RegisterFarmerScreen> createState() => _RegisterFarmerScreenState();
}

class _RegisterFarmerScreenState extends State<RegisterFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _village;
  late final TextEditingController _mobile;
  late final TextEditingController _bank;
  late final TextEditingController _account;
  late final TextEditingController _ifsc;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.farmerId != null ? DemoCatalog.farmerById(widget.farmerId!) : null;
    _name = TextEditingController(text: existing?.name ?? '');
    _village = TextEditingController(text: existing?.village ?? '');
    _mobile = TextEditingController(text: existing?.mobile ?? '');
    _bank = TextEditingController(text: existing?.bankName ?? '');
    _account = TextEditingController(text: existing?.bankAccount ?? '');
    _ifsc = TextEditingController(text: existing?.ifscCode ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _village.dispose();
    _mobile.dispose();
    _bank.dispose();
    _account.dispose();
    _ifsc.dispose();
    super.dispose();
  }

  void _onSave(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.farmerId != null ? l10n.farmerUpdated : l10n.farmerRegistered)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.farmerId != null;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(isEdit ? l10n.editFarmer.toUpperCase() : l10n.registerFarmer.toUpperCase()),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionLabel(theme, l10n.personalDetails),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobile,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                decoration: InputDecoration(
                  labelText: l10n.mobileNumber,
                  prefixIcon: const Icon(Icons.phone_iphone_outlined),
                  prefixText: '+91 ',
                ),
                validator: (v) => (v == null || v.trim().length != 10) ? l10n.mobileRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _village,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.village,
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              _buildVillageChips(theme, scheme),

              const SizedBox(height: 32),
              _buildSectionLabel(theme, l10n.bankingInfo),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bank,
                decoration: InputDecoration(
                  labelText: l10n.bankName,
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _account,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.accountNumber,
                  prefixIcon: const Icon(Icons.numbers_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ifsc,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.ifscCode,
                  prefixIcon: const Icon(Icons.password_outlined),
                ),
              ),

              const SizedBox(height: 40),
              FilledButton(
                onPressed: _isSaving ? null : () => _onSave(l10n),
                child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEdit ? l10n.saveChanges : l10n.completeRegistration),
              ),
              const SizedBox(height: 40),
            ],
          ),
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
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVillageChips(ThemeData theme, ColorScheme scheme) {
    final villages = DemoCatalog.knownVillages();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: villages.map((v) => ChoiceChip(
        label: Text(v),
        selected: _village.text == v,
        onSelected: (selected) {
          if (selected) setState(() => _village.text = v);
        },
        labelStyle: TextStyle(
          color: _village.text == v ? Colors.white : scheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        selectedColor: scheme.primary,
        backgroundColor: scheme.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
        showCheckmark: false,
      )).toList(),
    );
  }
}
