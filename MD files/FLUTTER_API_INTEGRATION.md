# AUTOHIVE Flutter API Integration Guide

## Base Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'http://your-domain.com/api';
  static const String adminBaseUrl = 'http://your-domain.com/admin';
  
  // Headers
  static Map<String, String> headers(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
```

## Authentication APIs

### 1. User Registration
```dart
Future<ApiResponse> register({
  required String phone,
  required String password,
  required String firstName,
  required String lastName,
  required String birthDate,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/register'),
    headers: ApiConfig.headers(null),
    body: jsonEncode({
      'phone': phone,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
    }),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. User Login
```dart
Future<ApiResponse> login({
  required String phone,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/login'),
    headers: ApiConfig.headers(null),
    body: jsonEncode({
      'phone': phone,
      'password': password,
    }),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 3. Admin Login (Web)
```dart
Future<ApiResponse> adminLogin({
  required String phone,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.adminBaseUrl}/login'),
    headers: ApiConfig.headers(null),
    body: jsonEncode({
      'phone': phone,
      'password': password,
    }),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## User APIs

### 1. Get Profile
```dart
Future<ApiResponse> getProfile(String token) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/profile'),
    headers: ApiConfig.headers(token),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Update Profile
```dart
Future<ApiResponse> updateProfile({
  required String token,
  required String firstName,
  required String lastName,
  String? birthDate,
}) async {
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/profile'),
    headers: ApiConfig.headers(token),
    body: jsonEncode({
      'first_name': firstName,
      'last_name': lastName,
      if (birthDate != null) 'birth_date': birthDate,
    }),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Apartment APIs

### 1. Get Apartments (Public)
```dart
Future<ApiResponse> getApartments({
  int page = 1,
  String? search,
  String? city,
  String? governorate,
  double? minPrice,
  double? maxPrice,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    if (search != null) 'search': search,
    if (city != null) 'city': city,
    if (governorate != null) 'governorate': governorate,
    if (minPrice != null) 'min_price': minPrice.toString(),
    if (maxPrice != null) 'max_price': maxPrice.toString(),
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/apartments/public')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(null));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Get Apartment Details
```dart
Future<ApiResponse> getApartmentDetails(int apartmentId) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/apartments/$apartmentId/public'),
    headers: ApiConfig.headers(null),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 3. Create Apartment (Owner)
```dart
Future<ApiResponse> createApartment({
  required String token,
  required String title,
  required String description,
  required String city,
  required String governorate,
  required String address,
  required double pricePerNight,
  required int bedrooms,
  required int bathrooms,
  required int maxGuests,
  required double area,
  List<String>? amenities,
  List<File>? images,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiConfig.baseUrl}/apartments'),
  );
  
  request.headers.addAll(ApiConfig.headers(token));
  
  request.fields.addAll({
    'title': title,
    'description': description,
    'city': city,
    'governorate': governorate,
    'address': address,
    'price_per_night': pricePerNight.toString(),
    'bedrooms': bedrooms.toString(),
    'bathrooms': bathrooms.toString(),
    'max_guests': maxGuests.toString(),
    'area': area.toString(),
    if (amenities != null) 'amenities': jsonEncode(amenities),
  });
  
  if (images != null) {
    for (int i = 0; i < images.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
        'images[$i]',
        images[i].path,
      ));
    }
  }
  
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Booking APIs

### 1. Create Booking
```dart
Future<ApiResponse> createBooking({
  required String token,
  required int apartmentId,
  required String checkIn,
  required String checkOut,
  required int guests,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/bookings'),
    headers: ApiConfig.headers(token),
    body: jsonEncode({
      'apartment_id': apartmentId,
      'check_in': checkIn,
      'check_out': checkOut,
      'guests': guests,
    }),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Get User Bookings
```dart
Future<ApiResponse> getUserBookings({
  required String token,
  int page = 1,
  String? status,
}) async {
  final queryPara# AutoHive API Integration Guide

## Base Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-domain.com/api';
  
  static Map<String, String> headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

## Authentication APIs

### 1. Register
```dart
Future<ApiResponse> register({
  required String phone,
  required String firstName,
  required String lastName,
  required String password,
  required String role, // 'tenant' or 'owner'
  String? birthDate,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/register'),
    headers: ApiConfig.headers(null),
    body: jsonEncode({
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'password_confirmation': password,
      'role': role,
      if (birthDate != null) 'birth_date': birthDate,
    }),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Login
```dart
Future<ApiResponse> login(String phone, String password) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/login'),
    headers: ApiConfig.headers(null),
    body: jsonEncode({
      'phone': phone,
      'password': password,
    }),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Apartment APIs

### 1. Get Apartments with Advanced Filtering
```dart
Future<ApiResponse> getApartments({
  String? token,
  int page = 1,
  String? governorate,
  String? city,
  double? minPrice,
  double? maxPrice,
  int? minGuests,
  int? bedrooms,
  int? bathrooms,
  double? minArea,
  String? search,
  List<String>? features,
  String sortBy = 'newest', // 'price_low', 'price_high', 'rating', 'newest'
  String sortOrder = 'desc',
  int perPage = 10,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    'per_page': perPage.toString(),
    'sort_by': sortBy,
    'sort_order': sortOrder,
    if (governorate != null) 'governorate': governorate,
    if (city != null) 'city': city,
    if (minPrice != null) 'min_price': minPrice.toString(),
    if (maxPrice != null) 'max_price': maxPrice.toString(),
    if (minGuests != null) 'min_guests': minGuests.toString(),
    if (bedrooms != null) 'bedrooms': bedrooms.toString(),
    if (bathrooms != null) 'bathrooms': bathrooms.toString(),
    if (minArea != null) 'min_area': minArea.toString(),
    if (search != null) 'search': search,
  };
  
  // Add features as separate parameters
  if (features != null) {
    for (int i = 0; i < features.length; i++) {
      queryParams['features[$i]'] = features[i];
    }
  }
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/apartments')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(token));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Get Apartment Details
```dart
Future<ApiResponse> getApartmentDetails(String token, int apartmentId) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/apartments/$apartmentId'),
    headers: ApiConfig.headers(token),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Booking APIs

### 1. Check Availability
```dart
Future<ApiResponse> checkAvailability({
  required String token,
  required int apartmentId,
  required String checkIn,
  required String checkOut,
}) async {
  final queryParams = {
    'check_in': checkIn,
    'check_out': checkOut,
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/bookings/check-availability/$apartmentId')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(token));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Create Booking
```dart
Future<ApiResponse> createBooking({
  required String token,
  required int apartmentId,
  required String checkIn,
  required String checkOut,
  required Map<String, dynamic> paymentDetails,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/bookings'),
    headers: ApiConfig.headers(token),
    body: jsonEncode({
      'apartment_id': apartmentId,
      'check_in': checkIn,
      'check_out': checkOut,
      'payment_details': paymentDetails,
    }),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 3. Update Booking
```dart
Future<ApiResponse> updateBooking({
  required String token,
  required int bookingId,
  String? checkIn,
  String? checkOut,
  Map<String, dynamic>? paymentDetails,
}) async {
  final body = <String, dynamic>{};
  if (checkIn != null) body['check_in'] = checkIn;
  if (checkOut != null) body['check_out'] = checkOut;
  if (paymentDetails != null) body['payment_details'] = paymentDetails;
  
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId'),
    headers: ApiConfig.headers(token),
    body: jsonEncode(body),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 4. Cancel Booking
```dart
Future<ApiResponse> cancelBooking(String token, int bookingId) async {
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId'),
    headers: ApiConfig.headers(token),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 5. Get Bookings with Filters
```dart
Future<ApiResponse> getBookings({
  required String token,
  int page = 1,
  String? status, // 'pending', 'approved', 'cancelled', 'completed', 'active'
  String? fromDate,
  String? toDate,
  int perPage = 10,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    'per_page': perPage.toString(),
    if (status != null) 'status': status,
    if (fromDate != null) 'from_date': fromDate,
    if (toDate != null) 'to_date': toDate,
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/bookings')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(token));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 6. Get Booking History
```dart
Future<ApiResponse> getBookingHistory({
  required String token,
  int page = 1,
  String type = 'all', // 'all', 'completed', 'cancelled', 'past', 'current'
  String? fromDate,
  String? toDate,
  int perPage = 10,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    'per_page': perPage.toString(),
    'type': type,
    if (fromDate != null) 'from_date': fromDate,
    if (toDate != null) 'to_date': toDate,
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/bookings/history')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(token));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 7. Get Upcoming Bookings
```dart
Future<ApiResponse> getUpcomingBookings({
  required String token,
  int page = 1,
  int perPage = 10,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    'per_page': perPage.toString(),
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/bookings/upcoming')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(token));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Review APIs

### 1. Submit Review
```dart
Future<ApiResponse> submitReview({
  required String token,
  required int bookingId,
  required int rating,
  required String comment,
  int? cleanlinessRating,
  int? locationRating,
  int? valueRating,
  int? communicationRating,
}) async {
  final body = {
    'booking_id': bookingId,
    'rating': rating,
    'comment': comment,
  };
  
  if (cleanlinessRating != null) body['cleanliness_rating'] = cleanlinessRating;
  if (locationRating != null) body['location_rating'] = locationRating;
  if (valueRating != null) body['value_rating'] = valueRating;
  if (communicationRating != null) body['communication_rating'] = communicationRating;
  
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/reviews'),
    headers: ApiConfig.headers(token),
    body: jsonEncode(body),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Get Apartment Reviews
```dart
Future<ApiResponse> getApartmentReviews({
  required int apartmentId,
  String? token,
  int page = 1,
  int? minRating,
  String sortBy = 'newest', // 'newest', 'oldest', 'highest_rating', 'lowest_rating'
  int perPage = 10,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    'per_page': perPage.toString(),
    'sort_by': sortBy,
    if (minRating != null) 'min_rating': minRating.toString(),
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/apartments/$apartmentId/reviews')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(token));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 3. Get My Reviews
```dart
Future<ApiResponse> getMyReviews({
  required String token,
  int page = 1,
  int perPage = 10,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    'per_page': perPage.toString(),
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/my-reviews')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(token));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 4. Check if Can Review
```dart
Future<ApiResponse> canReview(String token, int bookingId) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId/can-review'),
    headers: ApiConfig.headers(token),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Dashboard APIs

### 1. User Dashboard
```dart
Future<ApiResponse> getUserDashboard(String token) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/dashboard'),
    headers: ApiConfig.headers(token),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Owner Dashboard
```dart
Future<ApiResponse> getOwnerDashboard(String token) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/owner/dashboard'),
    headers: ApiConfig.headers(token),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Location APIs

### 1. Get Governorates
```dart
Future<ApiResponse> getGovernorates() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/locations/governorates'),
    headers: ApiConfig.headers(null),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Get Cities
```dart
Future<ApiResponse> getCities(String? governorate) async {
  final uri = governorate != null 
      ? Uri.parse('${ApiConfig.baseUrl}/locations/cities/$governorate')
      : Uri.parse('${ApiConfig.baseUrl}/locations/cities');
      
  final response = await http.get(uri, headers: ApiConfig.headers(null));
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Admin APIs (Requires Admin Token)

### 1. Admin Dashboard
```dart
Future<ApiResponse> getAdminDashboard(String adminToken) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/admin/dashboard'),
    headers: ApiConfig.headers(adminToken),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Manage Users
```dart
Future<ApiResponse> getUsers({
  required String adminToken,
  int page = 1,
  String? status,
  String? search,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    if (status != null) 'status': status,
    if (search != null) 'search': search,
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/admin/users')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(adminToken));
  return ApiResponse.fromJson(jsonDecode(response.body));
}

Future<ApiResponse> approveUser(String adminToken, int userId) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId/approve'),
    headers: ApiConfig.headers(adminToken),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}

Future<ApiResponse> rejectUser(String adminToken, int userId) async {
  final response = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId'),
    headers: ApiConfig.headers(adminToken),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 3. Manage Bookings
```dart
Future<ApiResponse> getAdminBookings({
  required String adminToken,
  int page = 1,
  String? status,
  String? search,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    if (status != null) 'status': status,
    if (search != null) 'search': search,
  };
  
  final uri = Uri.parse('${ApiConfig.baseUrl}/admin/bookings')
      .replace(queryParameters: queryParams);
      
  final response = await http.get(uri, headers: ApiConfig.headers(adminToken));
  return ApiResponse.fromJson(jsonDecode(response.body));
}

Future<ApiResponse> approveBooking(String adminToken, int bookingId) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/admin/bookings/$bookingId/approve'),
    headers: ApiConfig.headers(adminToken),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Notification APIs

### 1. Check Notifications
```dart
Future<ApiResponse> checkNotifications(String token) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/notifications/check'),
    headers: ApiConfig.headers(token),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Mark Notification as Read
```dart
Future<ApiResponse> markNotificationAsRead(String token, int notificationId) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read'),
    headers: ApiConfig.headers(token),
  );
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## File Upload APIs

### 1. Upload Profile Image
```dart
Future<ApiResponse> uploadProfileImage(String token, File imageFile) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiConfig.baseUrl}/files/profile-image'),
  );
  
  request.headers.addAll(ApiConfig.headers(token));
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  return ApiResponse.fromJson(jsonDecode(response.body));
}
```

## Response Models

### ApiResponse Model
```dart
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}
```

### User Model
```dart
class User {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? birthDate;
  final String role;
  final bool isApproved;
  final DateTime createdAt;

  User({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    required this.role,
    required this.isApproved,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      birthDate: json['birth_date'],
      role: json['role'],
      isApproved: json['is_approved'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

### Apartment Model
```dart
class Apartment {
  final int id;
  final String title;
  final String description;
  final String city;
  final String governorate;
  final String address;
  final double pricePerNight;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;
  final double area;
  final bool isAvailable;
  final List<String> amenities;
  final List<String> images;
  final User owner;
  final double? averageRating;
  final int? reviewsCount;
  final int? bookingsCount;
  final List<AvailabilityDay>? availabilityCalendar;

  Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.governorate,
    required this.address,
    required this.pricePerNight,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.area,
    required this.isAvailable,
    required this.amenities,
    required this.images,
    required this.owner,
    this.averageRating,
    this.reviewsCount,
    this.bookingsCount,
    this.availabilityCalendar,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      city: json['city'],
      governorate: json['governorate'],
      address: json['address'],
      pricePerNight: double.parse(json['price_per_night'].toString()),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      maxGuests: json['max_guests'],
      area: double.parse(json['area'].toString()),
      isAvailable: json['is_available'],
      amenities: List<String>.from(json['features'] ?? json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      owner: User.fromJson(json['owner']),
      averageRating: json['average_rating']?.toDouble(),
      reviewsCount: json['reviews_count'],
      bookingsCount: json['bookings_count'],
      availabilityCalendar: json['availability_calendar'] != null
          ? List<AvailabilityDay>.from(
              json['availability_calendar'].map((x) => AvailabilityDay.fromJson(x)))
          : null,
    );
  }
}

class AvailabilityDay {
  final String date;
  final bool available;

  AvailabilityDay({required this.date, required this.available});

  factory AvailabilityDay.fromJson(Map<String, dynamic> json) {
    return AvailabilityDay(
      date: json['date'],
      available: json['available'],
    );
  }
}
```

### Booking Model
```dart
class Booking {
  final int id;
  final int apartmentId;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;
  final String status;
  final Map<String, dynamic>? paymentDetails;
  final User user;
  final Apartment apartment;
  final DateTime createdAt;
  final bool? canReview;
  final bool? canCancel;
  final bool? canModify;
  final int? daysUntilCheckin;

  Booking({
    required this.id,
    required this.apartmentId,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    this.paymentDetails,
    required this.user,
    required this.apartment,
    required this.createdAt,
    this.canReview,
    this.canCancel,
    this.canModify,
    this.daysUntilCheckin,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      apartmentId: json['apartment_id'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      paymentDetails: json['payment_details'],
      user: User.fromJson(json['user'] ?? json['tenant']),
      apartment: Apartment.fromJson(json['apartment']),
      createdAt: DateTime.parse(json['created_at']),
      canReview: json['can_review'],
      canCancel: json['can_cancel'],
      canModify: json['can_modify'],
      daysUntilCheckin: json['days_until_checkin'],
    );
  }

  int get nights => checkOut.difference(checkIn).inDays;
  bool get isPast => checkOut.isBefore(DateTime.now());
  bool get isCurrent => checkIn.isBefore(DateTime.now()) && checkOut.isAfter(DateTime.now());
  bool get isFuture => checkIn.isAfter(DateTime.now());
}
```

### Review Model
```dart
class Review {
  final int id;
  final int apartmentId;
  final int? bookingId;
  final int rating;
  final String comment;
  final int? cleanlinessRating;
  final int? locationRating;
  final int? valueRating;
  final int? communicationRating;
  final User user;
  final Apartment? apartment;
  final Booking? booking;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.apartmentId,
    this.bookingId,
    required this.rating,
    required this.comment,
    this.cleanlinessRating,
    this.locationRating,
    this.valueRating,
    this.communicationRating,
    required this.user,
    this.apartment,
    this.booking,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      apartmentId: json['apartment_id'],
      bookingId: json['booking_id'],
      rating: json['rating'],
      comment: json['comment'],
      cleanlinessRating: json['cleanliness_rating'],
      locationRating: json['location_rating'],
      valueRating: json['value_rating'],
      communicationRating: json['communication_rating'],
      user: User.fromJson(json['tenant'] ?? json['user']),
      apartment: json['apartment'] != null ? Apartment.fromJson(json['apartment']) : null,
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  double get averageDetailedRating {
    final ratings = [cleanlinessRating, locationRating, valueRating, communicationRating]
        .where((r) => r != null)
        .cast<int>();
    return ratings.isEmpty ? rating.toDouble() : ratings.reduce((a, b) => a + b) / ratings.length;
  }
}

class ReviewStatistics {
  final double averageRating;
  final int totalReviews;
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
  });

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    return ReviewStatistics(
      averageRating: double.parse(json['average_rating']?.toString() ?? '0'),
      totalReviews: json['total_reviews'] ?? 0,
      fiveStar: json['five_star'] ?? 0,
      fourStar: json['four_star'] ?? 0,
      threeStar: json['three_star'] ?? 0,
      twoStar: json['two_star'] ?? 0,
      oneStar: json['one_star'] ?? 0,
    );
  }

  double get fiveStarPercentage => totalReviews > 0 ? (fiveStar / totalReviews) * 100 : 0;
  double get fourStarPercentage => totalReviews > 0 ? (fourStar / totalReviews) * 100 : 0;
  double get threeStarPercentage => totalReviews > 0 ? (threeStar / totalReviews) * 100 : 0;
  double get twoStarPercentage => totalReviews > 0 ? (twoStar / totalReviews) * 100 : 0;
  double get oneStarPercentage => totalReviews > 0 ? (oneStar / totalReviews) * 100 : 0;
}
```

### Dashboard Models
```dart
class UserDashboard {
  final User user;
  final DashboardStatistics statistics;
  final List<Booking> recentBookings;
  final List<Booking> upcomingBookings;
  final List<Apartment> favoriteApartments;
  final List<Booking> pendingReviews;

  UserDashboard({
    required this.user,
    required this.statistics,
    required this.recentBookings,
    required this.upcomingBookings,
    required this.favoriteApartments,
    required this.pendingReviews,
  });

  factory UserDashboard.fromJson(Map<String, dynamic> json) {
    return UserDashboard(
      user: User.fromJson(json['user']),
      statistics: DashboardStatistics.fromJson(json['statistics']),
      recentBookings: List<Booking>.from(
          json['recent_bookings'].map((x) => Booking.fromJson(x))),
      upcomingBookings: List<Booking>.from(
          json['upcoming_bookings'].map((x) => Booking.fromJson(x))),
      favoriteApartments: List<Apartment>.from(
          json['favorite_apartments'].map((x) => Apartment.fromJson(x))),
      pendingReviews: List<Booking>.from(
          json['pending_reviews'].map((x) => Booking.fromJson(x))),
    );
  }
}

class OwnerDashboard {
  final User user;
  final OwnerStatistics statistics;
  final List<Booking> recentBookings;
  final List<Booking> pendingBookings;
  final List<ApartmentPerformance> apartmentsPerformance;
  final List<MonthlyEarning> monthlyEarnings;

  OwnerDashboard({
    required this.user,
    required this.statistics,
    required this.recentBookings,
    required this.pendingBookings,
    required this.apartmentsPerformance,
    required this.monthlyEarnings,
  });

  factory OwnerDashboard.fromJson(Map<String, dynamic> json) {
    return OwnerDashboard(
      user: User.fromJson(json['user']),
      statistics: OwnerStatistics.fromJson(json['statistics']),
      recentBookings: List<Booking>.from(
          json['recent_bookings'].map((x) => Booking.fromJson(x))),
      pendingBookings: List<Booking>.from(
          json['pending_bookings'].map((x) => Booking.fromJson(x))),
      apartmentsPerformance: List<ApartmentPerformance>.from(
          json['apartments_performance'].map((x) => ApartmentPerformance.fromJson(x))),
      monthlyEarnings: List<MonthlyEarning>.from(
          json['monthly_earnings'].map((x) => MonthlyEarning.fromJson(x))),
    );
  }
}

class DashboardStatistics {
  final int totalBookings;
  final int activeBookings;
  final int completedBookings;
  final double totalSpent;

  DashboardStatistics({
    required this.totalBookings,
    required this.activeBookings,
    required this.completedBookings,
    required this.totalSpent,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      totalBookings: json['total_bookings'] ?? 0,
      activeBookings: json['active_bookings'] ?? 0,
      completedBookings: json['completed_bookings'] ?? 0,
      totalSpent: double.parse(json['total_spent']?.toString() ?? '0'),
    );
  }
}

class OwnerStatistics {
  final int totalApartments;
  final int activeApartments;
  final int totalBookings;
  final int pendingBookings;
  final double totalEarnings;
  final double thisMonthEarnings;

  OwnerStatistics({
    required this.totalApartments,
    required this.activeApartments,
    required this.totalBookings,
    required this.pendingBookings,
    required this.totalEarnings,
    required this.thisMonthEarnings,
  });

  factory OwnerStatistics.fromJson(Map<String, dynamic> json) {
    return OwnerStatistics(
      totalApartments: json['total_apartments'] ?? 0,
      activeApartments: json['active_apartments'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      pendingBookings: json['pending_bookings'] ?? 0,
      totalEarnings: double.parse(json['total_earnings']?.toString() ?? '0'),
      thisMonthEarnings: double.parse(json['this_month_earnings']?.toString() ?? '0'),
    );
  }
}

class ApartmentPerformance {
  final Apartment apartment;
  final int bookingsCount;
  final int reviewsCount;
  final double? averageRating;
  final double totalEarnings;
  final double occupancyRate;

  ApartmentPerformance({
    required this.apartment,
    required this.bookingsCount,
    required this.reviewsCount,
    this.averageRating,
    required this.totalEarnings,
    required this.occupancyRate,
  });

  factory ApartmentPerformance.fromJson(Map<String, dynamic> json) {
    return ApartmentPerformance(
      apartment: Apartment.fromJson(json),
      bookingsCount: json['bookings_count'] ?? 0,
      reviewsCount: json['reviews_count'] ?? 0,
      averageRating: json['reviews_avg_rating']?.toDouble(),
      totalEarnings: double.parse(json['total_earnings']?.toString() ?? '0'),
      occupancyRate: double.parse(json['occupancy_rate']?.toString() ?? '0'),
    );
  }
}

class MonthlyEarning {
  final String month;
  final double earnings;

  MonthlyEarning({required this.month, required this.earnings});

  factory MonthlyEarning.fromJson(Map<String, dynamic> json) {
    return MonthlyEarning(
      month: json['month'],
      earnings: double.parse(json['earnings']?.toString() ?? '0'),
    );
  }
}
```

## Error Handling

```dart
class ApiService {
  static Future<ApiResponse> handleResponse(http.Response response) async {
    try {
      final jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(jsonResponse);
      } else {
        return ApiResponse(
          success: false,
          message: jsonResponse['message'] ?? 'An error occurred',
          errors: jsonResponse['errors'] != null 
              ? List<String>.from(jsonResponse['errors']) 
              : null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
```

## Usage Examples

### 1. Complete Apartment Search with Filters
```dart
class ApartmentSearchService {
  static Future<List<Apartment>> searchApartments({
    String? governorate,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    List<String>? amenities,
    String sortBy = 'newest',
  }) async {
    try {
      final response = await getApartments(
        governorate: governorate,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        features: amenities,
        sortBy: sortBy,
      );
      
      if (response.success) {
        final data = response.data['data'] as List;
        return data.map((json) => Apartment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching apartments: $e');
      return [];
    }
  }
}
```

### 2. Complete Booking Flow
```dart
class BookingService {
  static Future<BookingResult> createBookingWithValidation({
    required String token,
    required int apartmentId,
    required DateTime checkIn,
    required DateTime checkOut,
    required PaymentDetails paymentDetails,
  }) async {
    try {
      // Step 1: Check availability
      final availabilityResponse = await checkAvailability(
        token: token,
        apartmentId: apartmentId,
        checkIn: checkIn.toIso8601String().split('T')[0],
        checkOut: checkOut.toIso8601String().split('T')[0],
      );
      
      if (!availabilityResponse.success || !availabilityResponse.data['available']) {
        return BookingResult.failure('Apartment not available for selected dates');
      }
      
      // Step 2: Create booking
      final bookingResponse = await createBooking(
        token: token,
        apartmentId: apartmentId,
        checkIn: checkIn.toIso8601String().split('T')[0],
        checkOut: checkOut.toIso8601String().split('T')[0],
        paymentDetails: paymentDetails.toJson(),
      );
      
      if (bookingResponse.success) {
        final booking = Booking.fromJson(bookingResponse.data);
        return BookingResult.success(booking);
      }
      
      return BookingResult.failure(bookingResponse.message);
    } catch (e) {
      return BookingResult.failure('Network error: $e');
    }
  }
}

class BookingResult {
  final bool success;
  final String? message;
  final Booking? booking;
  
  BookingResult.success(this.booking) : success = true, message = null;
  BookingResult.failure(this.message) : success = false, booking = null;
}

class PaymentDetails {
  final String method;
  final String? cardNumber;
  final String? cardholderName;
  final String? expiryDate;
  final String? cvv;
  
  PaymentDetails({
    required this.method,
    this.cardNumber,
    this.cardholderName,
    this.expiryDate,
    this.cvv,
  });
  
  Map<String, dynamic> toJson() => {
    'method': method,
    if (cardNumber != null) 'card_number': cardNumber,
    if (cardholderName != null) 'cardholder_name': cardholderName,
    if (expiryDate != null) 'expiry_date': expiryDate,
    if (cvv != null) 'cvv': cvv,
  };
}
```

### 3. Review Management
```dart
class ReviewService {
  static Future<bool> submitDetailedReview({
    required String token,
    required int bookingId,
    required int overallRating,
    required String comment,
    int? cleanlinessRating,
    int? locationRating,
    int? valueRating,
    int? communicationRating,
  }) async {
    try {
      final response = await submitReview(
        token: token,
        bookingId: bookingId,
        rating: overallRating,
        comment: comment,
        cleanlinessRating: cleanlinessRating,
        locationRating: locationRating,
        valueRating: valueRating,
        communicationRating: communicationRating,
      );
      
      return response.success;
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }
  
  static Future<List<Review>> getApartmentReviewsWithStats(int apartmentId) async {
    try {
      final response = await getApartmentReviews(apartmentId: apartmentId);
      
      if (response.success) {
        final reviewsData = response.data['reviews']['data'] as List;
        return reviewsData.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
}
```

### 4. Dashboard Data Management
```dart
class DashboardService {
  static Future<UserDashboard?> getUserDashboardData(String token) async {
    try {
      final response = await getUserDashboard(token);
      
      if (response.success) {
        return UserDashboard.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching dashboard: $e');
      return null;
    }
  }
  
  static Future<OwnerDashboard?> getOwnerDashboardData(String token) async {
    try {
      final response = await getOwnerDashboard(token);
      
      if (response.success) {
        return OwnerDashboard.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching owner dashboard: $e');
      return null;
    }
  }
}
```

## Best Practices

### 1. Error Handling
```dart
class ApiErrorHandler {
  static String getErrorMessage(ApiResponse response) {
    if (response.errors != null && response.errors!.isNotEmpty) {
      return response.errors!.first;
    }
    return response.message.isNotEmpty ? response.message : 'An error occurred';
  }
  
  static void handleApiError(ApiResponse response, {
    VoidCallback? onUnauthorized,
    VoidCallback? onValidationError,
    Function(String)? onGeneralError,
  }) {
    if (response.message.toLowerCase().contains('unauthorized')) {
      onUnauthorized?.call();
    } else if (response.errors != null) {
      onValidationError?.call();
    } else {
      onGeneralError?.call(getErrorMessage(response));
    }
  }
}
```

### 2. Token Management
```dart
class TokenManager {
  static const String _tokenKey = 'auth_token';
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
```

### 3. Caching Strategy
```dart
class CacheManager {
  static final Map<String, CacheItem> _cache = {};
  
  static void cacheApartments(String key, List<Apartment> apartments) {
    _cache[key] = CacheItem(apartments, DateTime.now());
  }
  
  static List<Apartment>? getCachedApartments(String key) {
    final item = _cache[key];
    if (item != null && DateTime.now().difference(item.timestamp).inMinutes < 5) {
      return item.data as List<Apartment>;
    }
    return null;
  }
}

class CacheItem {
  final dynamic data;
  final DateTime timestamp;
  
  CacheItem(this.data, this.timestamp);
}
```

## Real-time Notifications (WebSocket)

```dart
class NotificationService {
  static IOWebSocketChannel? _channel;
  static StreamController<Map<String, dynamic>>? _controller;

  static Stream<Map<String, dynamic>> get notificationStream => 
      _controller?.stream ?? const Stream.empty();

  static void connect(String token) {
    _controller = StreamController<Map<String, dynamic>>.broadcast();
    
    _channel = IOWebSocketChannel.connect(
      'ws://your-domain.com/ws',
      headers: {'Authorization': 'Bearer $token'},
    );

    _channel?.stream.listen(
      (data) {
        final notification = jsonDecode(data);
        _controller?.add(notification);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );
  }

  static void disconnect() {
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
```

This comprehensive API integration guide provides all the necessary endpoints and models for your Flutter application to work seamlessly with the AUTOHIVE Laravel backend.