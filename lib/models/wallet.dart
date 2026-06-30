class Wallet {
  final int id;
  final String phoneNumber;
  final String email;
  final String code;
  final double balance;
  final String currency;
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.code,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      code: json['code'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phoneNumber': phoneNumber,
    'email': email,
    'code': code,
    'balance': balance,
    'currency': currency,
    'createdAt': createdAt.toIso8601String(),
  };
}