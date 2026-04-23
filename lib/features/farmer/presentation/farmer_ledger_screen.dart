import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final activeSession = DemoCatalog.sessions.firstWhere((s) => s.id == sessionId);
    final rows = DemoCatalog.procurementsForFarmer(farmerId, sessionId: sessionId);
    // Sort by date descending and take last 5
    final recentRows = [...rows]..sort((a, b) => b.date.compareTo(a.date));
    final displayRows = recentRows.take(5).toList();

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
        title: Column(
          children: [
            Text(farmer.name.toUpperCase()),
            Text(
              '${l10n.activeSession}: ${activeSession.name}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
            _buildIdentityCard(context, theme, scheme, farmer, l10n),
            const SizedBox(height: 16),
            _buildFinancialSummary(theme, scheme, totalWt, totalAmt, totalPaid, balance, l10n),
            const SizedBox(height: 32),
            _buildSectionHeader(
              theme,
              scheme,
              l10n.recentSupply.toUpperCase(),
              l10n.seeAll.toUpperCase(),
              onSeeAll: () => context.go('/log?farmerId=$farmerId&sessionId=$sessionId'),
            ),
            const SizedBox(height: 12),
            if (displayRows.isEmpty)
              _buildEmptyState(theme, scheme, l10n)
            else
              ...displayRows.map((p) => _ProcurementLogItem(procurement: p)),
            const SizedBox(height: 32),
          ],
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

  Color _getAvatarColor(String name, ColorScheme scheme) {
    final colors = [
      scheme.primary,
      scheme.secondary,
      const Color(0xFF0F172A),
    ];
    final index = name.length % colors.length;
    return colors[index];
  }

  Widget _buildIdentityCard(BuildContext context, ThemeData theme, ColorScheme scheme, var farmer, AppLocalizations l10n) {
    final avatarColor = _getAvatarColor(farmer.name, scheme);
    final hasBankInfo = farmer.bankAccount != null && farmer.bankAccount!.isNotEmpty;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: avatarColor,
                  child: Text(
                    _getInitials(farmer.name),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer.name,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '#F-${farmer.id.length > 4 ? farmer.id.substring(0, 4).toUpperCase() : farmer.id.toUpperCase()} • Member since 2024',
                        style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => launchDialer(farmer.mobile),
                  icon: const Icon(Icons.phone_outlined), // Changed to outlined to match ListCard
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.primary.withValues(alpha: 0.05),
                    foregroundColor: scheme.primary,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 0.5), // Thinner divider
            ),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 32, // More compact
                crossAxisSpacing: 16,
              ),
              children: [
                _buildInfoTile(Icons.location_on_outlined, farmer.village, scheme),
                _buildInfoTile(Icons.smartphone_rounded, farmer.mobile, scheme),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.03), // Subtler green tint
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_outlined, size: 14, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.bankingInfo.split('(')[0].trim(),
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: scheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (hasBankInfo) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(farmer.bankName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        _CopyButton(text: farmer.bankAccount!, label: 'A/C'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('IFSC: ', style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline)),
                        Text(farmer.ifscCode ?? 'N/A', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        if (farmer.ifscCode != null) _CopyButton(text: farmer.ifscCode!, label: 'IFSC', isSmall: true),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: scheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No bank details registered.',
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/farmers/${farmer.id}/edit'),
                          child: const Text('ADD'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String value, ColorScheme scheme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
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
              _SummaryStat(label: '${l10n.sessionWeight.toUpperCase()}', value: '${wt.toStringAsFixed(1)} Qtl', isLight: true),
              _SummaryStat(label: '${l10n.sessionEarned.toUpperCase()}', value: '₹${(amt / 1000).toStringAsFixed(1)}k', isLight: true),
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
                  Text(l10n.sessionBalance.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildSectionHeader(ThemeData theme, ColorScheme scheme, String title, String actionLabel, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: scheme.secondary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          child: Text(actionLabel),
        ),
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

class _CopyButton extends StatelessWidget {
  final String text;
  final String label;
  final bool isSmall;

  const _CopyButton({required this.text, required this.label, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label copied to clipboard'), duration: const Duration(seconds: 1)),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: isSmall ? 2 : 4),
        decoration: BoxDecoration(
          color: scheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSmall) ...[
              Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scheme.secondary)),
              const SizedBox(width: 6),
            ],
            Icon(Icons.copy_rounded, size: isSmall ? 10 : 12, color: scheme.secondary),
          ],
        ),
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
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                      Text(
                        '${procurement.date.day}/${procurement.date.month}/${procurement.date.year}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PaymentStatusChip(status: procurement.paymentStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${procurement.netWeightQtl.toStringAsFixed(2)} Qtl',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${l10n.rate}: ₹${procurement.ratePerQtl}/Qtl • ${l10n.veh}: ${procurement.vehicleNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${procurement.totalAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${l10n.paid.toUpperCase()}: ₹${procurement.amountPaid.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
