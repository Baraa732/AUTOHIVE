class User {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profileImageUrl;
  final String? city;
  final String? governorate;
  final String? birthDate;
  final String? status; // 'pending', 'approved', 'rejected'
  final bool isVerified;

  const User({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.profileImageUrl,
    this.city,
    this.governorate,
    this.birthDate,
    this.status,
    this.isVerified = false,
  });

  // Get full name
  String get name => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      city: json['city'],
      governorate: json['governorate'],
      birthDate: json['birth_date'],
      status: json['status'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'city': city,
      'governorate': governorate,
      'birth_date': birthDate,
      'status': status,
      'is_verified': isVerified,
    };
  }
}