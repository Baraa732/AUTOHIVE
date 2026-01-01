class RentalModification {
  final String id;
  final String rentalApplicationId;
  final String status;
  final Map<String, dynamic>? previousValues;
  final Map<String, dynamic>? newValues;
  final Map<String, dynamic>? diff;
  final String? modificationReason;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? respondedAt;

  const RentalModification({
    required this.id,
    required this.rentalApplicationId,
    required this.status,
    this.previousValues,
    this.newValues,
    this.diff,
    this.modificationReason,
    this.rejectionReason,
    required this.submittedAt,
    this.respondedAt,
  });

  bool isPending() => status == 'pending';
  bool isApproved() => status == 'approved';
  bool isRejected() => status == 'rejected';

  factory RentalModification.fromJson(Map<String, dynamic> json) {
    return RentalModification(
      id: json['id'].toString(),
      rentalApplicationId: json['rental_application_id'].toString(),
      status: json['status'] ?? 'pending',
      previousValues: json['previous_values'] as Map<String, dynamic>?,
      newValues: json['new_values'] as Map<String, dynamic>?,
      diff: json['diff'] as Map<String, dynamic>?,
      modificationReason: json['modification_reason'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: DateTime.parse(json['submitted_at']),
      respondedAt: json['responded_at'] != null 
          ? DateTime.parse(json['responded_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rental_application_id': rentalApplicationId,
      'status': status,
      'previous_values': previousValues,
      'new_values': newValues,
      'diff': diff,
      'modification_reason': modificationReason,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }
}
