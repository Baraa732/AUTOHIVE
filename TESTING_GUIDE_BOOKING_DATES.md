# Testing Guide: Booking Date Blocking Feature

## Prerequisites
- Backend server running (`php artisan serve --host=0.0.0.0 --port=8000`)
- Flutter app running on device/emulator
- At least 2 user accounts (one apartment owner, one tenant)
- At least 1 approved apartment

## Test Case 1: Basic Date Blocking

### Setup
1. Login as User A (apartment owner)
2. Create an apartment and wait for admin approval
3. Login as User B (tenant)
4. Navigate to the apartment

### Steps
1. Click "Book Now" button
2. Click "Select Check-in Date"
3. **Expected**: Calendar opens with tomorrow's date (or first available date) selected
4. **Expected**: All past dates are disabled (grayed out)
5. Select a check-in date (e.g., 3 days from now)
6. Click "Select Check-out Date"
7. **Expected**: Calendar opens with day after check-in selected
8. **Expected**: Only dates after check-in are selectable
9. Select a check-out date
10. Fill in number of guests
11. Click "Submit Booking Request"
12. **Expected**: Success message, booking created with PENDING status

### Verification
- Check User B's "My Bookings" → Should show PENDING booking
- Check User A's "Apartment Bookings" → Should show the pending request

## Test Case 2: Confirmed Booking Blocks Dates

### Setup
1. Complete Test Case 1
2. Login as User A (apartment owner)
3. Navigate to "Apartment Bookings"
4. Approve the booking from User B
5. **Expected**: Booking status changes to CONFIRMED
6. **Expected**: Payment deducted from User B's wallet

### Steps
1. Logout and login as User C (another tenant)
2. Navigate to the same apartment
3. Click "Book Now"
4. Click "Select Check-in Date"
5. **Expected**: The dates booked by User B are disabled/grayed out
6. **Expected**: Info banner shows "Some dates are already booked and cannot be selected"
7. Try to select a date within User B's booking range
8. **Expected**: Date is not selectable (tap does nothing)
9. Select a date outside the booked range
10. Complete the booking request

### Verification
- User C can only select dates that don't overlap with User B's confirmed booking
- Calendar correctly shows unavailable dates

## Test Case 3: Multiple Pending Requests (Same Dates)

### Setup
1. Have an apartment with no confirmed bookings
2. Have 3 tenant accounts (User B, User C, User D)

### Steps
1. Login as User B
2. Request booking for Jan 15-20
3. **Expected**: Request created successfully (PENDING)

4. Login as User C
5. Request booking for Jan 15-20 (same dates)
6. **Expected**: Request created successfully (PENDING)
7. **Expected**: Dates are still selectable (not blocked)

8. Login as User D
9. Request booking for Jan 17-22 (overlapping dates)
10. **Expected**: Request created successfully (PENDING)

11. Login as apartment owner
12. Navigate to "Apartment Bookings"
13. **Expected**: See all 3 pending requests
14. Approve User B's request
15. **Expected**: User B's booking becomes CONFIRMED
16. **Expected**: User C and User D's requests auto-rejected

17. Login as User E (new tenant)
18. Try to book Jan 15-20
19. **Expected**: Dates 15-19 are disabled in calendar
20. **Expected**: Cannot select those dates

### Verification
- Multiple users can request same dates when no booking is confirmed
- Once one request is approved, others are auto-rejected
- Confirmed booking blocks dates for future requests

## Test Case 4: Date Range Validation

### Setup
1. Have an apartment with confirmed booking Jan 10-15

### Steps
1. Login as tenant
2. Try to book Jan 5-12
3. **Expected**: Dates 10-11 are disabled
4. **Expected**: Cannot select check-out date that overlaps

5. Try to book Jan 12-18
6. **Expected**: Dates 12-14 are disabled
7. **Expected**: Cannot select check-in date that overlaps

8. Try to book Jan 8-17
9. **Expected**: Dates 10-14 are disabled
10. **Expected**: Cannot create booking that spans the booked period

11. Try to book Jan 5-9
12. **Expected**: All dates are selectable
13. **Expected**: Booking request created successfully

14. Try to book Jan 16-20
15. **Expected**: All dates are selectable
16. **Expected**: Booking request created successfully

### Verification
- System prevents any overlap with confirmed bookings
- Dates immediately before and after booked period are available

## Test Case 5: Error Handling - Race Condition

### Setup
1. Have an apartment with no bookings
2. Have 2 devices/browsers with different tenant accounts

### Steps
1. On Device 1 (User B): Open booking screen for Jan 20-25
2. On Device 2 (User C): Open booking screen for Jan 20-25
3. On Device 1: Fill form and submit booking request
4. **Expected**: Request created (PENDING)
5. On Device 2: Fill form and submit booking request
6. **Expected**: Request created (PENDING)

7. On Owner account: Approve User B's request
8. **Expected**: User B's booking CONFIRMED
9. **Expected**: User C's request auto-rejected

