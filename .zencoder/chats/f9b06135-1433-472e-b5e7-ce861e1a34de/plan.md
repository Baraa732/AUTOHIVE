# Feature development workflow

---

## Workflow Steps

### [x] Step: Requirements
### [x] Step: Technical Specification
### [x] Step: Implementation Plan

### [x] Step: Verify and update getBookedDates in backend
Ensure that the `getBookedDates` method in `ApartmentAvailabilityController` returns all relevant confirmed bookings and handles date formatting correctly.

### [ ] Step: Fix/Verify date blocking in Flutter frontend
Update `create_booking_screen.dart` to ensure `_isDateBooked` correctly blocks all dates within the booked ranges, including potential edge cases with timezones or local date comparisons.

### [ ] Step: Test overlapping booking prevention
Perform a manual or automated test to ensure that trying to book an overlapping range results in an error and that the UI prevents selecting those dates.

