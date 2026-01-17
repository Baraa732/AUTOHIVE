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
  final String? previousStatus;
  final Map<String, dynamic>? previousData;
  final Map<String, dynamic>? currentData;
  final String? modificationReason;
  final DateTime? modificationSubmittedAt;
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
    this.previousStatus,
    this.previousData,
    this.currentData,
    this.modificationReason,
    this.modificationSubmittedAt,
    this.user,
    this.apartment,
  });

  bool canBeModified() {
    return status == 'pending' || status == 'approved';
  }

  bool hasModification() {
    return status == 'modified-pending' || status == 'modified-approved';
  }

  factory RentalApplication.fromJson(Map<String, dynamic> json) {
    // Helper function to parse dates correctly without timezone issues
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) throw Exception('Date value is null');
      final dateStr = dateValue.toString();
      
      // If it's just a date (YYYY-MM-DD), parse as local date without time
      if (dateStr.length == 10 && !dateStr.contains('T')) {
        final parts = dateStr.split('-');
        return DateTime(
          int.parse(parts[0]), // year
          int.parse(parts[1]), // month
          int.parse(parts[2]), // day
        );
      }
      
      // For datetime strings, parse normally
      return DateTime.parse(dateStr.replaceAll('Z', ''));
    }

    return RentalApplication(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      apartmentId: json['apartment_id'].toString(),
      checkIn: parseDate(json['check_in']),
      checkOut: parseDate(json['check_out']),
      message: json['message'] as String?,
      submissionAttempt: json['submission_attempt'] ?? 0,
      status: json['status'] ?? 'pending',
      rejectedReason: json['rejected_reason'] as String?,
      submittedAt: parseDate(json['submitted_at']),
      respondedAt: json['responded_at'] != null 
          ? parseDate(json['responded_at']) 
          : null,
      previousStatus: json['previous_status'] as String?,
      previousData: json['previous_data'] as Map<String, dynamic>?,
      currentData: json['current_data'] as Map<String, dynamic>?,
      modificationReason: json['modification_reason'] as String?,
      modificationSubmittedAt: json['modification_submitted_at'] != null
          ? parseDate(json['modification_submitted_at'])
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
      'previous_status': previousStatus,
      'previous_data': previousData,
      'current_data': currentData,
      'modification_reason': modificationReason,
      'modification_submitted_at': modificationSubmittedAt?.toIso8601String(),
      'user': user,
      'apartment': apartment,
    };
  }
}
