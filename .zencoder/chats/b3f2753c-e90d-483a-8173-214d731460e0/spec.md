# Technical Specification: Double-Booking Prevention

## Technical Context
- **Backend**: Laravel 10+, PHP 8.1+
- **Frontend**: Flutter 3.x, Dart 3.x
- **Key Models**: `Booking`, `RentalApplication`, `Apartment`
- **Primary Endpoint**: `GET /api/apartments/{id}/booked-dates`

## Technical Implementation Brief

1.  **Backend Logic**:
    - Modify `ApartmentAvailabilityController::getBookedDates` to merge date ranges from:
        - `Booking` where status is `confirmed`, `approved`, or `completed`.
        - `RentalApplication` where status is `approved` or `modified-approved`.
    - Ensure `check_out` date is treated correctly (usually it's the day the guest leaves, so the next guest can check in on that same day).

2.  **Frontend Logic**:
    - Create a reusable mixin or helper method in Flutter to handle `_loadBookedDates` and `_isDateBooked` logic to avoid duplication across:
        - `RentalApplicationFormScreen`
        - `ModifyApplicationFormScreen`
        - `BookingsScreen` (Edit dialog)
    - Apply `selectableDayPredicate` to all `showDatePicker` calls in these screens.

## Source Code Structure
- **Backend**:
    - `server/app/Http/Controllers/Api/ApartmentAvailabilityController.php`: Main logic for date retrieval.
- **Frontend**:
    - `client/lib/presentation/screens/tenant/rental_application_form.dart`
    - `client/lib/presentation/screens/shared/modify_application_form.dart`
    - `client/lib/presentation/screens/shared/bookings_screen.dart`
    - `client/lib/core/network/api_service.dart`: Already contains `getBookedDates`.

## Contracts

### API: `GET /api/apartments/{id}/booked-dates`
**Response**:
```json
{
    "success": true,
    "data": [
        {"check_in": "2026-01-01", "check_out": "2026-01-10"},
        {"check_in": "2026-01-15", "check_out": "2026-01-20"}
    ],
    "message": "Booked dates retrieved successfully"
}
```

## Delivery Phases

1.  **Phase 1: Backend Enhancement**
    - Update `getBookedDates` controller method.
    - Verify via manual API call or simple test script.

2.  **Phase 2: Rental Application Date Locking**
    - Implement fetching and locking in `RentalApplicationFormScreen`.
    - Implement fetching and locking in `ModifyApplicationFormScreen`.

3.  **Phase 3: Booking Edit Date Locking**
    - Implement fetching and locking in `BookingsScreen` edit dialog.

4.  **Phase 4: Verification & Edge Cases**
    - Ensure `check_out` day availability logic is consistent.
    - Verify past dates are locked.

## Verification Strategy

### Backend Verification
- Use `curl` or a PHP script to call `/api/apartments/{id}/booked-dates` after creating a dummy `RentalApplication` with `approved` status.

### Frontend Verification
- Open each screen in the app.
- Trigger the date picker.
- Visually confirm that dates returned by the API are greyed out/unselectable.
- Attempt to select a past date (should be locked).