10. On Device 2 (User C): Try to book Jan 20-25 again
11. **Expected**: Dates are now disabled
12. **Expected**: Info banner shows dates are booked

### Verification
- System handles concurrent requests correctly
- Calendar updates to reflect confirmed bookings
- Clear feedback when dates become unavailable

## Test Case 6: Initial Date Selection Bug Fix

### Setup
1. Have an apartment with confirmed booking starting tomorrow

### Steps
1. Login as tenant
2. Navigate to apartment
3. Click "Book Now"
4. Click "Select Check-in Date"
5. **Expected**: Calendar opens without crash
6. **Expected**: Initial date is set to first available date (not tomorrow)
7. **Expected**: Tomorrow's date is disabled

### Verification
- No crash when opening date picker
- Smart initial date selection skips booked dates
- User can immediately see available dates

## Test Case 7: Wallet Balance Validation

### Setup
1. Have a tenant with insufficient wallet balance
2. Have an apartment with price $100/night

### Steps
1. Login as tenant with $50 in wallet
2. Try to book apartment for 2 nights (total $200)
3. Fill in dates and guests
4. Click "Submit Booking Request"
5. **Expected**: Error dialog appears
6. **Expected**: Shows required amount: $200
7. **Expected**: Shows current balance: $50
8. **Expected**: Shows shortage: $150
9. **Expected**: "Add Funds" button available
10. Click "Add Funds"
11. **Expected**: Navigates to wallet screen

### Verification
- System checks wallet balance before creating request
- Clear error message with exact amounts
- Easy path to add funds

## Common Issues and Solutions

### Issue 1: Calendar Crashes When Opening
**Cause**: Initial date is booked and doesn't satisfy selectableDayPredicate
**Solution**: Implemented smart initial date selection that finds first available date

### Issue 2: Dates Not Showing as Blocked
**Cause**: Booked dates not loaded or API error
**Solution**: Check network logs, verify API endpoint returns data

### Issue 3: Can Select Booked Dates
**Cause**: Date comparison logic issue or timezone problem
**Solution**: Implemented date normalization to midnight for accurate comparison

### Issue 4: Multiple Requests Not Allowed
**Cause**: Backend checking PENDING bookings instead of only CONFIRMED
**Solution**: Updated logic to only block CONFIRMED bookings

## Performance Testing

### Load Test
1. Create apartment with 50 confirmed bookings
2. Open booking screen
3. **Expected**: Loads within 2 seconds
4. **Expected**: Calendar responsive
5. **Expected**: All booked dates correctly disabled

### Stress Test
1. Have 10 users simultaneously request same dates
2. Owner approves one request
3. **Expected**: All other requests auto-rejected
4. **Expected**: No database inconsistencies
5. **Expected**: Correct wallet transactions

## Regression Testing Checklist

- [ ] Past dates are disabled
- [ ] Future dates are selectable (if not booked)
- [ ] Confirmed bookings block dates
- [ ] Pending bookings don't block dates
- [ ] Multiple pending requests allowed
- [ ] Auto-rejection works when one approved
- [ ] Wallet balance checked before request
- [ ] Date range validation works
- [ ] Info banner shows when dates booked
- [ ] Calendar doesn't crash on open
- [ ] Check-out date must be after check-in
- [ ] Can book dates immediately after booked period
- [ ] Can book dates immediately before booked period
- [ ] Error messages are clear and helpful

## Automated Test Script (Optional)

```dart
// Example integration test
testWidgets('Booked dates are disabled in calendar', (WidgetTester tester) async {
  // Setup: Create apartment with confirmed booking
  final apartment = await createTestApartment();
  final booking = await createConfirmedBooking(
    apartmentId: apartment.id,
    checkIn: DateTime.now().add(Duration(days: 5)),
    checkOut: DateTime.now().add(Duration(days: 10)),
  );
  
  // Navigate to booking screen
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Book Now'));
  await tester.pumpAndSettle();
  
  // Open date picker
  await tester.tap(find.text('Select Check-in Date'));
  await tester.pumpAndSettle();
  
  // Verify booked dates are disabled
  final bookedDate = DateTime.now().add(Duration(days: 7));
  final dateButton = find.text(bookedDate.day.toString());
  
  expect(tester.widget<TextButton>(dateButton).enabled, false);
});
```

## Reporting Issues

When reporting issues, include:
1. User role (owner/tenant)
2. Apartment ID
3. Booking dates attempted
4. Existing bookings on apartment
5. Screenshots of calendar
6. Console logs (Flutter and Laravel)
7. Steps to reproduce

## Success Criteria

✅ Users cannot select dates that are already confirmed
✅ Multiple users can request same dates (pending)
✅ Owner can choose between multiple requests
✅ Calendar shows clear visual feedback
✅ No crashes or errors during normal use
✅ Wallet balance validated before request
✅ Auto-rejection works correctly
✅ Date range validation prevents overlaps
