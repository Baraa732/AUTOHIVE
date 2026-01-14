# Feature Specification: Double-Booking Prevention

## User Stories

### User Story 1 - Prevent selecting booked dates in calendar
**Acceptance Scenarios**:
1. **Given** an apartment has a confirmed booking from Jan 1st to Jan 10th, **When** another user attempts to book the same apartment, **Then** the dates from Jan 1st to Jan 10th should be disabled/locked in the date picker.
2. **Given** an apartment has an approved rental application for a specific period, **When** a user opens the calendar to create a new booking or rental application, **Then** those dates should be locked and unselectable.
3. **Given** a user is editing an existing booking, **When** they open the date picker to change dates, **Then** other confirmed bookings for the same apartment should be locked in the calendar (excluding their own current booking if applicable, although usually, it's safer to block all overlaps and let the user pick new available dates).

---

## Requirements
1. **Backend**:
    - Update `ApartmentAvailabilityController@getBookedDates` to return both `Booking` and `RentalApplication` date ranges that are confirmed/approved.
    - Ensure all relevant statuses that should block dates are included (e.g., `confirmed`, `approved`, `completed`).
2. **Frontend**:
    - Implement a unified way or ensure consistent implementation across all screens using `showDatePicker` to fetch and respect booked dates.
    - **Screens to update**:
        - `CreateBookingScreen`: Verify current implementation and ensure it uses the updated API.
        - `RentalApplicationFormScreen`: Add booked dates fetching and locking logic.
        - `ModifyApplicationFormScreen`: Add booked dates fetching and locking logic.
        - `BookingsScreen` (Edit Booking dialog): Add booked dates fetching and locking logic.
    - Past dates must remain locked (already implemented in most places, but ensure consistency).

## Success Criteria
1. Users cannot select any date that is already part of a confirmed booking or approved rental application.
2. The calendar UI clearly shows locked dates (disabled buttons).
3. The backend API correctly returns all occupied date ranges for a given apartment.
4. No two bookings can overlap for the same apartment.
