# Feature Specification: Calendar Booking Conflict Prevention

## User Stories

### User Story 1 - Block Booked Dates in Calendar
**Acceptance Scenarios**:
1. **Given** an apartment has a confirmed booking from the 1st to the 10th of the month, **When** another user opens the booking calendar for the same apartment, **Then** the days from the 1st to the 9th should be disabled and unselectable.
2. **Given** today is the 15th, **When** a user opens the calendar, **Then** all days before the 15th should be disabled (existing behavior).
3. **Given** an apartment has a confirmed booking from the 1st to the 10th, **When** a user selects the 10th as their check-in date, **Then** it should be allowed (standard check-out/check-in overlap).

## Requirements
1. Fetch all confirmed booking dates for a specific apartment from the backend.
2. Update the frontend calendar (DatePicker) to disable (lock) dates that are already booked.
3. Ensure that the check-out date of an existing booking is still available as a check-in date for a new booking, and vice versa.
4. The "lock" should be visual (greyed out) and functional (unclickable).

## Success Criteria
1. Users cannot select dates that overlap with existing confirmed bookings.
2. The UI clearly indicates which dates are unavailable.
3. No two bookings can overlap for the same apartment.
