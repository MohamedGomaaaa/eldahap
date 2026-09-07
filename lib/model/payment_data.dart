class PaymentData {
  final String id;
  final String name;
  final bool isEnabled;
  final String? accountNumber;
  final String? bankName;

  PaymentData({
    required this.id,
    required this.name,
    required this.isEnabled,
    this.accountNumber,
    this.bankName,
  });
}