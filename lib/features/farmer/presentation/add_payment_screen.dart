import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/demo_catalog.dart';
import '../../../data/payment_model.dart';
import '../../../features/farmer/domain/farmer.dart';
import '../../../l10n/generated/app_localizations.dart';

class AddPaymentScreen extends StatefulWidget {
  final String farmerId;

  const AddPaymentScreen({super.key, required this.farmerId});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  PaymentModel? _editingPayment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is PaymentModel) {
        setState(() {
          _editingPayment = extra;
          _amountController.text = extra.amount.toStringAsFixed(0);
          _noteController.text = extra.note ?? '';
          _selectedDate = extra.date;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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

    setState(() => _isSaving = true);
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    final payment = PaymentModel(
      id: _editingPayment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: widget.farmerId,
      sessionId: DemoCatalog.activeSessionId,
      date: _selectedDate,
      amount: amount,
      note: _noteController.text,
    );

    // Simulating save logic
    await Future.delayed(const Duration(milliseconds: 500));
    if (_editingPayment != null) {
      DemoCatalog.manualPayments.removeWhere((p) => p.id == _editingPayment!.id);
    }
    DemoCatalog.addPayment(payment);
    
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingPayment != null ? 'Payment updated successfully' : 'Payment recorded successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final farmer = DemoCatalog.farmerById(widget.farmerId);

    if (farmer == null) return const Scaffold(body: Center(child: Text('Farmer not found')));

    // Dynamic balance calculation
    final procurements = DemoCatalog.procurementsForFarmer(widget.farmerId);
    final payments = DemoCatalog.paymentsForFarmer(widget.farmerId);
    
    double totalDue = procurements.fold(0.0, (sum, p) => sum + p.totalAmount);
    double totalPaid = procurements.fold(0.0, (sum, p) => sum + p.amountPaid) + 
                       payments.fold(0.0, (sum, p) => sum + p.amount);
    
    double currentBalance = totalDue - totalPaid;
    if (_editingPayment != null) {
      currentBalance += _editingPayment!.amount;
    }

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
          _editingPayment != null ? 'EDIT PAYMENT' : 'RECORD PAYMENT',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildSectionLabel('FARMER'),
            const SizedBox(height: 12),
            _buildFarmerMiniCard(farmer, theme),
            const SizedBox(height: 32),
            _buildSummaryCard(currentBalance),
            const SizedBox(height: 32),
            _buildSectionLabel('PAYMENT DETAILS'),
            const SizedBox(height: 12),
            _buildAmountField(currentBalance),
            const SizedBox(height: 16),
            _buildDateField(context),
            const SizedBox(height: 16),
            _buildNoteField(),
            const SizedBox(height: 40),
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
                        _editingPayment != null ? 'UPDATE PAYMENT' : 'CONFIRM PAYMENT',
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFarmerMiniCard(Farmer farmer, ThemeData theme) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF365E32),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                _getInitials(farmer.name),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmer.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                ),
                Text(
                  farmer.village.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PENDING BALANCE',
                style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.2),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${balance.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const Icon(Icons.account_balance_wallet_outlined, color: Colors.white24, size: 40),
        ],
      ),
    );
  }

  Widget _buildAmountField(double maxBalance) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(
            labelText: 'PAYMENT AMOUNT',
            labelStyle: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
            prefixText: '₹ ',
            prefixStyle: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            final amount = double.tryParse(v) ?? 0;
            if (amount <= 0) return 'Enter a valid amount';
            if (amount > maxBalance) return 'Amount exceeds pending balance (₹${maxBalance.toStringAsFixed(0)})';
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
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
              const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF64748B)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT DATE',
                    style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMMM, yyyy').format(_selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextFormField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'NOTES (OPTIONAL)',
            labelStyle: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8),
            hintText: 'e.g. Cash payment, Bank transfer',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
