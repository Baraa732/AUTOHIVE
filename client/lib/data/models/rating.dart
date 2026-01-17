class Rating {
  final int id;
  final int userId;
  final int apartmentId;
  final int? bookingId;
  final int rating;
  final String? comment;
  final int? cleanlinessRating;
  final int? locationRating;
  final int? valueRating;
  final int? communicationRating;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? user;

  Rating({
    required this.id,
    required this.userId,
    required this.apartmentId,
    this.bookingId,
    required this.rating,
    this.comment,
    this.cleanlinessRating,
    this.locationRating,
    this.valueRating,
    this.communicationRating,
    required this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      apartmentId: json['apartment_id'] ?? 0,
      bookingId: json['booking_id'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      cleanlinessRating: json['cleanliness_rating'],
      locationRating: json['location_rating'],
      valueRating: json['value_rating'],
      communicationRating: json['communication_rating'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: json['user'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'apartment_id': apartmentId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'cleanliness_rating': cleanlinessRating,
      'location_rating': locationRating,
      'value_rating': valueRating,
      'communication_rating': communicationRating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  double get ratingPercentage => (rating / 5) * 100;
}
