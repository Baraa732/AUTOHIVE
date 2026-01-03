class Wallet {
  final int id;
  final int userId;
  final int balanceSpy;
  final String currency;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balanceSpy,
    required this.currency,
    required this.createdAt,
    this.updatedAt,
  });

  double get balanceUsd => balanceSpy / 110;

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      balanceSpy: int.parse(json['balance_spy'].toString()),
      currency: json['currency'] as String? ?? 'SPY',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'] as String) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance_spy': balanceSpy,
      'balance_usd': balanceUsd,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
