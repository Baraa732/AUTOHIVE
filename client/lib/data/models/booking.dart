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
    return Booking(
      id: json['id'].toString(),
      apartmentId: json['apartment_id'].toString(),
      userId: json['user_id'].toString(),
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      guests: json['guests'] as int?,
      message: json['message'] as String?,
      apartment: json['apartment'] as Map<String, dynamic>?,
      user: json['user'] as Map<String, dynamic>?,
    );
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