import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/payment_status_chip.dart';
import '../../../data/demo_catalog.dart';
import '../../../data/procurement_model.dart';

class ProcurementLogScreen extends StatefulWidget {
  const ProcurementLogScreen({super.key});

  @override
  State<ProcurementLogScreen> createState() => _ProcurementLogScreenState();
}

class _ProcurementLogScreenState extends State<ProcurementLogScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final allProcurements = DemoCatalog.procurementsForSession(DemoCatalog.activeSessionId);
    final filteredList = allProcurements.where((p) {
      final farmer = DemoCatalog.farmerById(p.farmerId);
      final nameMatch = farmer?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final vehicleMatch = p.vehicleNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || vehicleMatch;
    }).toList();

    final totalWeight = filteredList.fold(0.0, (sum, p) => sum + p.netWeightQtl);
    final totalAmount = filteredList.fold(0.0, (sum, p) => sum + p.totalAmount);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n.procurementLog.toUpperCase()),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildQuickStats(theme, scheme, totalWeight, totalAmount, l10n),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: l10n.searchFarmerVehicle,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    fillColor: scheme.onPrimary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/procurement/add'),
        icon: const Icon(Icons.add_task_rounded),
        label: Text(l10n.newEntry.toUpperCase()),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ProcurementCard(procurement: filteredList[index]),
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, ColorScheme scheme, double weight, double amount, AppLocalizations l10n) {
    return Row(
      children: [
        _StatItem(label: l10n.totalWeight.toUpperCase(), value: '${weight.toStringAsFixed(1)} Qtl'),
        const SizedBox(width: 16),
        _StatItem(label: l10n.totalValue.toUpperCase(), value: '₹${(amount / 1000).toStringAsFixed(1)}k'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
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
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final farmer = DemoCatalog.farmerById(procurement.farmerId);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () {
          if (farmer != null) context.push('/farmers/${farmer.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: scheme.primary.withValues(alpha: 0.05),
                    child: Icon(Icons.person_outline, color: scheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer?.name ?? l10n.unknownFarmer,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${procurement.vehicleNumber} • ${procurement.date.day}/${procurement.date.month}',
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
                        ),
                      ],
                    ),
                  ),
                  PaymentStatusChip(status: procurement.paymentStatus),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.netWeight.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline, fontWeight: FontWeight.bold)),
                      Text('${procurement.netWeightQtl.toStringAsFixed(2)} Qtl', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.totalAmount.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline, fontWeight: FontWeight.bold)),
                      Text('₹${procurement.totalAmount.toStringAsFixed(0)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
