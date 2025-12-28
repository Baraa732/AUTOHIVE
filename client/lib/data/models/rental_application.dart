class RentalApplication {
  final String id;
  final String userId;
  final String apartmentId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String? message;
  final int submissionAttempt;
  final String status;
  final String? rejectedReason;
  final DateTime submittedAt;
  final DateTime? respondedAt;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? apartment;

  const RentalApplication({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.checkIn,
    required this.checkOut,
    this.message,
    required this.submissionAttempt,
    required this.status,
    this.rejectedReason,
    required this.submittedAt,
    this.respondedAt,
    this.user,
    this.apartment,
  });

  factory RentalApplication.fromJson(Map<String, dynamic> json) {
    return RentalApplication(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      apartmentId: json['apartment_id'].toString(),
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      message: json['message'] as String?,
      submissionAttempt: json['submission_attempt'] ?? 0,
      status: json['status'] ?? 'pending',
      rejectedReason: json['rejected_reason'] as String?,
      submittedAt: DateTime.parse(json['submitted_at']),
      respondedAt: json['responded_at'] != null 
          ? DateTime.parse(json['responded_at']) 
          : null,
      user: json['user'] as Map<String, dynamic>?,
      apartment: json['apartment'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'apartment_id': apartmentId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'message': message,
      'submission_attempt': submissionAttempt,
      'status': status,
      'rejected_reason': rejectedReason,
      'submitted_at': submittedAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'user': user,
      'apartment': apartment,
    };
  }
}
