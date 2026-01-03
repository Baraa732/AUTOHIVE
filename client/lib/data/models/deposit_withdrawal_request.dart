enum DepositWithdrawalType {
  deposit,
  withdrawal,
}

extension DepositWithdrawalTypeExtension on DepositWithdrawalType {
  String get value {
    switch (this) {
      case DepositWithdrawalType.deposit:
        return 'deposit';
      case DepositWithdrawalType.withdrawal:
        return 'withdrawal';
    }
  }

  String get displayName {
    switch (this) {
      case DepositWithdrawalType.deposit:
        return 'Deposit';
      case DepositWithdrawalType.withdrawal:
        return 'Withdrawal';
    }
  }

  static DepositWithdrawalType fromString(String value) {
    switch (value) {
      case 'deposit':
        return DepositWithdrawalType.deposit;
      case 'withdrawal':
        return DepositWithdrawalType.withdrawal;
      default:
        return DepositWithdrawalType.deposit;
    }
  }
}

enum RequestStatus {
  pending,
  approved,
  rejected,
}

extension RequestStatusExtension on RequestStatus {
  String get value {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.approved:
        return 'approved';
      case RequestStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }

  static RequestStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return RequestStatus.pending;
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }
}

class DepositWithdrawalRequest {
  final int id;
  final int userId;
  final DepositWithdrawalType type;
  final int amountSpy;
  final RequestStatus status;
  final String? reason;
  final int? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DepositWithdrawalRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.amountSpy,
    required this.status,
    this.reason,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    this.updatedAt,
  });

  double get amountUsd => amountSpy / 110;

  factory DepositWithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return DepositWithdrawalRequest(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: DepositWithdrawalTypeExtension.fromString(json['type'] as String),
      amountSpy: int.parse(json['amount_spy'].toString()),
      status: RequestStatusExtension.fromString(json['status'] as String),
      reason: json['reason'] as String?,
      approvedBy: json['approved_by'] as int?,
      approvedAt: json['approved_at'] != null 
        ? DateTime.parse(json['approved_at'] as String) 
        : null,
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
      'type': type.value,
      'amount_spy': amountSpy,
      'amount_usd': amountUsd,
      'status': status.value,
      'reason': reason,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
