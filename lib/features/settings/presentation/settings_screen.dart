import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gur_bhatti_manager/features/auth/data/auth_provider.dart';
import 'package:gur_bhatti_manager/features/session/data/session_provider.dart';
import '../../../core/providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final bhatti = authProvider.bhatti;
    
    final activeSession = sessionProvider.activeSession;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if (bhatti != null) ...[
              _buildBhattiProfile(theme, scheme, bhatti, l10n),
              const SizedBox(height: 16),
              FutureBuilder<int>(
                future: sessionProvider.getUniqueFarmerCountForSession(activeSession?.id ?? ''),
                builder: (context, snapshot) {
                  return _buildQuickStats(
                    theme, 
                    scheme, 
                    activeSession?.name ?? '-', 
                    snapshot.data?.toString() ?? '...',
                  );
                }
              ),
              const SizedBox(height: 24),
            ],
            
            _buildSectionHeader('Operational Tools'),
            _buildMenuContainer([
              _MenuTile(
                icon: Icons.calendar_month_rounded,
                title: l10n.sessions,
                onTap: () => context.push('/settings/sessions'),
              ),
              _MenuTile(
                icon: Icons.scale_rounded,
                title: l10n.weighbridge,
                subtitle: 'Auto-capture',
                onTap: () => _notAvailable(context),
              ),
              _MenuTile(
                icon: Icons.analytics_outlined,
                title: l10n.reports,
                onTap: () => _notAvailable(context),
              ),
              _MenuTile(
                icon: Icons.inventory_2_outlined,
                title: l10n.inventory,
                onTap: () => _notAvailable(context),
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('Your Preferences'),
            _buildMenuContainer([
              _MenuTile(
                icon: Icons.language_rounded,
                title: l10n.language,
                trailing: Text(l10n.selectLanguage, style: theme.textTheme.bodySmall),
                onTap: () => _showLanguageDialog(context),
              ),
              _MenuTile(
                icon: Icons.cloud_sync_rounded,
                title: l10n.apiSync,
                onTap: () => _notAvailable(context),
              ),
              _MenuTile(
                icon: Icons.security_rounded,
                title: 'Roles & Permissions',
                onTap: () => _notAvailable(context),
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('Support'),
            _buildMenuContainer([
              _MenuTile(
                icon: Icons.info_outline_rounded,
                title: 'About Version',
                trailing: const Text('v1.0.0-PRO', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'GurBhattiManager',
                    applicationVersion: '1.0.0-PRO',
                  );
                },
              ),
              _MenuTile(
                icon: Icons.logout_rounded,
                title: l10n.logout,
                titleColor: Colors.redAccent,
                showArrow: false,
                onTap: () => _showLogoutDialog(context, l10n),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBhattiProfile(ThemeData theme, ColorScheme scheme, dynamic bhatti, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text(
              bhatti.bhattiName[0].toUpperCase(),
              style: TextStyle(color: scheme.primary, fontSize: 32, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bhatti.ownerName,
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  bhatti.mobileNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Edit profile', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_right, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, ColorScheme scheme, String sessionName, String farmers) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.history_edu_rounded,
            title: 'Active Session',
            value: sessionName,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline,
            title: 'Total Farmers',
            value: farmers,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
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
        content: RadioGroup<String>(
          groupValue: localeProvider.locale.languageCode,
          onChanged: (v) {
            if (v != null) {
              localeProvider.setLocale(Locale(v));
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              RadioListTile<String>(
                title: Text('English'),
                value: 'en',
              ),
              RadioListTile<String>(
                title: Text('हिंदी (Hindi)'),
                value: 'hi',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/signup');
            },
            child: Text(l10n.logout, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _notAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Module scheduled for Q2 update')));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? titleColor;
  final bool showArrow;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.titleColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: titleColor ?? Colors.black87)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          trailing ?? const SizedBox.shrink(),
          if (showArrow) const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}
