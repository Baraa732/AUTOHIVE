# Technical Specification: Bookings Management System

## Technical Context
- **Language**: PHP 8+ (Backend - Laravel 10), Dart (Frontend - Flutter)
- **Database**: MySQL
- **API Format**: REST JSON
- **State Management**: Riverpod (Flutter)
- **HTTP Client**: http package (Flutter)
- **Authentication**: Sanctum with Bearer tokens

## Technical Implementation Brief

The bookings feature requires completing two main data flows:

1. **MyBookings Flow** (Tenant's booking requests on other apartments):
   - Backend: `BookingController@index()` - returns Bookings where user_id matches current user
   - Frontend: `getMyBookings()` in ApiService → maps to Booking model
   - Provider: `bookingProvider` stores in `bookings` list

2. **MyApartmentBookings Flow** (House owner's received bookings):
   - Backend: `BookingController@myApartmentBookings()` - returns Bookings for user's apartments
   - Frontend: `getMyApartmentBookings()` in ApiService → maps to Booking model  
   - Provider: `bookingProvider` stores in `apartmentBookings` list

Both endpoints need to:
- Eager load relationships (apartment with user, user details)
- Return paginated results with proper structure
- Handle authentication via Sanctum

## Source Code Structure

### Backend:
- `server/app/Http/Controllers/Api/BookingController.php` - Main booking logic
- `server/app/Http/Controllers/Api/BookingRequestController.php` - Booking request approval/rejection
- `server/app/Models/Booking.php` - Booking model with relationships
- `server/app/Models/BookingRequest.php` - BookingRequest model
- `server/app/Models/Apartment.php` - Apartment model
- `server/routes/api.php` - API route definitions

### Frontend:
- `client/lib/presentation/screens/shared/bookings_screen.dart` - Main UI screen
- `client/lib/presentation/providers/booking_provider.dart` - State management
- `client/lib/core/network/api_service.dart` - API calls
- `client/lib/data/models/booking.dart` - Booking data model

## Contracts

### Backend API Endpoints:

#### 1. GET /bookings
**Purpose**: Get current user's booking requests on other apartments
**Middleware**: auth:sanctum
**Response**:
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 2,
        "apartment_id": 5,
        "check_in": "2025-01-15",
        "check_out": "2025-01-20",
        "total_price": "250.00",
        "status": "pending|approved|confirmed|rejected",
        "created_at": "2025-01-01T10:00:00Z",
        "apartment": {
          "id": 5,
          "title": "Luxury Apartment",
          "user_id": 1,
          "user": {
            "id": 1,
            "name": "John Owner",
            "profile_image": "url"
          }
        },
        "user": {
          "id": 2,
          "name": "Tenant Name",
          "profile_image": "url"
        }
      }
    ],
    "current_page": 1,
    "per_page": 20,
    "total": 10
  },
  "message": "Bookings retrieved successfully"
}
```

#### 2. GET /my-apartment-bookings
**Purpose**: Get bookings received for user's apartments
**Middleware**: auth:sanctum
**Response**: Same structure as /bookings but filtered for user's apartments

#### 3. GET /my-booking-requests (BookingRequest endpoints)
**Purpose**: Get BookingRequest records (pending requests for user to make)
**Note**: This is different from Bookings - these are unapproved requests

### Database Schema (Already exists):

**bookings table**:
- id, user_id, apartment_id, check_in, check_out, total_price, status, booking_request_id, created_at, updated_at

**booking_requests table**:
- id, user_id, apartment_id, check_in, check_out, guests, total_price, message, status, created_at, updated_at

### Frontend Data Model:

**Booking model** (client/lib/data/models/booking.dart):
```dart
class Booking {
  final String id;
  final String userId;
  final String apartmentId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String totalPrice;
  final String status;
  final Map<String, dynamic>? apartment;
  final Map<String, dynamic>? user;
}
```

## Delivery Phases

### Phase 1: Backend API Completion
**Objective**: Ensure backend endpoints return correct data with all required relationships

**Tasks**:
1. Verify `BookingController@index()` returns paginated Bookings for current user with relationships
2. Verify `BookingController@myApartmentBookings()` exists and returns correct data
3. Ensure both endpoints eager-load apartment.user and user relationships
4. Test endpoints with actual data using Postman/API testing tool

**Verification**: API returns correct structure with nested relationships

### Phase 2: Frontend API Integration
**Objective**: Ensure frontend API service correctly calls backend and parses responses

**Tasks**:
1. Verify `ApiService.getMyBookings()` calls correct endpoint
2. Verify `ApiService.getMyApartmentBookings()` calls correct endpoint
3. Ensure response parsing handles pagination structure correctly
4. Add proper error handling for both endpoints

**Verification**: Console logs show API calls succeeding and data being received

### Phase 3: Frontend State Management
**Objective**: Ensure booking_provider correctly manages state for both tabs

**Tasks**:
1. Fix `loadMyBookings()` to properly parse paginated response
2. Fix `loadMyApartmentBookings()` to properly parse paginated response
3. Ensure `loadAllBookingsData()` waits for both APIs before setting isLoading=false
4. Fix Booking model mapping to handle nested relationships

**Verification**: Provider correctly loads both lists without hanging loading state

### Phase 4: UI/UX Polish
**Objective**: Ensure screen displays data beautifully without showing loading indefinitely

**Tasks**:
1. Verify bookings_screen properly displays both tabs
2. Fix status badge colors and formatting
3. Implement empty states for both tabs
4. Test pull-to-refresh functionality
5. Test error state display with retry button

**Verification**: Screen shows data correctly, no infinite loading, proper error handling

## Verification Strategy

### Phase 1 (Backend) Verification:
```bash
# Test with curl or Postman:
curl -H "Authorization: Bearer {token}" http://localhost:8000/api/bookings
curl -H "Authorization: Bearer {token}" http://localhost:8000/api/my-apartment-bookings
```

Expected: Returns JSON with proper structure including nested relationships

### Phase 2 (API Integration) Verification:
- Check Flutter console logs for HTTP requests/responses
- Use network inspection tools in Flutter DevTools
- Verify response is being parsed without errors

### Phase 3 (State Management) Verification:
- Check provider logs showing successful data loading
- Verify `bookingProvider` state contains data after loading
- Ensure isLoading=false after both APIs complete

### Phase 4 (UI) Verification:
- Run app and navigate to bookings screen
- Verify both tabs display data
- Pull to refresh and verify data reloads
- Check error handling by disconnecting network
- Verify empty states show when no data

### Helper Scripts:
A database helper script can be created to:
1. Create test bookings with proper relationships
2. Verify data structure in database
3. Check if relationships are properly set up

## Success Metrics

1. ✅ API endpoints return data in expected format
2. ✅ Frontend successfully calls APIs without errors
3. ✅ Provider state contains booking data
4. ✅ Screen displays bookings without loading indefinitely
5. ✅ Both tabs work correctly with proper empty states
6. ✅ Pull-to-refresh reloads data
7. ✅ Error states display and can be retried
