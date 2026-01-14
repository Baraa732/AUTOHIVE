# Booking Date Blocking Implementation

## Overview
This document describes the implementation of the booking date blocking feature that prevents users from selecting dates that are already booked for an apartment.

## Problem Statement
Users were able to select and request booking dates that were already confirmed for an apartment, leading to potential conflicts. The calendar date picker needed to:
1. Disable dates that are already booked (confirmed bookings)
2. Show visual feedback about unavailable dates
3. Prevent submission of conflicting date ranges

## Solution Architecture

### Backend Changes

#### 1. ApartmentAvailabilityController (`server/app/Http/Controllers/Api/ApartmentAvailabilityController.php`)
- **Endpoint**: `GET /api/apartments/{id}/booked-dates`
- **Purpose**: Returns all confirmed booking dates for a specific apartment
- **Logic**: 
  - Only returns bookings with `STATUS_CONFIRMED` status
  - Pending bookings are NOT included to allow multiple users to request the same dates
  - The apartment owner will choose which pending request to approve
  - Returns date ranges in `YYYY-MM-DD` format

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

#### 2. BookingController Validation
The `requestBooking` method already includes:
- Conflict detection for confirmed bookings
- Wallet balance validation
- Duplicate request prevention
- Auto-rejection of overlapping pending requests when one is approved

### Frontend Changes

#### 1. Create Booking Screen (`client/lib/presentation/screens/shared/create_booking_screen.dart`)

**Key Features Implemented:**

##### A. Load Booked Dates on Screen Init
```dart
@override
void initState() {
  super.initState();
  _loadBookedDates();
}

Future<void> _loadBookedDates() async {
  final result = await apiService.getBookedDates(apartmentId);
  if (result['success'] == true) {
    setState(() {
      _bookedRanges = result['data'].map((booking) {
        return DateTimeRange(
          start: DateTime.parse(booking['check_in']),
          end: DateTime.parse(booking['check_out']),
        );
      }).toList();
    });
  }
}
```

##### B. Date Checking Logic
```dart
bool _isDateBooked(DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  
  for (var range in _bookedRanges) {
    final rangeStart = DateTime(range.start.year, range.start.month, range.start.day);
    final rangeEnd = DateTime(range.end.year, range.end.month, range.end.day);
    
    // Check if date falls within any booked range
    if ((normalizedDate.isAfter(rangeStart.subtract(const Duration(days: 1))) && 
         normalizedDate.isBefore(rangeEnd)) ||
        normalizedDate.isAtSameMomentAs(rangeStart)) {
      return true;
    }
  }
  return false;
}

bool _isRangeAvailable(DateTime checkIn, DateTime checkOut) {
  DateTime currentDate = checkIn;
  while (currentDate.isBefore(checkOut)) {
    if (_isDateBooked(currentDate)) {
      return false;
    }
    currentDate = currentDate.add(const Duration(days: 1));
  }
  return true;
}
```

##### C. Smart Initial Date Selection
The date picker now finds the first available date instead of defaulting to tomorrow:

```dart
Future<void> _selectCheckInDate() async {
  // Find the first available date starting from tomorrow
  DateTime initialDate = DateTime.now().add(const Duration(days: 1));
  while (_isDateBooked(initialDate) && 
         initialDate.isBefore(DateTime.now().add(const Duration(days: 365)))) {
    initialDate = initialDate.add(const Duration(days: 1));
  }

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    selectableDayPredicate: (DateTime date) {
      return !_isDateBooked(date);
    },
  );
}
```

##### D. Visual Feedback
Added an info banner when there are booked dates:

```dart
if (_bookedRanges.isNotEmpty) {
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Colors.blue),
        Text('Some dates are already booked and cannot be selected'),
      ],
    ),
  ),
}
```

##### E. Pre-Submission Validation
Before submitting the booking request:

```dart
if (!_isRangeAvailable(_checkInDate!, _checkOutDate!)) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Selected dates are no longer available. Please choose different dates.'),
      backgroundColor: Colors.red,
    ),
  );
  await _loadBookedDates(); // Refresh booked dates
  setState(() {
    _checkInDate = null;
    _checkOutDate = null;
  });
  return;
}
```

## User Experience Flow

