enum PaymentStatus {
  pending,
  partial,
  paid,
}

extension PaymentStatusLabel on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pending => 'PENDING',
        PaymentStatus.partial => 'PARTIAL',
        PaymentStatus.paid => 'PAID',
      };
}
