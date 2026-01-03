enum TransactionType {
  deposit,
  withdrawal,
  rentalPayment,
  rentalReceived,
}

extension TransactionTypeExtension on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.deposit:
        return 'deposit';
      case TransactionType.withdrawal:
        return 'withdrawal';
      case TransactionType.rentalPayment:
        return 'rental_payment';
      case TransactionType.rentalReceived:
        return 'rental_received';
    }
  }

  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.rentalPayment:
        return 'Rental Payment';
      case TransactionType.rentalReceived:
        return 'Rental Received';
    }
  }

  static TransactionType fromString(String value) {
    switch (value) {
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'rental_payment':
        return TransactionType.rentalPayment;
      case 'rental_received':
        return TransactionType.rentalReceived;
      default:
        return TransactionType.deposit;
    }
  }
}

class WalletTransaction {
  final int id;
  final int walletId;
  final int userId;
  final TransactionType type;
  final int amountSpy;
  final String? description;
  final int? relatedUserId;
  final int? relatedBookingId;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.type,
    required this.amountSpy,
    this.description,
    this.relatedUserId,
    this.relatedBookingId,
    required this.createdAt,
  });

  double get amountUsd => amountSpy / 110;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int,
      walletId: json['wallet_id'] as int,
      userId: json['user_id'] as int,
      type: TransactionTypeExtension.fromString(json['type'] as String),
      amountSpy: int.parse(json['amount_spy'].toString()),
      description: json['description'] as String?,
      relatedUserId: json['related_user_id'] as int?,
      relatedBookingId: json['related_booking_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'user_id': userId,
      'type': type.value,
      'amount_spy': amountSpy,
      'amount_usd': amountUsd,
      'description': description,
      'related_user_id': relatedUserId,
      'related_booking_id': relatedBookingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