1. **User opens booking screen**
   - System loads all confirmed bookings for the apartment
   - Booked dates are stored in memory

2. **User clicks "Select Check-in Date"**
   - Calendar opens with the first available date selected
   - All booked dates appear disabled/grayed out
   - User can only tap on available dates

3. **User selects check-in date**
   - System validates the date is available
   - User proceeds to select check-out date

4. **User clicks "Select Check-out Date"**
   - Calendar opens starting from day after check-in
   - Only available dates can be selected
   - Ensures no overlap with existing bookings

5. **User submits booking request**
   - System validates the entire date range is still available
   - If dates became unavailable, user is notified and dates are reset
   - If available, booking request is created with PENDING status

6. **Owner approves booking**
   - Booking status changes to CONFIRMED
   - Payment is processed from tenant's wallet
   - Other pending requests for overlapping dates are auto-rejected
   - Apartment becomes unavailable for those dates

## Booking Status Flow

```
PENDING → CONFIRMED → COMPLETED
   ↓
REJECTED

CONFIRMED → CANCELLED
```

- **PENDING**: Initial state when user requests booking
- **CONFIRMED**: Owner approved and payment processed
- **REJECTED**: Owner declined the request
- **CANCELLED**: User or owner cancelled after confirmation
- **COMPLETED**: Booking period has ended (auto-updated by scheduled task)

## Key Design Decisions

### 1. Why Only Block CONFIRMED Bookings?
- Allows multiple users to request the same dates
- Owner has flexibility to choose the best tenant
- Prevents "first come, first served" issues
- When one request is approved, others are auto-rejected

### 2. Why Check Dates Before Submission?
- Prevents race conditions
- Better user experience (immediate feedback)
- Reduces failed API calls
- Ensures data consistency

### 3. Why Normalize Dates?
- Ensures accurate date comparisons
- Handles timezone differences
- Prevents off-by-one errors
- Consistent behavior across platforms

## Testing Scenarios

### Scenario 1: Single Confirmed Booking
- Apartment has booking from Jan 1-10
- User A tries to book Jan 5-15 → Dates 5-9 are disabled
- User A tries to book Jan 11-20 → All dates available

### Scenario 2: Multiple Pending Requests
- User A requests Jan 1-10 (PENDING)
- User B requests Jan 5-15 (PENDING) → Allowed
- Owner approves User A → User B's request auto-rejected
- User C tries to book Jan 1-10 → Dates disabled

### Scenario 3: Gap Between Bookings
- Booking 1: Jan 1-5 (CONFIRMED)
- Booking 2: Jan 10-15 (CONFIRMED)
- User tries to book Jan 6-9 → All dates available
- User tries to book Jan 4-11 → Dates 4-5 and 10-11 disabled

## Error Handling

1. **Network Errors**: Gracefully handled, user can retry
2. **Date Conflicts**: Clear error message with suggestion to choose different dates
3. **Insufficient Balance**: Detailed breakdown of required vs available funds
4. **Invalid Date Range**: Validation prevents submission

## Future Enhancements

1. **Visual Calendar View**: Show booked dates in a monthly calendar
2. **Price Calendar**: Display different prices for different dates
3. **Partial Availability**: Suggest alternative nearby dates
4. **Real-time Updates**: WebSocket notifications when dates become unavailable
5. **Booking Modifications**: Allow users to modify pending bookings

## API Endpoints Used

- `GET /api/apartments/{id}/booked-dates` - Get confirmed bookings
- `POST /api/booking-requests` - Create new booking request
- `POST /api/bookings/{id}/approve` - Owner approves booking
- `POST /api/bookings/{id}/reject` - Owner rejects booking

## Files Modified

### Backend
- `server/app/Http/Controllers/Api/ApartmentAvailabilityController.php`
- `server/routes/api.php` (route already existed)

### Frontend
- `client/lib/presentation/screens/shared/create_booking_screen.dart`
- `client/lib/core/network/api_service.dart` (method already existed)

## Conclusion

This implementation provides a robust solution for preventing booking conflicts while maintaining flexibility for apartment owners to choose between multiple requests. The system ensures data consistency through both frontend validation and backend enforcement, providing a smooth user experience with clear feedback at every step.
