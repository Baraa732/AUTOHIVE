import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'error_handler.dart';
import '../constants/app_config.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getApartments({String? search}) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      // Only show available apartments to public
      String url = '$apiUrl/apartments/public';
      List<String> params = ['available=1']; // Filter only available apartments
      
      if (search != null && search.isNotEmpty) {
        params.add('search=$search');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 30));
      final data = json.decode(response.body);
      
      return data;
    } catch (e, stackTrace) {
      ErrorHandler.logError('getApartments', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading apartments');
    }
  }

  // Home endpoint
  Future<Map<String, dynamic>> getHome() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      print('🏠 Calling dashboard endpoint: $apiUrl/dashboard');
      print('📋 Headers: $headers');
      
      final response = await http.get(Uri.parse('$apiUrl/dashboard'), headers: headers).timeout(const Duration(seconds: 30));
      print('📊 Dashboard response status: ${response.statusCode}');
      print('📦 Dashboard response body: ${response.body}');
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      print('❌ Dashboard error: $e');
      ErrorHandler.logError('getHome', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading home data');
    }
  }

  Future<Map<String, dynamic>> getApartmentDetails(String id) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      // Try authenticated endpoint first to get owner info
      final token = await _authService.getToken();
      String endpoint = token != null ? '/apartments/$id' : '/apartments/$id/public';
      
      final response = await http.get(Uri.parse('$apiUrl$endpoint'), headers: headers).timeout(const Duration(seconds: 30));
      final data = json.decode(response.body);

      return data;
    } catch (e, stackTrace) {
      ErrorHandler.logError('getApartmentDetails', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading apartment details');
    }
  }

  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/favorites'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getFavorites', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading favorites');
    }
  }

  Future<Map<String, dynamic>> addToFavorites(String apartmentId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/favorites'),
        headers: headers,
        body: json.encode({'apartment_id': apartmentId}),
      ).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('addToFavorites', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Adding to favorites');
    }
  }

  Future<Map<String, dynamic>> removeFromFavorites(String favoriteId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.delete(
        Uri.parse('$apiUrl/favorites/$favoriteId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('removeFromFavorites', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Removing from favorites');
    }
  }

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/notifications'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getNotifications', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading notifications');
    }
  }

  Future<Map<String, dynamic>> markNotificationRead(String id) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(Uri.parse('$apiUrl/notifications/$id/read'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('markNotificationRead', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Marking notification as read');
    }
  }

  Future<Map<String, dynamic>> getMyApartments() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/my-apartments'), headers: headers).timeout(const Duration(seconds: 30));
      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'data': data['data'] ?? data,
        'message': data['message'] ?? 'My apartments retrieved successfully'
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyApartments', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading my apartments');
    }
  }

  Future<Map<String, dynamic>> createApartment({
    required Map<String, dynamic> apartmentData,
    required List<File> images,
  }) async {
    try {
      final apiUrl = await AppConfig.baseUrl;
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/apartments'));
      
      // Get token for authorization
      final token = await _authService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add form fields
      apartmentData.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            for (int i = 0; i < value.length; i++) {
              request.fields['$key[$i]'] = value[i].toString();
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add image files - backend expects at least one image
      if (images.isEmpty) {
        return {
          'success': false,
          'message': 'At least one image is required',
        };
      }
      
      for (int i = 0; i < images.length; i++) {
        final file = await http.MultipartFile.fromPath(
          'images[$i]',
          images[i].path,
          filename: 'apartment_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        request.files.add(file);
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await streamedResponse.stream.bytesToString();
      
      Map<String, dynamic> data;
      try {
        data = json.decode(responseBody);
      } catch (e) {
        return {
          'success': false,
          'message': 'Server response error. Please try again.',
        };
      }
      
      return {
        'success': streamedResponse.statusCode == 201,
        'message': data['message'] ?? (streamedResponse.statusCode == 201 ? 'Apartment created successfully' : 'Failed to create apartment'),
        'data': data['data'],
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('createApartment', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Creating apartment');
    }
  }

  Future<Map<String, dynamic>> updateApartment({
    required String apartmentId,
    required Map<String, dynamic> apartmentData,
    required List<File> images,
  }) async {
    try {
      final apiUrl = await AppConfig.baseUrl;
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/apartments/$apartmentId'));
      
      final token = await _authService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      request.fields['_method'] = 'PUT'; // Laravel method spoofing
      
      apartmentData.forEach((key, value) {
        if (value != null) {
          if (key == 'existing_images' && value is List) {
            // Send existing images as array
            for (int i = 0; i < value.length; i++) {
              request.fields['existing_images[$i]'] = value[i].toString();
            }
          } else if (value is List) {
            // Send other arrays
            for (int i = 0; i < value.length; i++) {
              request.fields['$key[$i]'] = value[i].toString();
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });
      
      // Add new images
      for (int i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images[$i]',
            images[i].path,
            filename: 'apartment_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          )
        );
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(responseBody);
      
      return {
        'success': streamedResponse.statusCode == 200,
        'message': data['message'] ?? (streamedResponse.statusCode == 200 ? 'Apartment updated successfully' : 'Failed to update apartment'),
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('updateApartment', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Updating apartment');
    }
  }

  Future<Map<String, dynamic>> deleteApartment(String apartmentId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.delete(
        Uri.parse('$apiUrl/apartments/$apartmentId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? (response.statusCode == 200 ? 'Apartment deleted successfully' : 'Failed to delete apartment')
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('deleteApartment', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Deleting apartment');
    }
  }

  Future<Map<String, dynamic>> toggleApartmentAvailability(String apartmentId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/apartments/$apartmentId/toggle-availability'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Availability updated'
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('toggleApartmentAvailability', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Updating availability');
    }
  }

  Future<Map<String, dynamic>> createBookingRequest({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
    required int guests,
    String? message,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      print('📝 Creating booking request:');
      print('   URL: $apiUrl/booking-requests');
      print('   ApartmentID: $apartmentId');
      print('   CheckIn: $checkIn');
      print('   CheckOut: $checkOut');
      print('   Guests: $guests');
      
      final response = await http.post(
        Uri.parse('$apiUrl/booking-requests'),
        headers: headers,
        body: json.encode({
          'apartment_id': apartmentId,
          'check_in': checkIn,
          'check_out': checkOut,
          'guests': guests,
          if (message != null) 'message': message,
        }),
      ).timeout(const Duration(seconds: 30));
      
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Booking request sent successfully',
          'data': data['data']
        };
      } else {
        // Handle error response
        String errorMessage = 'Failed to create booking request';
        String? errorDetails;
        
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? errorMessage;
          
          // Extract validation errors if present
          if (data['errors'] is Map) {
            final errors = data['errors'] as Map<String, dynamic>;
            final errorList = <String>[];
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorList.add('${key.replaceAll('_', ' ')}: ${value.first}');
              } else if (value is String) {
                errorList.add('${key.replaceAll('_', ' ')}: $value');
              }
            });
            if (errorList.isNotEmpty) {
              errorDetails = errorList.join('\n');
            }
          }
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'details': errorDetails,
          'data': null
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception in createBookingRequest: $e');
      print('Stack Trace: $stackTrace');
      ErrorHandler.logError('createBookingRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Creating booking request');
    }
  }

  Future<Map<String, dynamic>> getMyBookingRequests() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/my-booking-requests'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyBookingRequests', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading booking requests');
    }
  }

  Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final url = '$apiUrl/bookings';
      print('    🌐 HTTP GET: $url');
      print('    📋 Headers: $headers');
      
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 30));
      print('    ↩️ Status: ${response.statusCode}');
      print('    📦 Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      if (response.statusCode != 200) {
        print('    ❌ Non-200 status, handling error');
        return ErrorHandler.handleApiError(response, operation: 'Loading bookings');
      }
      
      final decoded = json.decode(response.body);
      print('    ✅ Successfully decoded response');
      return decoded;
    } catch (e, stackTrace) {
      print('    💥 Exception in getMyBookings: $e');
      ErrorHandler.logError('getMyBookings', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading bookings');
    }
  }

  Future<Map<String, dynamic>> getApartmentBookingRequests() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/my-apartment-booking-requests'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getApartmentBookingRequests', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading apartment booking requests');
    }
  }

  Future<Map<String, dynamic>> getMyApartmentBookings() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final url = '$apiUrl/my-apartment-bookings';
      print('    🌐 HTTP GET: $url');
      print('    📋 Headers: $headers');
      
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 30));
      print('    ↩️ Status: ${response.statusCode}');
      print('    📦 Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      if (response.statusCode != 200) {
        print('    ❌ Non-200 status, handling error');
        return ErrorHandler.handleApiError(response, operation: 'Loading apartment bookings');
      }
      
      final decoded = json.decode(response.body);
      print('    ✅ Successfully decoded response');
      return decoded;
    } catch (e, stackTrace) {
      print('    💥 Exception in getMyApartmentBookings: $e');
      ErrorHandler.logError('getMyApartmentBookings', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading apartment bookings');
    }
  }

  Future<Map<String, dynamic>> getUpcomingApartmentBookings() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/bookings/upcoming-on-apartments'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getUpcomingApartmentBookings', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading upcoming apartment bookings');
    }
  }

  Future<Map<String, dynamic>> getMyPendingBookings() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/bookings/my-pending'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyPendingBookings', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading pending bookings');
    }
  }

  Future<Map<String, dynamic>> getMyOngoingBookings() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/bookings/my-ongoing'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyOngoingBookings', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading ongoing bookings');
    }
  }

  Future<Map<String, dynamic>> getMyCancelledRejectedBookings() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$apiUrl/bookings/my-cancelled-rejected'), headers: headers).timeout(const Duration(seconds: 30));
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyCancelledRejectedBookings', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading cancelled/rejected bookings');
    }
  }

  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.delete(
        Uri.parse('$apiUrl/bookings/$bookingId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('cancelBooking', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Cancelling booking');
    }
  }

  Future<Map<String, dynamic>> approveBooking(String bookingId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/bookings/$bookingId/approve'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Booking approved',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('approveBooking', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Approving booking');
    }
  }

  Future<Map<String, dynamic>> rejectBooking(String bookingId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/bookings/$bookingId/reject'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Booking rejected',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('rejectBooking', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Rejecting booking');
    }
  }

  Future<Map<String, dynamic>> updateBooking(String bookingId, {
    String? checkIn,
    String? checkOut,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final body = <String, dynamic>{};
      
      if (checkIn != null) body['check_in'] = checkIn;
      if (checkOut != null) body['check_out'] = checkOut;
      if (paymentDetails != null) body['payment_details'] = paymentDetails;
      
      final response = await http.put(
        Uri.parse('$apiUrl/bookings/$bookingId'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('updateBooking', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Updating booking');
    }
  }

  Future<Map<String, dynamic>> approveBookingRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/booking-requests/$requestId/approve'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Booking request approved',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('approveBookingRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Approving booking request');
    }
  }

  Future<Map<String, dynamic>> rejectBookingRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/booking-requests/$requestId/reject'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Booking request rejected',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('rejectBookingRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Rejecting booking request');
    }
  }

  Future<Map<String, dynamic>> checkAvailability({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/bookings/check-availability/$apartmentId?check_in=$checkIn&check_out=$checkOut'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('checkAvailability', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Checking availability');
    }
  }

  Future<Map<String, dynamic>> getApartmentFeatures() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/apartments/features/available'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getApartmentFeatures', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading apartment features');
    }
  }

  Future<Map<String, dynamic>> submitRentalApplication({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
    String? message,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final body = {
        'apartment_id': apartmentId,
        'check_in': checkIn,
        'check_out': checkOut,
        if (message != null && message.isNotEmpty) 'message': message,
      };
      
      final response = await http.post(
        Uri.parse('$apiUrl/rental-applications'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? 'Application submitted successfully',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('submitRentalApplication', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Submitting rental application');
    }
  }

  Future<Map<String, dynamic>> getMyRentalApplications() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/rental-applications/my-applications'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyRentalApplications', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading my rental applications');
    }
  }

  Future<Map<String, dynamic>> getIncomingRentalApplications() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/rental-applications/incoming'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getIncomingRentalApplications', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading incoming rental applications');
    }
  }

  Future<Map<String, dynamic>> getRentalApplicationDetail(String applicationId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/rental-applications/$applicationId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getRentalApplicationDetail', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading rental application details');
    }
  }

  Future<Map<String, dynamic>> approveRentalApplication(String applicationId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/rental-applications/$applicationId/approve'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Application approved successfully',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('approveRentalApplication', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Approving rental application');
    }
  }

  Future<Map<String, dynamic>> rejectRentalApplication(
    String applicationId, {
    String? rejectedReason,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final body = {
        if (rejectedReason != null && rejectedReason.isNotEmpty) 'rejected_reason': rejectedReason,
      };
      
      final response = await http.post(
        Uri.parse('$apiUrl/rental-applications/$applicationId/reject'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Application rejected successfully',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('rejectRentalApplication', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Rejecting rental application');
    }
  }

  Future<Map<String, dynamic>> modifyRentalApplication(
    String applicationId, {
    required String checkIn,
    required String checkOut,
    String? message,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final body = {
        'check_in': checkIn,
        'check_out': checkOut,
        if (message != null && message.isNotEmpty) 'message': message,
      };
      
      final response = await http.post(
        Uri.parse('$apiUrl/rental-applications/$applicationId/modify'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? 'Modification submitted successfully',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('modifyRentalApplication', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Modifying rental application');
    }
  }

  Future<Map<String, dynamic>> getModificationHistory(String applicationId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      final response = await http.get(
        Uri.parse('$apiUrl/rental-applications/$applicationId/modifications'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Modification history retrieved successfully',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('getModificationHistory', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Fetching modification history');
    }
  }

  Future<Map<String, dynamic>> approveModification(
    String applicationId,
    String modificationId,
  ) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      final response = await http.post(
        Uri.parse('$apiUrl/rental-applications/$applicationId/modifications/$modificationId/approve'),
        headers: headers,
        body: json.encode({}),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Modification approved successfully',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('approveModification', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Approving modification');
    }
  }

  Future<Map<String, dynamic>> rejectModification(
    String applicationId,
    String modificationId, {
    String? rejectionReason,
  }) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final body = {
        if (rejectionReason != null && rejectionReason.isNotEmpty) 'rejection_reason': rejectionReason,
      };
      
      final response = await http.post(
        Uri.parse('$apiUrl/rental-applications/$applicationId/modifications/$modificationId/reject'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Modification rejected successfully',
        'data': data['data']
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('rejectModification', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Rejecting modification');
    }
  }

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      final response = await http.get(
        Uri.parse('$apiUrl/wallet'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getWallet', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading wallet');
    }
  }

  Future<Map<String, dynamic>> getWalletTransactions({int page = 1}) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      final response = await http.get(
        Uri.parse('$apiUrl/wallet/transactions?page=$page'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getWalletTransactions', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading wallet transactions');
    }
  }

  Future<Map<String, dynamic>> submitDepositRequest(double amountUsd) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final body = {'amount_usd': amountUsd};
      
      final response = await http.post(
        Uri.parse('$apiUrl/wallet/deposit-request'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('submitDepositRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Submitting deposit request');
    }
  }

  Future<Map<String, dynamic>> submitWithdrawalRequest(double amountUsd) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final body = {'amount_usd': amountUsd};
      
      final response = await http.post(
        Uri.parse('$apiUrl/wallet/withdrawal-request'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('submitWithdrawalRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Submitting withdrawal request');
    }
  }

  Future<Map<String, dynamic>> getMyWalletRequests({int page = 1}) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      final response = await http.get(
        Uri.parse('$apiUrl/wallet/my-requests?page=$page'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getMyWalletRequests', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading wallet requests');
    }
  }

  Future<Map<String, dynamic>> getAdminWalletRequests({int page = 1, String? status}) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      String url = '$apiUrl/admin/deposit-requests?page=$page';
      if (status != null) {
        url += '&status=$status';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getAdminWalletRequests', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading deposit/withdrawal requests');
    }
  }

  Future<Map<String, dynamic>> approveWalletRequest(int requestId) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      
      final response = await http.post(
        Uri.parse('$apiUrl/admin/deposit-requests/$requestId/approve'),
        headers: headers,
        body: json.encode({}),
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('approveWalletRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Approving request');
    }
  }

  Future<Map<String, dynamic>> rejectWalletRequest(int requestId, String reason) async {
    try {
      final headers = await _getHeaders();
      final apiUrl = await AppConfig.baseUrl;
      final body = {'reason': reason};
      
      final response = await http.post(
        Uri.parse('$apiUrl/admin/deposit-requests/$requestId/reject'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('rejectWalletRequest', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Rejecting request');
    }
  }

  Future<Map<String, dynamic>> getBookedDates(String apartmentId) async {
    try {
      final apiUrl = await AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/apartments/$apartmentId/booked-dates'),
      ).timeout(const Duration(seconds: 30));
      
      return json.decode(response.body);
    } catch (e, stackTrace) {
      ErrorHandler.logError('getBookedDates', e, stackTrace);
      return ErrorHandler.handleApiError(e, operation: 'Loading booked dates');
    }
  }
}
