/// Permanent farmer master record (session-agnostic).
class FarmerModel {
  const FarmerModel({
    required this.id,
    required this.name,
    required this.village,
    required this.mobile,
    this.bankName,
    this.bankAccount,
    this.ifscCode,
  });

  final String id;
  final String name;
  final String village;
  final String mobile;
  final String? bankName;
  final String? bankAccount;
  final String? ifscCode;
}
