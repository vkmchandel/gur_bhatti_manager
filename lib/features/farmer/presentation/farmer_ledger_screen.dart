import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/phone_launcher.dart';
import '../../../core/widgets/payment_status_chip.dart';
import '../../../data/demo_catalog.dart';

class FarmerLedgerScreen extends StatelessWidget {
  const FarmerLedgerScreen({super.key, required this.farmerId});

  final String farmerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final farmer = DemoCatalog.farmerById(farmerId);

    final l10n = AppLocalizations.of(context)!;

    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.farmerNotFound.toUpperCase())),
        body: Center(child: Text(l10n.farmerNotFoundDesc)),
      );
    }

    final sessionId = DemoCatalog.activeSessionId;
    final rows = DemoCatalog.procurementsForFarmer(farmerId, sessionId: sessionId);
    var totalWt = 0.0;
    var totalAmt = 0.0;
    var totalPaid = 0.0;
    for (final p in rows) {
      totalWt += p.netWeightQtl;
      totalAmt += p.totalAmount;
      totalPaid += p.amountPaid;
    }
    final balance = totalAmt - totalPaid;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(farmer.name.toUpperCase()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/farmers/$farmerId/edit'),
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildProfileHeader(theme, scheme, farmer),
            const SizedBox(height: 24),
            _buildFinancialSummary(theme, scheme, totalWt, totalAmt, totalPaid, balance, l10n),
            const SizedBox(height: 32),
            _buildSectionHeader(theme, scheme, l10n.supplyHistory.toUpperCase(), '${rows.length} ${l10n.entries.toUpperCase()}'),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              _buildEmptyState(theme, scheme, l10n)
            else
              ...rows.map((p) => _ProcurementLogItem(procurement: p)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/procurement/add'),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: Text(l10n.logNewSupply.toUpperCase()),
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

  Color _getAvatarColor(String name, ColorScheme scheme) {
    final colors = [
      scheme.primary,
      scheme.secondary,
      const Color(0xFF0F172A),
    ];
    final index = name.length % colors.length;
    return colors[index];
  }

  Widget _buildProfileHeader(ThemeData theme, ColorScheme scheme, var farmer) {
    final avatarColor = _getAvatarColor(farmer.name, scheme);
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: avatarColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: avatarColor.withValues(alpha: 0.3),
                blurRadius: 12,
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
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(farmer.village, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(farmer.mobile, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.outline)),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => launchDialer(farmer.mobile),
          icon: const Icon(Icons.call_rounded),
          style: IconButton.styleFrom(
            backgroundColor: scheme.primary.withValues(alpha: 0.1),
            foregroundColor: scheme.primary,
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(ThemeData theme, ColorScheme scheme, double wt, double amt, double paid, double bal, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.onSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryStat(label: l10n.totalWeight.toUpperCase(), value: '${wt.toStringAsFixed(1)} Qtl', isLight: true),
              _SummaryStat(label: l10n.totalEarned.toUpperCase(), value: '₹${(amt/1000).toStringAsFixed(1)}k', isLight: true),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.balanceDue.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('₹${bal.toStringAsFixed(0)}', style: TextStyle(color: scheme.secondary, fontSize: 28, fontWeight: FontWeight.w900)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.secondary,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                child: Text(l10n.payNow.toUpperCase()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, ColorScheme scheme, String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, style: BorderStyle.none),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: scheme.outline),
          const SizedBox(height: 16),
          Text(l10n.noSupplies, style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline)),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isLight;
  const _SummaryStat({required this.label, required this.value, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isLight ? Colors.white70 : Colors.black54, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: isLight ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _ProcurementLogItem extends StatelessWidget {
  final dynamic procurement;
  const _ProcurementLogItem({required this.procurement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${procurement.date.day}/${procurement.date.month}/${procurement.date.year}', style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      PaymentStatusChip(status: procurement.paymentStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${procurement.netWeightQtl.toStringAsFixed(2)} Qtl', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  Text('${l10n.rate}: ₹${procurement.ratePerQtl}/Qtl • ${l10n.veh}: ${procurement.vehicleNumber}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${procurement.totalAmount.toStringAsFixed(0)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('${l10n.paid.toUpperCase()}: ₹${procurement.amountPaid.toStringAsFixed(0)}', style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
