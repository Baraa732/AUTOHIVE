# Technical Specification: Calendar Booking Conflict Prevention

## Technical Context
- **Backend**: Laravel (PHP)
- **Frontend**: Flutter (Dart)
- **Database**: MySQL/PostgreSQL (via Eloquent)
- **Key Models**: `Apartment`, `Booking`

## Technical Implementation Brief
The current implementation already has a `getBookedDates` endpoint in `ApartmentAvailabilityController` and a `_isDateBooked` logic in the Flutter `CreateBookingScreen`. However, it seems to only consider `confirmed` bookings. We need to ensure this logic is robust and correctly handles the "lock" visual state. We will also verify if the `check_out` date handling matches user expectations.

## Source Code Structure
- **Backend**:
    - `app/Http/Controllers/Api/ApartmentAvailabilityController.php`: Handles fetching booked dates.
    - `app/Models/Apartment.php`: contains `isBookedForDates` logic.
- **Frontend**:
    - `lib/presentation/screens/shared/create_booking_screen.dart`: The UI for selecting dates.
    - `lib/core/network/api_service.dart`: API client for fetching booked dates.

## Contracts
### APIs
- `GET /api/apartments/{id}/booked-dates`
    - Response: `{ success: true, data: [ { check_in: "YYYY-MM-DD", check_out: "YYYY-MM-DD" }, ... ] }`

## Delivery Phases
1. **Phase 1: Verification & Refinement of Backend**: Ensure `getBookedDates` returns all relevant bookings (confirmed).
2. **Phase 2: Frontend Calendar Update**: Ensure the Flutter `showDatePicker` correctly uses the `selectableDayPredicate` to block all booked dates.
3. **Phase 3: End-to-End Testing**: Verify that an overlapping booking cannot be created.

## Verification Strategy
- **Backend**: Use `artisan tinker` or manual API calls to verify `getBookedDates` returns correct ranges.
- **Frontend**: Manual testing in the Flutter app to see if dates are greyed out.
- **Database**: Check `bookings` table for overlapping entries.
