/// Permanent farmer master record (session-agnostic).
class Farmer {
  const Farmer({
    required this.id,
    required this.name,
    required this.village,
    required this.mobile,
    required this.bankName,
    this.bankAccount,
    this.ifscCode,
  });

  final String id;
  final String name;
  final String village;
  final String mobile;
  final String bankName;
  final String? bankAccount;
  final String? ifscCode;
}
