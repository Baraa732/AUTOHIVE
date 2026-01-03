# Booking Date Restriction Feature

## Overview
This feature prevents users from booking apartments during periods when they are already booked by other users. Users can only select available dates from the calendar.

## Implementation

### Backend (Laravel)

#### 1. New Controller: `ApartmentAvailabilityController.php`
- **Location**: `server/app/Http/Controllers/Api/ApartmentAvailabilityController.php`
- **Method**: `getBookedDates($apartmentId)`
- **Purpose**: Returns all confirmed booking dates for a specific apartment
- **Response Format**:
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
  ],
  "message": "Booked dates retrieved successfully"
}
```

#### 2. New API Route
- **Endpoint**: `GET /api/apartments/{id}/booked-dates`
- **Access**: Public (no authentication required)
- **Location**: `server/routes/api.php`

### Frontend (Flutter)

#### 1. Updated `ApiService`
- **Location**: `client/lib/core/network/api_service.dart`
- **New Method**: `getBookedDates(String apartmentId)`
- **Purpose**: Fetches booked dates from the backend

#### 2. Updated `CreateBookingScreen`
- **Location**: `client/lib/presentation/screens/shared/create_booking_screen.dart`
- **Changes**:
  - Added `_bookedRanges` list to store booked date ranges
  - Added `initState()` to load booked dates when screen opens
  - Added `_loadBookedDates()` method to fetch booked dates from API
  - Added `_isDateBooked(DateTime date)` method to check if a date is booked
  - Updated `_selectCheckInDate()` to disable booked dates using `selectableDayPredicate`
  - Updated `_selectCheckOutDate()` to disable booked dates using `selectableDayPredicate`

## How It Works

1. **User Opens Booking Screen**: When a user opens the booking screen for an apartment, the app automatically fetches all confirmed booking dates for that apartment.

2. **Date Picker Displays**: When the user taps to select check-in or check-out dates, the calendar appears with booked dates disabled (grayed out and unselectable).

3. **Date Selection**: Users can only select dates that are not part of any confirmed booking period.

4. **Booking Submission**: When the user submits the booking request, the backend validates again to ensure the dates are still available (double-check for race conditions).

## Key Features

- **Real-time Availability**: Dates are fetched fresh each time the booking screen opens
- **Visual Feedback**: Booked dates appear disabled in the calendar
- **Prevents Conflicts**: Users cannot select dates that overlap with existing confirmed bookings
- **Only Confirmed Bookings**: Only bookings with status "confirmed" block dates (pending bookings don't block dates)

## Testing

### Test Scenario 1: View Booked Dates
1. Create a confirmed booking for an apartment (e.g., Feb 1-5, 2025)
2. Open the booking screen for that apartment
3. Try to select check-in date
4. Verify that Feb 1-5 are disabled in the calendar

### Test Scenario 2: Book Available Dates
1. With existing booking (Feb 1-5)
2. Select check-in: Feb 6
3. Select check-out: Feb 10
4. Submit booking successfully

### Test Scenario 3: Multiple Bookings
1. Create multiple confirmed bookings with gaps
2. Verify only the booked date ranges are disabled
3. Verify gaps between bookings are selectable

## API Endpoint Details

### Get Booked Dates
```
GET /api/apartments/{apartmentId}/booked-dates
```

**Response (Success)**:
```json
{
  "success": true,
  "data": [
    {
      "check_in": "2025-02-01",
      "check_out": "2025-02-05"
    }
  ],
  "message": "Booked dates retrieved successfully"
}
```

**Response (Error)**:
```json
{
  "success": false,
  "message": "Apartment not found"
}
```

## Notes

- The feature only blocks dates for **confirmed** bookings (status = 'confirmed')
- Pending bookings do not block dates to allow multiple users to request the same dates
- The landlord can then approve the best booking request
- Once a booking is confirmed, all other pending bookings for overlapping dates are automatically rejected
- The backend performs additional validation when a booking is submitted to prevent race conditions

## Future Enhancements

1. **Visual Calendar View**: Show a full month calendar with booked dates highlighted
2. **Price Calendar**: Display different prices for different dates
3. **Minimum Stay**: Enforce minimum stay requirements
4. **Instant Booking**: Allow instant booking for available dates without landlord approval
5. **Booking Buffer**: Add buffer days between bookings for cleaning/maintenance
