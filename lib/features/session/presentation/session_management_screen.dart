import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';

import '../domain/models/session_model.dart';

class SessionManagementScreen extends StatefulWidget {
  const SessionManagementScreen({super.key});

  @override
  State<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {
  late List<SessionModel> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = [
      SessionModel(
        id: 's24',
        name: '2024-25 SEASON',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2025, 9, 30),
        isActive: false,
      ),
      SessionModel(
        id: 's25',
        name: '2025-26 SEASON',
        startDate: DateTime(2025, 10, 1),
        endDate: DateTime(2026, 9, 30),
        isActive: true,
      ),
    ];
  }

  Future<void> _confirmSwitch(SessionModel target, AppLocalizations l10n) async {
    if (target.isActive) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.switchSessionTitle),
        content: Text(l10n.switchSessionDesc(target.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel.toUpperCase())),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.activateSession.toUpperCase())),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _sessions = _sessions
          .map(
            (s) => SessionModel(
              id: s.id,
              name: s.name,
              startDate: s.startDate,
              endDate: s.endDate,
              isActive: s.id == target.id,
            ),
          )
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.sessionUpdated(target.name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n.sessionManagement.toUpperCase()),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // Not implemented in demo
        icon: const Icon(Icons.add_business_rounded),
        label: Text(l10n.createNewSeason.toUpperCase()),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInfoCard(theme, scheme, l10n),
            const SizedBox(height: 24),
            Text(
              l10n.historicalActiveSessions.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary.withValues(alpha: 0.7),
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._sessions.map((s) => _SessionCard(
              session: s,
              onActivate: () => _confirmSwitch(s, l10n),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, ColorScheme scheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: scheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.sessionInfo,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onActivate;

  const _SessionCard({required this.session, required this.onActivate});

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
        side: BorderSide(
          color: session.isActive ? scheme.primary : scheme.outlineVariant,
          width: session.isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: session.isActive ? scheme.primary : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    session.isActive ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                    color: session.isActive ? Colors.white : scheme.outline,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      Text(
                        '${session.startDate.year} - ${session.endDate.year}',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ),
                ),
                if (session.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(l10n.active.toUpperCase(), style: TextStyle(color: scheme.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                  )
                else
                  TextButton(
                    onPressed: onActivate,
                    child: Text(l10n.activate.toUpperCase()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
