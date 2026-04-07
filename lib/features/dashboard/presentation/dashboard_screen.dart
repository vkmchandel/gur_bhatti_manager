import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../data/demo_catalog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final session = DemoCatalog.activeSession();
    final sid = session?.id ?? DemoCatalog.activeSessionId;

    final netWeight = DemoCatalog.totalNetWeightQtlForSession(sid);
    final farmerCount = DemoCatalog.uniqueFarmerCountForSession(sid);
    final fin = DemoCatalog.financialTotalsForSession(sid);
    final totalDue = fin.$1 - fin.$2;

    final recentProcurements = DemoCatalog.recentProcurements(n: 3);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18, letterSpacing: 1)),
            if (session != null)
              Text(
                '${l10n.season} ${session.name.toUpperCase()}',
                style: theme.textTheme.labelSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings/sessions'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildMainStats(theme, scheme, netWeight, totalDue, l10n),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, l10n.liveOperations, () => context.go('/procurement'), l10n),
            const SizedBox(height: 12),
            _KpiRow(farmerCount: farmerCount, paidAmount: fin.$2, scheme: scheme, l10n: l10n),
            const SizedBox(height: 28),
            _buildSectionHeader(theme, l10n.recentIntake, () => context.go('/procurement'), l10n),
            const SizedBox(height: 12),
            ...recentProcurements.map((p) => _ProcurementCard(procurement: p)),
            const SizedBox(height: 32),
            _buildActionCard(context, theme, scheme, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats(ThemeData theme, ColorScheme scheme, double weight, double due, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.totalWeight, style: theme.textTheme.labelLarge?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
              const Icon(Icons.analytics_outlined, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${weight.toStringAsFixed(1)} Qtl',
            style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontSize: 36),
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            children: [
              _MiniStat(label: l10n.outstanding, value: '₹${(due/1000).toStringAsFixed(1)}K', color: scheme.secondary),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, VoidCallback onSeeAll, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        TextButton(
          onPressed: onSeeAll,
          child: Text(l10n.seeAll),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return InkWell(
      onTap: () => context.push('/procurement/add'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.newProcurement, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                  Text(l10n.tapToRecord, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final int farmerCount;
  final double paidAmount;
  final ColorScheme scheme;
  final AppLocalizations l10n;

  const _KpiRow({required this.farmerCount, required this.paidAmount, required this.scheme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiBox(
            label: l10n.farmers,
            value: farmerCount.toString(),
            icon: Icons.people_alt_outlined,
            scheme: scheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiBox(
            label: l10n.totalPaid,
            value: '₹${(paidAmount/1000).toStringAsFixed(1)}K',
            icon: Icons.payments_outlined,
            scheme: scheme,
          ),
        ),
      ],
    );
  }
}

class _KpiBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme scheme;

  const _KpiBox({required this.label, required this.value, required this.icon, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ProcurementCard extends StatelessWidget {
  final dynamic procurement;
  const _ProcurementCard({required this.procurement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farmer = DemoCatalog.farmerById(procurement.farmerId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(farmer?.name[0] ?? 'F', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(farmer?.name ?? 'Unknown', style: theme.textTheme.titleMedium),
                Text('${procurement.vehicleNumber} • ${procurement.netWeightQtl} Qtl', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${procurement.totalAmount.round()}', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
              Text('Pending', style: theme.textTheme.labelSmall?.copyWith(color: Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
