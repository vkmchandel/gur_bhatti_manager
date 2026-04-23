import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../data/demo_catalog.dart';
import 'widgets/farmer_list_card.dart';

class FarmerScreen extends StatefulWidget {
  const FarmerScreen({super.key});

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final farmers = DemoCatalog.farmers.where((f) {
      if (_query.isEmpty) return true;
      return f.name.toLowerCase().contains(_query) || f.village.toLowerCase().contains(_query);
    }).toList();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n.farmerDirectory.toUpperCase()),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                fillColor: scheme.onPrimary.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/farmers/register'),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l10n.registerFarmer.toUpperCase()),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.registeredFarmers.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary.withValues(alpha: 0.7),
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${farmers.length} ${l10n.total.toUpperCase()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...farmers.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FarmerListCard(
                  farmer: f,
                  onOpenDetail: () => context.push('/farmers/${f.id}'),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
