import 'package:flutter/material.dart';
import 'package:gur_bhatti_manager/l10n/generated/app_localizations.dart';

import '../domain/payment_status.dart';

class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (bg, fg, label) = switch (status) {
      PaymentStatus.pending => (
          const Color(0xFFFEE2E2),
          const Color(0xFF991B1B),
          l10n.statusPending,
        ),
      PaymentStatus.partial => (
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
          l10n.statusPartial,
        ),
      PaymentStatus.paid => (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
          l10n.statusPaid,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          fontSize: 9,
        ),
      ),
    );
  }
}
