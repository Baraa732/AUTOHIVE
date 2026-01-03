# Booking System - Date-Based Availability

## Problem Statement
Previously, when an apartment received a confirmed booking, it was marked as permanently unavailable (`is_available = false`), causing it to disappear from the home page and search results. This prevented users from booking the apartment for other available dates.

## Solution
Implemented a **date-based availability system** where:
- Apartments are always visible on the home page
- Users can only book dates that don't conflict with existing confirmed bookings
- The calendar automatically disables booked dates when users try to select check-in/check-out dates

## Changes Made

### Backend Changes

#### 1. **ApartmentController.php** - Removed `is_available` Filter
**File**: `server/app/Http/Controllers/Api/ApartmentController.php`

**Before**:
```php
$query = Apartment::with(['user', 'reviews'])
    ->where('is_available', true)  // ❌ This hid apartments with bookings
    ->where('is_approved', true)
    ->where('status', 'approved');
```

**After**:
```php
$query = Apartment::with(['user', 'reviews'])
    ->where('is_approved', true)  // ✅ Only check approval status
    ->where('status', 'approved');
```

#### 2. **BookingController.php** - Removed Availability Toggle Logic

**Changes**:
- Removed `is_available = false` when booking is approved
- Removed `is_available = true` when booking is rejected/cancelled
- Removed `is_available` check when creating bookings

**Before** (approve method):
```php
$booking->update(['status' => Booking::STATUS_CONFIRMED]);
$booking->apartment->update(['is_available' => false]); // ❌ Made apartment permanently unavailable
```

**After** (approve method):
```php
$booking->update(['status' => Booking::STATUS_CONFIRMED]);
// ✅ No availability toggle - apartment stays visible
```

#### 3. **New Controller**: `ApartmentAvailabilityController.php`
**File**: `server/app/Http/Controllers/Api/ApartmentAvailabilityController.php`

```php
public function getBookedDates($apartmentId)
{
    $bookedDates = Booking::where('apartment_id', $apartmentId)
        ->where('status', Booking::STATUS_CONFIRMED)
        ->select(['check_in', 'check_out'])
        ->get();
    
    return response()->json([
        'success' => true,
        'data' => $bookedDates
    ]);
}
```

#### 4. **New API Route**
**File**: `server/routes/api.php`

```php
Route::get('/apartments/{id}/booked-dates', [ApartmentAvailabilityController::class, 'getBookedDates']);
```

### Frontend Changes

#### 1. **ApiService.dart** - New Method
**File**: `client/lib/core/network/api_service.dart`

```dart
Future<Map<String, dynamic>> getBookedDates(String apartmentId) async {
  final apiUrl = await AppConfig.baseUrl;
  final response = await http.get(
    Uri.parse('$apiUrl/apartments/$apartmentId/booked-dates'),
  );
  return json.decode(response.body);
}
```

#### 2. **CreateBookingScreen.dart** - Date Picker Enhancement
**File**: `client/lib/presentation/screens/shared/create_booking_screen.dart`

**Added**:
- `_bookedRanges` list to store confirmed booking periods
- `initState()` to load booked dates when screen opens
- `_loadBookedDates()` to fetch booked dates from API
- `_isDateBooked()` to check if a specific date is booked
- `selectableDayPredicate` in date pickers to disable booked dates

```dart
Future<void> _selectCheckInDate() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    selectableDayPredicate: (DateTime date) {
      return !_isDateBooked(date); // ✅ Disable booked dates
    },
    // ... other parameters
  );
}
```

## How It Works

### 1. **Apartment Listing**
- All approved apartments appear on the home page
- No filtering based on `is_available` flag
- Users can view and click on any apartment

### 2. **Booking Screen**
When a user opens the booking screen:
1. App fetches all confirmed bookings for that apartment
2. Booked date ranges are stored in `_bookedRanges`
3. When user taps to select dates, the calendar appears
4. Booked dates are grayed out and unselectable

### 3. **Date Selection**
- Users can only select dates that don't overlap with confirmed bookings
- Check-in and check-out dates are validated against booked ranges
- Visual feedback shows which dates are unavailable

### 4. **Booking Submission**
- User submits booking request with selected dates
- Backend validates dates are still available (prevents race conditions)
- If dates conflict with a confirmed booking, request is rejected
- If dates are available, booking is created with "pending" status

### 5. **Booking Approval**
- Landlord reviews pending booking requests
- When approved:
  - Booking status changes to "confirmed"
  - Payment is processed from tenant's wallet
  - Other pending bookings with overlapping dates are auto-rejected
  - **Apartment remains visible** for other dates

## Key Features

✅ **Always Visible**: Apartments never disappear from listings
✅ **Date-Based Blocking**: Only specific dates are blocked, not the entire apartment
✅ **Visual Feedback**: Booked dates appear disabled in calendar
✅ **Multiple Bookings**: Same apartment can have multiple bookings for different periods
✅ **Real-Time Validation**: Backend validates availability when booking is submitted
✅ **Automatic Rejection**: Overlapping pending bookings are auto-rejected when one is confirmed

## Database Schema

The `is_available` field in the `apartments` table is now used for:
- Manual availability toggle by landlord (e.g., for maintenance)
- NOT automatically set by the booking system

## API Endpoints

### Get Booked Dates
```
GET /api/apartments/{apartmentId}/booked-dates
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "check_in": "2025-02-01",
      "check_out": "2025-02-05"
    },
    {
      "check_in": "2025-02-10",
      "check_out": "2025-02-15"
    }
  ]
}
```

## Testing Scenarios

### Scenario 1: Multiple Bookings
1. User A books Apartment X for Feb 1-5 (confirmed)
2. Apartment X still appears on home page
3. User B opens booking screen for Apartment X
4. Feb 1-5 are disabled in calendar
5. User B books Feb 6-10 successfully

### Scenario 2: Overlapping Requests
1. User A requests Feb 1-5 (pending)
2. User B requests Feb 3-7 (pending)
3. Landlord approves User A's request
4. User B's request is automatically rejected (overlapping dates)

### Scenario 3: Gaps Between Bookings
1. Apartment has bookings: Feb 1-5 and Feb 10-15
2. User can book Feb 6-9 (gap between bookings)
3. User can book Feb 16+ (after last booking)

## Benefits

1. **Better User Experience**: Users can see all apartments and available dates
2. **Higher Booking Rate**: Apartments don't disappear after first booking
3. **Flexible Scheduling**: Multiple bookings for different periods
4. **Clear Availability**: Visual calendar shows exactly which dates are available
5. **Prevents Conflicts**: System automatically prevents double-booking

## Migration Notes

If you have existing apartments with `is_available = false` due to bookings:

```sql
-- Reset all apartments to available (optional)
UPDATE apartments SET is_available = true WHERE is_approved = true;
```

## Future Enhancements

1. **Calendar View**: Full month calendar showing all booked dates
2. **Price Calendar**: Different prices for different dates/seasons
3. **Minimum Stay**: Enforce minimum number of nights
4. **Instant Booking**: Skip landlord approval for certain dates
5. **Cleaning Buffer**: Automatic buffer days between bookings
6. **Recurring Bookings**: Support for weekly/monthly rentals
