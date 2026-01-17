# Booking Update Fix - Check-in Date Issue & Date Off-by-One Bug

## Problem Description
1. When editing a booking contract, only the check-out date was being updated while the check-in date remained unchanged
2. Dates were showing as one day earlier than selected (e.g., selecting June 19-23 would show as June 18-22)

## Root Causes

### Issue 1: Check-in Date Not Updating
The backend `BookingController.php` was using truthy checks instead of `$request->has()` to detect which dates were provided.

### Issue 2: Date Off-by-One (Timezone Issue)
The client was using `.toIso8601String().split('T')[0]` which converts DateTime to ISO format with timezone information, causing dates to shift by one day when parsed by the backend in a different timezone (Asia/Damascus).

**Example:**
- User selects: June 19, 2025 (local time)
- `.toIso8601String()` produces: `2025-06-19T00:00:00.000` (but in UTC it might be `2025-06-18T21:00:00.000Z`)
- Backend receives: `2025-06-18` ❌

## Solution Implemented

### 1. Backend Changes (`server/app/Http/Controllers/Api/BookingController.php`)

#### Updated Validation Rules
```php
$request->validate([
    'check_in' => 'sometimes|date|after_or_equal:today',
    'check_out' => 'sometimes|date|after:check_in',
    'payment_details' => 'sometimes|array',
]);
```
- Added `sometimes` rule to allow optional fields
- This enables partial updates (only check_in, only check_out, or both)

#### Fixed Date Processing Logic
```php
if ($request->has('check_in') || $request->has('check_out')) {
    // Use provided dates or keep existing ones
    $checkIn = $request->has('check_in') ? $request->check_in : $booking->check_in->format('Y-m-d');
    $checkOut = $request->has('check_out') ? $request->check_out : $booking->check_out->format('Y-m-d');
    
    Log::info('Processing date change', [
        'original_check_in' => $booking->check_in->format('Y-m-d'),
        'original_check_out' => $booking->check_out->format('Y-m-d'),
        'new_check_in' => $checkIn,
        'new_check_out' => $checkOut,
        'request_has_check_in' => $request->has('check_in'),
        'request_has_check_out' => $request->has('check_out')
    ]);
    
    // ... rest of the logic
}
```

#### Updated Status Reset Logic
```php
if (($request->has('check_in') || $request->has('check_out')) && $booking->status === Booking::STATUS_CONFIRMED) {
    $updateData['status'] = Booking::STATUS_PENDING;
    Log::info('Status reset to pending due to date change');
}
```

#### Updated Notification Logic
```php
if ($request->has('check_in') || $request->has('check_out')) {
    $this->notifyOwnerOfModification($booking);
}
```

### 2. Client-Side Date Formatting Fix

#### A. Sending Dates to Backend

**Files Modified:**
- `client/lib/presentation/screens/shared/bookings_screen.dart`
- `client/lib/presentation/screens/shared/modify_application_form.dart`

**Changed From (WRONG):**
```dart
checkIn: selectedCheckIn!.toIso8601String().split('T')[0],
checkOut: selectedCheckOut!.toIso8601String().split('T')[0],
```

**Changed To (CORRECT):**
```dart
import 'package:intl/intl.dart';

checkIn: DateFormat('yyyy-MM-dd').format(selectedCheckIn!),
checkOut: DateFormat('yyyy-MM-dd').format(selectedCheckOut!),
```

#### B. Parsing Dates from Backend

**Files Modified:**
- `client/lib/data/models/booking.dart`
- `client/lib/data/models/rental_application.dart`

**Changed From (WRONG):**
```dart
checkIn: DateTime.parse(json['check_in']),
checkOut: DateTime.parse(json['check_out']),
```

**Changed To (CORRECT):**
```dart
DateTime parseDate(dynamic dateValue) {
  if (dateValue == null) throw Exception('Date value is null');
  final dateStr = dateValue.toString();
  
  // If it's just a date (YYYY-MM-DD), parse as local date without time
  if (dateStr.length == 10 && !dateStr.contains('T')) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]), // year
      int.parse(parts[1]), // month
      int.parse(parts[2]), // day
    );
  }
  
  // For datetime strings, parse normally
  return DateTime.parse(dateStr.replaceAll('Z', ''));
}

checkIn: parseDate(json['check_in']),
checkOut: parseDate(json['check_out']),
```

