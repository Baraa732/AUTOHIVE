import 'apartment.dart';

class Favorite {
  final String id;
  final String userId;
  final String apartmentId;
  final Apartment apartment;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.apartment,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    try {
      return Favorite(
        id: json['id'].toString(),
        userId: json['user_id'].toString(),
        apartmentId: json['apartment_id'].toString(),
        apartment: Apartment.fromJson(json['apartment'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['created_at']),
      );
    } catch (e) {
      print('❌ Error parsing Favorite: $e');
      print('📦 JSON data: $json');
      rethrow;
    }
  }
}
