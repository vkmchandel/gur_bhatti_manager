import 'package:flutter/material.dart';

import '../../../../core/utils/phone_launcher.dart';
import '../../domain/farmer.dart';

class FarmerListCard extends StatelessWidget {
  const FarmerListCard({
    super.key,
    required this.farmer,
    this.onOpenDetail,
  });

  final Farmer farmer;
  final VoidCallback? onOpenDetail;

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
      const Color(0xFF0F172A), // Slate 900
    ];
    // Simple hash to consistently pick a color for the same name
    final index = name.length % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final avatarColor = _getAvatarColor(farmer.name, scheme);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: avatarColor.withValues(alpha: 0.2)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(farmer.name),
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: scheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          farmer.village,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => launchDialer(farmer.mobile),
                icon: const Icon(Icons.phone_outlined, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary.withValues(alpha: 0.05),
                  foregroundColor: scheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