**Why this fixes the issue:**
- **Sending**: `DateFormat('yyyy-MM-dd').format()` formats the date in local time without timezone conversion
- **Receiving**: Using `DateTime(year, month, day)` constructor creates a local DateTime without timezone interpretation
- **Problem**: `DateTime.parse()` interprets date strings with timezone context, causing shifts
- Backend timezone is `Asia/Damascus` (UTC+3), causing mismatches

## Business Rules Enforced

The update is only allowed when:
1. **Booking is pending** AND **check-in date is in the future**, OR
2. **Booking was created within the last 60 minutes**

This ensures:
- Users can modify pending bookings before the contract starts
- Users can't modify approved/confirmed bookings that have already started
- Example: If today is June 17 and someone books from June 19-22, they can update dates as long as:
  - The booking is still pending (not approved), OR
  - The booking was just created (within 60 minutes)

## Testing Scenarios

### Scenario 1: Update Both Dates (Pending Booking)
- **Current Date**: June 17, 2025
- **Original Booking**: June 19-22 (Pending)
- **New Dates**: June 20-23
- **Expected**: ✅ Both dates updated successfully

### Scenario 2: Update Only Check-in Date
- **Original Booking**: June 19-22
- **Update**: Check-in to June 18
- **Expected**: ✅ Check-in updated, check-out remains June 22

### Scenario 3: Update Only Check-out Date
- **Original Booking**: June 19-22
- **Update**: Check-out to June 24
- **Expected**: ✅ Check-out updated, check-in remains June 19

### Scenario 4: Approved Booking (Started)
- **Current Date**: June 19, 2025
- **Booking**: June 19-22 (Confirmed/Approved)
- **Expected**: ❌ Cannot modify - contract has started

### Scenario 5: Pending Booking (Future Date)
- **Current Date**: June 17, 2025
- **Booking**: June 19-22 (Pending)
- **Expected**: ✅ Can modify dates

## Files Modified
1. **Backend**: `server/app/Http/Controllers/Api/BookingController.php`
   - Updated `update()` method validation rules
   - Fixed date processing logic using `$request->has()`
   - Added detailed logging for debugging

2. **Client (Sending Dates)**: `client/lib/presentation/screens/shared/bookings_screen.dart`
   - Fixed date formatting from `.toIso8601String()` to `DateFormat('yyyy-MM-dd').format()`
   - Applied fix to both `updateBooking()` and `checkAvailability()` calls

3. **Client (Sending Dates)**: `client/lib/presentation/screens/shared/modify_application_form.dart`
   - Fixed date formatting in rental application modifications
   - Added `intl` package import for DateFormat

4. **Client (Parsing Dates)**: `client/lib/data/models/booking.dart`
   - Fixed date parsing to use `DateTime(year, month, day)` constructor for date-only strings
   - Prevents timezone conversion when parsing dates from API

5. **Client (Parsing Dates)**: `client/lib/data/models/rental_application.dart`
   - Fixed date parsing to use `DateTime(year, month, day)` constructor
   - Ensures consistent date handling across all models

## Additional Notes
- The fix maintains backward compatibility with existing API calls
- Enhanced logging helps track date changes for debugging
- The solution properly handles both partial and full date updates
- Status is automatically reset to pending when dates are changed on confirmed bookings
- **CRITICAL**: Always use `DateFormat('yyyy-MM-dd').format()` when SENDING date-only values to avoid timezone issues
- **CRITICAL**: Always use `DateTime(year, month, day)` constructor when PARSING date-only strings to avoid timezone issues
- Never use `.toIso8601String()` for date-only fields as it includes timezone information
- Never use `DateTime.parse()` directly for date-only strings (YYYY-MM-DD) as it applies timezone interpretation
