class PaymentModel {
  final String id;
  final String farmerId;
  final String sessionId;
  final DateTime date;
  final double amount;
  final String? note;

  PaymentModel({
    required this.id,
    required this.farmerId,
    required this.sessionId,
    required this.date,
    required this.amount,
    this.note,
  });

  PaymentModel copyWith({
    String? id,
    String? farmerId,
    String? sessionId,
    DateTime? date,
    double? amount,
    String? note,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      sessionId: sessionId ?? this.sessionId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}
