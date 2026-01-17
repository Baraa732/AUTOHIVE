class Booking {
  final String id;
  final String apartmentId;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? guests;
  final String? message;
  final Map<String, dynamic>? apartment;
  final Map<String, dynamic>? user;

  const Booking({
    required this.id,
    required this.apartmentId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.guests,
    this.message,
    this.apartment,
    this.user,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
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

      // For datetime strings, parse as UTC to avoid timezone issues
      if (dateStr.endsWith('Z')) {
        // Parse as UTC time
        return DateTime.parse(dateStr).toUtc();
      }

      // For other datetime strings, parse normally
      return DateTime.parse(dateStr.replaceAll('Z', ''));
    }

    try {
      return Booking(
        id: json['id'].toString(),
        apartmentId: json['apartment_id'].toString(),
        userId: json['user_id'].toString(),
        checkIn: parseDate(json['check_in']),
        checkOut: parseDate(json['check_out']),
        totalPrice: double.parse(json['total_price'].toString()),
        status: json['status'] ?? 'pending',
        createdAt: parseDate(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? parseDate(json['updated_at'])
            : null,
        guests: json['guests'] as int?,
        message: json['message'] as String?,
        apartment: json['apartment'] as Map<String, dynamic>?,
        user: json['user'] as Map<String, dynamic>?,
      );
    } catch (e) {
      print('❌ Error parsing Booking from JSON: $e');
      print('📋 JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      'user_id': userId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
