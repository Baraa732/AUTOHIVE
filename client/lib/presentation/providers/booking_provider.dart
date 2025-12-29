import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking.dart';
import '../../core/network/api_service.dart';

class BookingState {
  final List<Booking> bookings;
  final List<Booking> apartmentBookings;
  final List<Map<String, dynamic>> bookingRequests;
  final String? error;
  final String? successMessage;

  const BookingState({
    this.bookings = const [],
    this.apartmentBookings = const [],
    this.bookingRequests = const [],
    this.error,
    this.successMessage,
  });

  BookingState copyWith({
    List<Booking>? bookings,
    List<Booking>? apartmentBookings,
    List<Map<String, dynamic>>? bookingRequests,
    String? error,
    String? successMessage,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      apartmentBookings: apartmentBookings ?? this.apartmentBookings,
      bookingRequests: bookingRequests ?? this.bookingRequests,
      error: error,
      successMessage: successMessage,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final ApiService _apiService;

  BookingNotifier(this._apiService) : super(const BookingState());

  Future<void> loadMyBookings() async {
    print('  📱 loadMyBookings API call started');
    try {
      final result = await _apiService.getMyBookings();
      print('  📡 API response received');
      print('  Full Response: $result');
      
      List<Booking> bookingList = [];
      
      if (result['success'] == true) {
        final data = result['data'];
        print('  🔍 Data type: ${data.runtimeType}');
        
        if (data is List) {
          print('  ➡️ Data is a List');
          bookingList = (data as List)
              .map((json) {
                try {
                  return Booking.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('  ⚠️ Error parsing booking: $e');
                  print('  JSON data: $json');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        } else if (data is Map) {
          final dataList = data['data'];
          if (dataList is List) {
            print('  ➡️ Data is a paginated Map');
            bookingList = (dataList as List)
                .map((json) {
                  try {
                    return Booking.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    print('  ⚠️ Error parsing booking: $e');
                    print('  JSON data: $json');
                    return null;
                  }
                })
                .whereType<Booking>()
                .toList();
          }
        }
        
        print('  ✅ Loaded ${bookingList.length} user bookings');
        state = state.copyWith(
          bookings: bookingList,
        );
      } else {
        final errorMsg = result['message'] ?? result.toString();
        print('  ⚠️ API error in loadMyBookings: $errorMsg');
        print('  Success field: ${result['success']}');
        state = state.copyWith(
          bookings: [],
        );
      }
    } catch (e, stackTrace) {
      print('  ❌ Exception in loadMyBookings: $e');
      print('  Stack: $stackTrace');
      state = state.copyWith(
        bookings: [],
      );
    }
  }

  Future<void> loadMyBookingRequests() async {
    try {
      final result = await _apiService.getMyBookingRequests();
      
      if (result['success'] == true) {
        final requestList = (result['data'] as List?)
            ?.cast<Map<String, dynamic>>() ?? [];
        
        state = state.copyWith(
          bookingRequests: requestList,
          error: null,
        );
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load booking requests',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  Future<bool> createBookingRequest({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
    required int guests,
    String? message,
  }) async {
    try {
      final result = await _apiService.createBookingRequest(
        apartmentId: apartmentId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        message: message,
      );
      
      if (result['success'] == true) {
        state = state.copyWith(
          successMessage: result['message'] ?? 'Booking request sent successfully',
        );
        await loadMyBookingRequests();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to create booking request',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> checkAvailability({
    required String apartmentId,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      return await _apiService.checkAvailability(
        apartmentId: apartmentId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }

  Future<void> loadMyApartmentBookings() async {
    print('  📱 loadMyApartmentBookings API call started');
    try {
      final result = await _apiService.getMyApartmentBookings();
      print('  📡 API response received');
      print('  Full Response: $result');
      
      List<Booking> bookingList = [];
      
      if (result['success'] == true) {
        final data = result['data'];
        print('  🔍 Data type: ${data.runtimeType}');
        
        if (data is List) {
          print('  ➡️ Data is a List');
          bookingList = (data as List)
              .map((json) {
                try {
                  return Booking.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('  ⚠️ Error parsing booking: $e');
                  print('  JSON data: $json');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        } else if (data is Map) {
          final dataList = data['data'];
          if (dataList is List) {
            print('  ➡️ Data is a paginated Map');
            bookingList = (dataList as List)
                .map((json) {
                  try {
                    return Booking.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    print('  ⚠️ Error parsing booking: $e');
                    print('  JSON data: $json');
                    return null;
                  }
                })
                .whereType<Booking>()
                .toList();
          }
        }
        
        print('  ✅ Loaded ${bookingList.length} apartment bookings');
        state = state.copyWith(
          apartmentBookings: bookingList,
        );
      } else {
        final errorMsg = result['message'] ?? result.toString();
        print('  ⚠️ API error in loadMyApartmentBookings: $errorMsg');
        print('  Success field: ${result['success']}');
        state = state.copyWith(
          apartmentBookings: [],
        );
      }
    } catch (e, stackTrace) {
      print('  ❌ Exception in loadMyApartmentBookings: $e');
      print('  Stack: $stackTrace');
      state = state.copyWith(
        apartmentBookings: [],
      );
    }
  }

  Future<void> loadAllBookingsData() async {
    await Future.wait([
      loadMyBookings(),
      loadMyApartmentBookings(),
    ], eagerError: false);
  }

  Future<void> loadApartmentBookingRequests() async {
    try {
      final result = await _apiService.getApartmentBookingRequests();
      
      if (result['success'] == true) {
        final requestList = (result['data'] as List?)
            ?.cast<Map<String, dynamic>>() ?? [];
        
        state = state.copyWith(
          bookingRequests: requestList,
        );
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load booking requests',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  Future<bool> approveBookingRequest(String requestId) async {
    try {
      final result = await _apiService.approveBookingRequest(requestId);
      
      if (result['success'] == true) {
        state = state.copyWith(
          successMessage: result['message'] ?? 'Booking request approved',
        );
        await loadApartmentBookingRequests();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to approve booking request',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> rejectBookingRequest(String requestId) async {
    try {
      final result = await _apiService.rejectBookingRequest(requestId);
      
      if (result['success'] == true) {
        state = state.copyWith(
          successMessage: result['message'] ?? 'Booking request rejected',
        );
        await loadApartmentBookingRequests();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to reject booking request',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      final result = await _apiService.cancelBooking(bookingId);
      
      if (result['success'] == true) {
        state = state.copyWith(
          successMessage: result['message'] ?? 'Booking cancelled successfully',
        );
        await loadMyBookings();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to cancel booking',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      return false;
    }
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ApiService());
});