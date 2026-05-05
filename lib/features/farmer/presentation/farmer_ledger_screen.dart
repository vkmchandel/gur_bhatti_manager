import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../data/demo_catalog.dart';

class FarmerLedgerScreen extends StatefulWidget {
  const FarmerLedgerScreen({super.key, required this.farmerId});

  final String farmerId;

  @override
  State<FarmerLedgerScreen> createState() => _FarmerLedgerScreenState();
}

class _FarmerLedgerScreenState extends State<FarmerLedgerScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final farmer = DemoCatalog.farmerById(widget.farmerId);

    final l10n = AppLocalizations.of(context)!;

    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.farmerNotFound.toUpperCase()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.farmerNotFoundDesc),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.home.toUpperCase()),
              ),
            ],
          ),
        ),
      );
    }

    final sessionId = DemoCatalog.activeSessionId;
    final procurements = DemoCatalog.procurementsForFarmer(widget.farmerId, sessionId: sessionId);
    final payments = DemoCatalog.paymentsForFarmer(widget.farmerId, sessionId: sessionId);

    var totalWt = 0.0;
    var totalAmt = 0.0;
    var totalPaidAtSupply = 0.0;
    for (final p in procurements) {
      totalWt += p.netWeightQtl;
      totalAmt += p.totalAmount;
      totalPaidAtSupply += p.amountPaid;
    }

    double totalManualPaid = 0;
    for (final p in payments) {
      totalManualPaid += p.amount;
    }

    final totalPaid = totalPaidAtSupply + totalManualPaid;
    final balance = totalAmt - totalPaid;

    final sortedProcurements = [...procurements]..sort((a, b) => b.date.compareTo(a.date));

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
        title: Column(
          children: [
            const Text(
              'FARMER PROFILE',
              style: TextStyle(
                color: Color(0xFF365E32),
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              'ACTIVE SESSION: ${DemoCatalog.activeSession()?.name ?? 'N/A'}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/farmers/${widget.farmerId}/payment');
          setState(() {});
        },
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.currency_rupee_rounded, size: 20, color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.only(left: 14, top: 10),
              child: Icon(Icons.add, size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _buildIdentitySection(context, farmer, theme, scheme),
            const SizedBox(height: 24),
            _buildFinancialSummary(totalWt, procurements.length, totalAmt, totalPaid, balance),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  'RECENT DELIVERIES',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Divider(thickness: 1, color: Color(0xFFE2E8F0))),
              ],
            ),
            const SizedBox(height: 12),
            if (sortedProcurements.isEmpty)
              _buildEmptyDeliveryState(theme, scheme)
            else
              ...sortedProcurements.take(3).map((p) => _DeliveryItem(
                    date: p.date,
                    weight: p.netWeightQtl,
                    amount: p.totalAmount,
                    onTap: () => context.push('/procurement/receipt/${p.id}'),
                  )),
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  'PAYMENT HISTORY',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Divider(thickness: 1, color: Color(0xFFE2E8F0))),
              ],
            ),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              _buildEmptyState(theme, scheme)
            else
              ...payments.map((p) => _PaymentHistoryItem(
                    date: p.date,
                    amount: p.amount,
                    onEdit: () async {
                      await context.push('/farmers/${widget.farmerId}/payment', extra: p);
                      setState(() {});
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, p.id);
                    },
                  )),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this payment record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              DemoCatalog.deletePayment(paymentId);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context, var farmer, ThemeData theme, ColorScheme scheme) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF365E32),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF365E32).withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(farmer.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        farmer.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E9D5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'MEMBER SINCE 2023',
                          style: TextStyle(
                            color: Color(0xFF365E32),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/farmers/${widget.farmerId}/edit'),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  visualDensity: VisualDensity.compact,
                  color: scheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildInfoItem(Icons.location_on_outlined, 'LOCATION', farmer.village)),
                Expanded(child: _buildInfoItem(Icons.smartphone_outlined, 'PHONE', farmer.mobile)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoItem(Icons.account_balance_outlined, 'BANK', farmer.bankName)),
                Expanded(
                  child: _buildInfoItem(
                    Icons.credit_card_outlined,
                    'ACCOUNT',
                    farmer.bankAccount ?? 'N/A',
                    isCopyable: farmer.bankAccount != null,
                    ifsc: farmer.ifscCode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {bool isCopyable = false, String? ifsc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isCopyable) ...[
                    const SizedBox(width: 8),
                    _CopyButton(text: value, label: label, isSmall: true),
                  ],
                ],
              ),
              if (ifsc != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'IFSC: $ifsc',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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

  Widget _buildFinancialSummary(double wt, int trolleys, double earned, double paid, double bal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSummaryItem('SESSION WEIGHT (QTL)', wt.toStringAsFixed(1), crossAxisAlignment: CrossAxisAlignment.start),
              const Spacer(),
              _buildSummaryItem('TOTAL TROLLEYS', trolleys.toString(), crossAxisAlignment: CrossAxisAlignment.center),
              const Spacer(),
              _buildSummaryItem('SESSION EARNED (₹)', '₹${(earned / 1000).toStringAsFixed(1)}k', crossAxisAlignment: CrossAxisAlignment.end),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSummaryItem('TOTAL PAID (₹)', '₹${(paid / 1000).toStringAsFixed(1)}k', crossAxisAlignment: CrossAxisAlignment.start),
              const Spacer(),
              _buildSummaryItem('BALANCE DUE (₹)', '₹${bal.toStringAsFixed(0)}',
                crossAxisAlignment: CrossAxisAlignment.end,
                valueColor: const Color(0xFFFFB300),
                valueSize: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    Color valueColor = Colors.white,
    double valueSize = 20,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.payments_outlined, size: 48, color: scheme.outline),
          const SizedBox(height: 16),
          Text("No payments recorded yet.", style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline)),
        ],
      ),
    );
  }

  Widget _buildEmptyDeliveryState(ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text("No deliveries recorded yet.", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
    );
  }
}

class _DeliveryItem extends StatelessWidget {
  final DateTime date;
  final double weight;
  final double amount;
  final VoidCallback onTap;

  const _DeliveryItem({
    required this.date,
    required this.weight,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                Text(
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 24),
                Text(
                  '${weight.toStringAsFixed(2)} Qtl',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
                ),
                const Spacer(),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String text;
  final String label;
  final bool isSmall;

  const _CopyButton({required this.text, required this.label, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label copied to clipboard'), duration: const Duration(seconds: 1)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEFD5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSmall) ...[
              Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.copy_rounded, size: 14, color: Color(0xFFD97706)),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final DateTime date;
  final double amount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PaymentHistoryItem({
    required this.date,
    required this.amount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 24),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                visualDensity: VisualDensity.compact,
                color: scheme.outline,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                color: scheme.error.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
