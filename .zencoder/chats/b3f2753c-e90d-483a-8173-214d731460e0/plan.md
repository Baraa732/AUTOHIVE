# Implementation Plan: Double-Booking Prevention

## Proposed Changes

### Backend

#### 1. Update `ApartmentAvailabilityController@getBookedDates`
- **File**: `server/app/Http/Controllers/Api/ApartmentAvailabilityController.php`
- **Task**: 
    - Include `Booking` with statuses: `confirmed`, `approved`, `completed`.
    - Include `RentalApplication` with statuses: `approved`, `modified-approved`.
    - Merge and return unique date ranges.

#### 2. Update `Apartment@isBookedForDates`
- **File**: `server/app/Models/Apartment.php`
- **Task**: 
    - Update the status check to include `confirmed` and `approved`.
    - Add logic to also check for approved `RentalApplication`s to be safe.

#### 3. Update `CompletePastBookings` command
- **File**: `server/app/Console/Commands/CompletePastBookings.php`
- **Task**: 
    - Ensure it checks for both `confirmed` and `approved` bookings to mark as `completed`.

### Frontend

#### 4. Update `RentalApplicationFormScreen`
- **File**: `client/lib/presentation/screens/tenant/rental_application_form.dart`
- **Task**:
    - Add `_loadBookedDates` and `_isDateBooked` logic.
    - Implement `selectableDayPredicate` in `showDatePicker`.

#### 5. Update `ModifyApplicationFormScreen`
- **File**: `client/lib/presentation/screens/shared/modify_application_form.dart`
- **Task**:
    - Add `_loadBookedDates` and `_isDateBooked` logic.
    - Implement `selectableDayPredicate` in `showDatePicker`.

#### 6. Update `BookingsScreen`
- **File**: `client/lib/presentation/screens/shared/bookings_screen.dart`
- **Task**:
    - Add `_loadBookedDates` and `_isDateBooked` logic within `_handleEditBooking`.
    - Implement `selectableDayPredicate` in `showDatePicker` inside the edit dialog.

#### 7. Refine `CreateBookingScreen`
- **File**: `client/lib/presentation/screens/shared/create_booking_screen.dart`
- **Task**:
    - Ensure logic matches the other screens and handles checkout day correctly.

## Verification Instructions

### Backend
1. Create a `Booking` or `RentalApplication` via database or API for a specific date range.
2. Call `GET /api/apartments/{id}/booked-dates` and verify the range is present.

### Frontend
1. Open the updated screens in the app.
2. Open the date picker and verify that the booked dates are disabled.
3. Verify that past dates are also disabled.
