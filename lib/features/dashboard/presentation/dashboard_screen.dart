import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gur_bhatti_manager/features/auth/data/auth_provider.dart';
import 'package:gur_bhatti_manager/features/procurement/data/procurement_provider.dart';
import 'package:gur_bhatti_manager/features/session/data/session_provider.dart';
import 'package:gur_bhatti_manager/features/farmer/data/farmer_provider.dart';

import '../../procurement/domain/models/procurement_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final bhatti = authProvider.bhatti;
    
    return Consumer3<ProcurementProvider, SessionProvider, FarmerProvider>(
      builder: (context, procurementProvider, sessionProvider, farmerProvider, child) {
        final session = sessionProvider.activeSession;
        final sid = session?.id ?? sessionProvider.activeSessionId;

        return FutureBuilder(
          future: Future.wait([
            procurementProvider.getTotalNetWeightForSession(sid),
            procurementProvider.getFinancialTotalsForSession(sid),
            procurementProvider.getRecentProcurements(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final netWeight = snapshot.data![0] as double;
            final fin = snapshot.data![1] as (double, double);
            final recentProcurementsAll = snapshot.data![2] as List<ProcurementModel>;
            
            final totalDue = fin.$1 - fin.$2;
            final recentProcurements = recentProcurementsAll.take(3).toList();
            final farmerCount = recentProcurements.map((p) => p.farmerId).toSet().length;

            return Scaffold(
              backgroundColor: scheme.surface,
              appBar: AppBar(
                leadingWidth: 56,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Image.asset(
                    'assets/images/bhatti_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bhatti?.bhattiName ?? l10n.appTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    _buildSessionChip(context, theme, scheme, session, sessionProvider),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: InkWell(
                      onTap: () => context.push('/settings'),
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: scheme.secondary,
                        child: Text(
                          (bhatti?.ownerName.isNotEmpty == true) ? bhatti!.ownerName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
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
          },
        );
      },
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
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
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

  Widget _buildSessionChip(BuildContext context, ThemeData theme, ColorScheme scheme, dynamic session, SessionProvider sessionProvider) {
    return InkWell(
      onTap: () => _showSessionPicker(context, sessionProvider),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            session?.name ?? 'Select Session',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(Icons.arrow_drop_down, size: 16, color: scheme.primary.withValues(alpha: 0.8)),
        ],
      ),
    );
  }

  void _showSessionPicker(BuildContext context, SessionProvider sessionProvider) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FutureBuilder(
          future: sessionProvider.sessions,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            }
            final sessions = snapshot.data!;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Switch Season', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sessions.map((s) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: s.isActive ? scheme.primary.withValues(alpha: 0.1) : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_edu_rounded, 
                          color: s.isActive ? scheme.primary : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        s.name, 
                        style: TextStyle(
                          fontWeight: s.isActive ? FontWeight.bold : FontWeight.normal,
                          color: s.isActive ? scheme.primary : Colors.black87,
                        ),
                      ),
                      subtitle: Text('Season: ${s.startDate.year}-${s.endDate.year}'),
                      trailing: s.isActive 
                          ? Icon(Icons.check_circle_rounded, color: scheme.primary) 
                          : null,
                      onTap: () {
                        // In a real app, this would call sessionProvider.setActiveSession(s.id)
                        Navigator.pop(context);
                      },
                    )),
                    const Divider(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/settings/sessions');
                        },
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Manage All Seasons'),
                        style: TextButton.styleFrom(foregroundColor: scheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
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
  final ProcurementModel procurement;
  const _ProcurementCard({required this.procurement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farmerProvider = context.read<FarmerProvider>();
    final farmer = farmerProvider.getFarmerById(procurement.farmerId);

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
                Text(farmer?.name ?? 'Unknown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${procurement.vehicleNumber} • '),
                      TextSpan(
                        text: '${procurement.netWeightQtl} Qtl',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                  style: theme.textTheme.bodySmall,
                ),
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
