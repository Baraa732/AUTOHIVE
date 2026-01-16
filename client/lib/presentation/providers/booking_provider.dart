import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking.dart';
import '../../core/network/api_service.dart';

class BookingState {
  final List<Booking> bookings;
  final List<Booking> apartmentBookings;
  final List<Map<String, dynamic>> bookingRequests;
  // Categorized bookings
  final List<Booking> upcomingApartmentBookings; // Bookings on user's apartments (from others)
  final List<Booking> myPendingBookings; // Bookings created by user that are pending
  final List<Booking> myOngoingBookings; // Bookings created by user that are confirmed and ongoing
  final List<Booking> myCancelledRejectedBookings; // Bookings created by user that are cancelled/rejected
  final String? error;
  final String? successMessage;

  const BookingState({
    this.bookings = const [],
    this.apartmentBookings = const [],
    this.bookingRequests = const [],
    this.upcomingApartmentBookings = const [],
    this.myPendingBookings = const [],
    this.myOngoingBookings = const [],
    this.myCancelledRejectedBookings = const [],
    this.error,
    this.successMessage,
  });

  BookingState copyWith({
    List<Booking>? bookings,
    List<Booking>? apartmentBookings,
    List<Map<String, dynamic>>? bookingRequests,
    List<Booking>? upcomingApartmentBookings,
    List<Booking>? myPendingBookings,
    List<Booking>? myOngoingBookings,
    List<Booking>? myCancelledRejectedBookings,
    String? error,
    String? successMessage,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      apartmentBookings: apartmentBookings ?? this.apartmentBookings,
      bookingRequests: bookingRequests ?? this.bookingRequests,
      upcomingApartmentBookings: upcomingApartmentBookings ?? this.upcomingApartmentBookings,
      myPendingBookings: myPendingBookings ?? this.myPendingBookings,
      myOngoingBookings: myOngoingBookings ?? this.myOngoingBookings,
      myCancelledRejectedBookings: myCancelledRejectedBookings ?? this.myCancelledRejectedBookings,
      error: error,
      successMessage: successMessage,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final ApiService _apiService;

  BookingNotifier(this._apiService) : super(const BookingState());

  Future<void> loadMyBookings() async {
    try {
      final result = await _apiService.getMyBookings();
      
      List<Booking> bookingList = [];
      
      if (result['success'] == true) {
        final data = result['data'];
        
        if (data is List) {
          bookingList = (data as List)
              .map((json) {
                try {
                  return Booking.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        } else if (data is Map) {
          final dataList = data['data'];
          if (dataList is List) {
            bookingList = (dataList as List)
                .map((json) {
                  try {
                    return Booking.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<Booking>()
                .toList();
          }
        }
        
        state = state.copyWith(
          bookings: bookingList,
        );
      } else {
        state = state.copyWith(
          bookings: [],
        );
      }
    } catch (e) {
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
    try {
      final result = await _apiService.getMyApartmentBookings();
      
      List<Booking> bookingList = [];
      
      if (result['success'] == true) {
        final data = result['data'];
        
        if (data is List) {
          bookingList = (data as List)
              .map((json) {
                try {
                  return Booking.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        } else if (data is Map) {
          final dataList = data['data'];
          if (dataList is List) {
            bookingList = (dataList as List)
                .map((json) {
                  try {
                    return Booking.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<Booking>()
                .toList();
          }
        }
        
        state = state.copyWith(
          apartmentBookings: bookingList,
        );
      } else {
        state = state.copyWith(
          apartmentBookings: [],
        );
      }
    } catch (e) {
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

  Future<void> loadUpcomingApartmentBookings() async {
    try {
      print('📱 Loading upcoming apartment bookings...');
      final result = await _apiService.getUpcomingApartmentBookings();
      print('📡 API Response: $result');
      
      List<Booking> bookingList = [];
      
      if (result['success'] == true) {
        final data = result['data'];
        print('📦 Data type: ${data.runtimeType}');
        print('📦 Data: $data');
        
        if (data is List) {
          print('✅ Data is List with ${data.length} items');
          bookingList = (data as List)
              .map((json) {
                try {
                  return Booking.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('❌ Error parsing booking: $e');
                  print('📋 JSON: $json');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        } else if (data is Map) {
          final dataList = data['data'];
          print('✅ Data is Map, dataList type: ${dataList.runtimeType}');
          if (dataList is List) {
            print('✅ DataList is List with ${dataList.length} items');
            bookingList = (dataList as List)
                .map((json) {
                  try {
                    return Booking.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    print('❌ Error parsing booking: $e');
                    print('📋 JSON: $json');
                    return null;
                  }
                })
                .whereType<Booking>()
                .toList();
          } else {
            print('⚠️ DataList is not a List: $dataList');
          }
        } else {
          print('⚠️ Data is neither List nor Map: ${data.runtimeType}');
        }
        
        print('✅ Parsed ${bookingList.length} bookings');
        state = state.copyWith(
          upcomingApartmentBookings: bookingList,
        );
      } else {
        print('❌ API returned success=false: ${result['message']}');
        state = state.copyWith(
          upcomingApartmentBookings: [],
          error: result['message'] ?? 'Failed to load upcoming apartment bookings',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exception in loadUpcomingApartmentBookings: $e');
      print('📋 StackTrace: $stackTrace');
      state = state.copyWith(
        upcomingApartmentBookings: [],
        error: e.toString(),
      );
    }
  }

  Future<void> loadMyPendingBookings() async {
    try {
      print('📱 Loading my pending bookings...');
      final result = await _apiService.getMyPendingBookings();
      print('📡 API Response: $result');
      
      List<Booking> bookingList = [];
      
      if (result['success'] == true) {
        final data = result['data'];
        print('📦 Data type: ${data.runtimeType}');
        
        if (data is List) {
          print('✅ Data is List with ${data.length} items');
          bookingList = (data as List)
              .map((json) {
                try {
                  return Booking.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('❌ Error parsing booking: $e');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        } else if (data is Map) {
          final dataList = data['data'];
          print('✅ Data is Map, dataList type: ${dataList.runtimeType}');
          if (dataList is List) {
            print('✅ DataList is List with ${dataList.length} items');
            bookingList = (dataList as List)
                .map((json) {
                  try {
                    return Booking.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    print('❌ Error parsing booking: $e');
                    return null;
                  }
                })
                .whereType<Booking>()
                .toList();
          } else {
            print('⚠️ DataList is not a List: $dataList');
          }
        } else {
          print('⚠️ Data is neither List nor Map: ${data.runtimeType}');
        }
        
        print('✅ Parsed ${bookingList.length} bookings');
        state = state.copyWith(
          myPendingBookings: bookingList,
        );
      } else {
        print('❌ API returned success=false: ${result['message']}');
        state = state.copyWith(
          myPendingBookings: [],
          error: result['message'] ?? 'Failed to load pending bookings',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exception in loadMyPendingBookings: $e');
      print('📋 StackTrace: $stackTrace');
      state = state.copyWith(
        myPendingBookings: [],
        error: e.toString(),
      );
    }
  }

  Future<void> loadMyOngoingBookings() async {
    try {
      print('📱 Loading my ongoing bookings...');
      final result = await _apiService.getMyOngoingBookings();
      print('📡 API Response: $result');
      
      List<Booking> bookingList = [];
      
      if (result['success'] == true) {
        final data = result['data'];
        print('📦 Data type: ${data.runtimeType}');
        
        if (data is List) {
          print('✅ Data is List with ${data.length} items');
          bookingList = (data as List)
              .map((json) {
                try {
                  return Booking.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('❌ Error parsing booking: $e');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        } else if (data is Map) {
          final dataList = data['data'];
          print('✅ Data is Map, dataList type: ${dataList.runtimeType}');
          if (dataList is List) {
            print('✅ DataList is List with ${dataList.length} items');
            bookingList = (dataList as List)
                .map((json) {
                  try {
                    return Booking.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    print('❌ Error parsing booking: $e');
                    return null;
                  }
                })
                .whereType<Booking>()
                .toList();
          } else {
            print('⚠️ DataList is not a List: $dataList');
          }
        } else {
          print('⚠️ Data is neither List nor Map: ${data.runtimeType}');
        }
        
        print('✅ Parsed ${bookingList.length} bookings');
        state = state.copyWith(
          myOngoingBookings: bookingList,
        );
      } else {
        print('❌ API returned success=false: ${result['message']}');
        state = state.copyWith(
          myOngoingBookings: [],
          error: result['message'] ?? 'Failed to load ongoing bookings',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exception in loadMyOngoingBookings: $e');
      print('📋 StackTrace: $stackTrace');
      state = state.copyWith(
        myOngoingBookings: [],
        error: e.toString(),
      );
    }
  }

  Future<void> loadMyCancelledRejectedBookings() async {
    try {
      print('📱 Loading cancelled/rejected bookings...');
      final result = await _apiService.getMyCancelledRejectedBookings();
      print('📡 API Response: $result');
      
      List<Booking> bookingList = [];
      
      if (result['success'] == true) {
        final data = result['data'];
        print('📦 Data type: ${data.runtimeType}');
        
        if (data is List) {
          print('✅ Data is List with ${data.length} items');
          bookingList = (data as List)
              .map((json) {
                try {
                  return Booking.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('❌ Error parsing booking: $e');
                  return null;
                }
              })
              .whereType<Booking>()
              .toList();
        } else if (data is Map) {
          final dataList = data['data'];
          print('✅ Data is Map, dataList type: ${dataList.runtimeType}');
          if (dataList is List) {
            print('✅ DataList is List with ${dataList.length} items');
            bookingList = (dataList as List)
                .map((json) {
                  try {
                    return Booking.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    print('❌ Error parsing booking: $e');
                    return null;
                  }
                })
                .whereType<Booking>()
                .toList();
          } else {
            print('⚠️ DataList is not a List: $dataList');
          }
        } else {
          print('⚠️ Data is neither List nor Map: ${data.runtimeType}');
        }
        
        print('✅ Parsed ${bookingList.length} bookings');
        state = state.copyWith(
          myCancelledRejectedBookings: bookingList,
        );
      } else {
        print('❌ API returned success=false: ${result['message']}');
        state = state.copyWith(
          myCancelledRejectedBookings: [],
          error: result['message'] ?? 'Failed to load cancelled/rejected bookings',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exception in loadMyCancelledRejectedBookings: $e');
      print('📋 StackTrace: $stackTrace');
      state = state.copyWith(
        myCancelledRejectedBookings: [],
        error: e.toString(),
      );
    }
  }

  Future<void> loadAllCategorizedBookings() async {
    await Future.wait([
      loadUpcomingApartmentBookings(),
      loadMyPendingBookings(),
      loadMyOngoingBookings(),
      loadMyCancelledRejectedBookings(),
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
        await loadAllCategorizedBookings();
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

  Future<bool> approveBooking(String bookingId) async {
    try {
      final result = await _apiService.approveBooking(bookingId);
      
      if (result['success'] == true) {
        state = state.copyWith(
          successMessage: result['message'] ?? 'Booking approved successfully',
        );
        await loadAllCategorizedBookings();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to approve booking',
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

  Future<bool> rejectBooking(String bookingId) async {
    try {
      final result = await _apiService.rejectBooking(bookingId);
      
      if (result['success'] == true) {
        state = state.copyWith(
          successMessage: result['message'] ?? 'Booking rejected successfully',
        );
        await loadAllCategorizedBookings();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to reject booking',
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

  Future<bool> updateBooking(String bookingId, {
    String? checkIn,
    String? checkOut,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final result = await _apiService.updateBooking(
        bookingId,
        checkIn: checkIn,
        checkOut: checkOut,
        paymentDetails: paymentDetails,
      );
      
      if (result['success'] == true) {
        state = state.copyWith(
          successMessage: result['message'] ?? 'Booking updated successfully',
        );
        await loadAllCategorizedBookings();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to update booking',
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

  Future<bool> deleteBooking(String bookingId) async {
    try {
      final result = await _apiService.cancelBooking(bookingId);
      
      if (result['success'] == true) {
        state = state.copyWith(
          successMessage: result['message'] ?? 'Booking deleted successfully',
        );
        await loadAllCategorizedBookings();
        return true;
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to delete booking',
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
