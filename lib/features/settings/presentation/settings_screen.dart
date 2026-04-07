import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(l10n.menuHub),
        centerTitle: true,
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader(theme, scheme, l10n.operationalTools),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _HubCard(
                  icon: Icons.calendar_month_rounded,
                  title: l10n.sessions,
                  subtitle: 'Seasons',
                  onTap: () => context.push('/settings/sessions'),
                ),
                _HubCard(
                  icon: Icons.scale_rounded,
                  title: l10n.weighbridge,
                  subtitle: 'Auto-capture',
                  onTap: () => _notAvailable(context),
                ),
                _HubCard(
                  icon: Icons.analytics_outlined,
                  title: l10n.reports,
                  subtitle: 'Excel/PDF',
                  onTap: () => _notAvailable(context),
                ),
                _HubCard(
                  icon: Icons.inventory_2_outlined,
                  title: l10n.inventory,
                  subtitle: 'Stock mgmt',
                  onTap: () => _notAvailable(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(theme, scheme, l10n.systemConfig),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.language_rounded,
              title: l10n.language,
              subtitle: l10n.selectLanguage,
              onTap: () => _showLanguageDialog(context),
            ),
            _SettingTile(
              icon: Icons.cloud_sync_rounded,
              title: l10n.apiSync,
              subtitle: l10n.apiSyncDesc,
              onTap: () => _notAvailable(context),
            ),
            _SettingTile(
              icon: Icons.security_rounded,
              title: l10n.rolesPermissions,
              subtitle: l10n.rolesPermissionsDesc,
              onTap: () => _notAvailable(context),
            ),
            _SettingTile(
              icon: Icons.info_outline_rounded,
              title: l10n.aboutVersion,
              subtitle: 'v1.0.0-PRO • Industrial Edition',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'GurBhattiManager',
                  applicationVersion: '1.0.0-PRO',
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (v) {
                if (v != null) {
                  localeProvider.setLocale(Locale(v));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('हिंदी (Hindi)'),
              value: 'hi',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (v) {
                if (v != null) {
                  localeProvider.setLocale(Locale(v));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _notAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Module scheduled for Q2 update')),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, ColorScheme scheme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        color: scheme.primary.withValues(alpha: 0.7),
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: scheme.primary, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: scheme.outline, size: 20),
      title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
