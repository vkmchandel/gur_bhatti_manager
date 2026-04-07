class SessionModel {
  const SessionModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
}
