# Bookings Feature - Complete Testing Guide

## Overview
This guide covers end-to-end testing of the bookings feature including both backend API endpoints and frontend UI/UX.

---

## Backend API Testing

### Prerequisites
- API running on `http://localhost:8000` (or your configured URL)
- Valid authentication token for a test user
- Test apartments and test users set up

### Test 1: Get User's Bookings
**Endpoint**: `GET /api/bookings`
**Method**: GET
**Headers**: 
```
Authorization: Bearer {TOKEN}
Content-Type: application/json
```

**Expected Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": "1",
        "user_id": "2",
        "apartment_id": "5",
        "check_in": "2025-01-15",
        "check_out": "2025-01-20",
        "total_price": "250.00",
        "status": "pending|approved|confirmed|rejected",
        "created_at": "2025-01-01T10:00:00Z",
        "apartment": {
          "id": "5",
          "title": "Luxury Apartment",
          "user_id": "1",
          "user": {
            "id": "1",
            "first_name": "John",
            "last_name": "Owner",
            "profile_image": "url"
          }
        },
        "user": {
          "id": "2",
          "first_name": "Jane",
          "last_name": "Tenant",
          "profile_image": "url"
        }
      }
    ],
    "current_page": 1,
    "per_page": 20,
    "total": 10
  },
  "message": "Bookings retrieved successfully"
}
```

**Verification**:
- ✅ Response contains `success: true`
- ✅ Response has pagination structure with `data.data` array
- ✅ Each booking has nested `apartment` with nested `user`
- ✅ Each booking has nested `user` (tenant)
- ✅ All required fields present: id, user_id, apartment_id, check_in, check_out, total_price, status
- ✅ Pagination info present: current_page, per_page, total

### Test 2: Get House Owner's Apartment Bookings
**Endpoint**: `GET /api/my-apartment-bookings`
**Method**: GET
**Headers**: 
```
Authorization: Bearer {TOKEN}
Content-Type: application/json
```

**Expected Response** (200 OK):
Same structure as Test 1, but filtered for apartments owned by the current user.

**Verification**:
- ✅ Response contains `success: true`
- ✅ Response has pagination structure
- ✅ All bookings shown are for apartments owned by current user
- ✅ Nested relationships include apartment.user (landlord) and user (tenant)
- ✅ Paginated with 20 items per page

### Test 3: Error Handling - Invalid Token
**Endpoint**: `GET /api/bookings`
**Headers**: 
```
Authorization: Bearer invalid_token
```

**Expected Response** (401 Unauthorized):
```json
{
  "message": "Unauthenticated"
}
```

### Test 4: Error Handling - No Authorization
**Endpoint**: `GET /api/bookings`
**No Authorization header**

**Expected Response** (401 Unauthorized):
```json
{
  "message": "Unauthenticated"
}
```

---

## Frontend Testing

### Test Setup
1. Install flutter dependencies: `flutter pub get`
2. Run the app in debug mode
3. Log in with a test account that has bookings

### Test 1: Bookings Screen Loading
**Steps**:
1. Navigate to Bookings screen from main navigation
2. Observe loading indicator

**Expected Behavior**:
- ✅ Loading indicator appears briefly
- ✅ After 2-5 seconds, data loads and loading indicator disappears
- ✅ Two tabs appear: "My Requests" and "Received"
- ✅ No infinite loading spinner

**If Loading Persists**:
- Check console logs for error messages
- Verify API endpoint is responding (use curl/Postman)
- Check if authentication token is valid
- Check network in Flutter DevTools

### Test 2: My Requests Tab
**Steps**:
1. Ensure you're logged in as a tenant with booking requests
2. Navigate to Bookings screen
3. View "My Requests" tab

**Expected Behavior**:
- ✅ List shows all your booking requests
- ✅ Each card shows:
  - Apartment title
  - Tenant name (your name)
  - Check-in and check-out dates with night count
  - Price per night and total price
  - Status badge (color-coded)
- ✅ Pull-to-refresh works (drag down)
- ✅ Error state shows with retry button if network fails

### Test 3: Received Bookings Tab (House Owner)
**Steps**:
1. Log in as a house owner with apartment bookings
2. Navigate to Bookings screen
3. View "Received" tab

**Expected Behavior**:
- ✅ List shows all bookings on your apartments
- ✅ Each card shows:
  - Apartment title (one of your apartments)
  - Tenant name (who booked)
  - Check-in and check-out dates with night count
  - Price per night and total price
  - Status badge (color-coded)
- ✅ Pull-to-refresh works
- ✅ Error state shows with retry button if network fails

### Test 4: Empty States
**Steps**:
1. Use an account with no bookings
2. Navigate to Bookings screen

**Expected Behavior**:
- ✅ "My Requests" tab shows: "No bookings yet"
- ✅ "Received" tab shows: "No received bookings"
- ✅ No loading spinner, clean centered message
- ✅ Pull-to-refresh still available

### Test 5: Error State
**Steps**:
1. Turn off internet/WiFi while on Bookings screen
2. Pull-to-refresh (or reload)

**Expected Behavior**:
- ✅ Error message displays in center
- ✅ "Retry" button appears
- ✅ No crash, graceful error handling

### Test 6: Status Badge Colors
**Steps**:
1. Find bookings with different statuses
2. Verify badge colors

**Expected Status Colors**:
- ✅ Pending: Orange
- ✅ Approved/Confirmed: Green
- ✅ Rejected/Cancelled: Red
- ✅ Default: Gray

### Test 7: Date and Price Formatting
**Steps**:
1. View any booking card
2. Check date format and price display

**Expected Formatting**:
- ✅ Dates: "MMM d, y" format (e.g., "Jan 15, 2025")
- ✅ Dates show range with night count (e.g., "Jan 15, 2025 - Jan 20, 2025 (5 nights)")
- ✅ Prices show currency symbol: $ (e.g., "$50.00/night", "Total: $250.00")
- ✅ No negative numbers or formatting errors

### Test 8: Responsive Design
**Steps**:
1. Test on different device sizes:
   - Small phone (iPhone SE)
   - Regular phone (iPhone 12)
   - Large phone (iPhone 14 Plus)
   - Tablet (iPad)
2. Verify UI doesn't break

**Expected Behavior**:
- ✅ Text doesn't overflow (use ellipsis)
- ✅ Cards are properly sized
- ✅ All information is readable
- ✅ Status badge doesn't overlap with title

---

## Integration Testing (E2E)

### Scenario 1: Tenant View Journey
1. **Login** as tenant user
2. **Make booking request** on an apartment
3. **Navigate to Bookings** screen
4. **Verify** the request appears in "My Requests" tab with correct data
5. **Refresh** the list (pull-to-refresh)
6. **Verify** data reloads correctly
7. **Logout** and login again
8. **Verify** booking request still appears

### Scenario 2: House Owner View Journey
1. **Login** as house owner
2. **Request sent** to one of your apartments (from another account or test data)
3. **Approve** the booking request (if applicable)
4. **Navigate to Bookings** screen
5. **Verify** the booking appears in "Received" tab
6. **Verify** status shows as "confirmed" or "approved"
7. **Refresh** the list
8. **Verify** data loads correctly

### Scenario 3: Network Error Recovery
1. **Open Bookings** screen successfully
2. **Simulate network error**: Turn off WiFi/mobile data
3. **Pull to refresh** - should show error
4. **Verify** "Retry" button appears
5. **Turn network back on**
6. **Click Retry**
7. **Verify** data loads successfully

### Scenario 4: Authentication Token Expiration
1. **Open Bookings** screen successfully
2. **Simulate token expiration**: Clear auth token or wait if configured to expire
3. **Pull to refresh** - should get 401 error
4. **Verify** error is shown to user
5. **Login again**
6. **Verify** bookings load correctly with new token

---

## Console Log Verification

When testing, check console logs for:

### Success Indicators
- `🔵 START: loadAllBookingsData`
- `⏳ Waiting for both bookings APIs...`
- `📱 loadMyBookings API call started`
- `📡 API response received`
- `✅ Loaded X user bookings`
- `✅ Both APIs completed`
- `🟢 FINISH: loadAllBookingsData - SUCCESS`

### Error Indicators
- `❌ Exception in loadMyBookings`
- `❌ ERROR in loadAllBookingsData`
- `⚠️ API error in loadMyApartmentBookings`

If errors appear, check:
1. Is the endpoint returning 200?
2. Does the response have `success: true`?
3. Are relationships properly loaded?
4. Is the token valid?

---

## Debugging Checklist

- [ ] Backend: Run `php artisan tinker` to verify data
- [ ] Backend: Check Laravel logs in `storage/logs/`
- [ ] Frontend: Check Flutter console output
- [ ] Frontend: Use DevTools Network tab to inspect API responses
- [ ] Frontend: Check if Booking model is parsing correctly
- [ ] Frontend: Verify BookingProvider state is updating
- [ ] Database: Verify relationships are set up correctly
- [ ] Database: Check that bookings table has proper foreign keys
- [ ] API: Test endpoints with Postman or curl
- [ ] Auth: Verify token is being sent in headers
- [ ] Auth: Verify user has permission to view bookings

---

## Success Criteria

All of the following must pass for the feature to be complete:

1. ✅ Backend endpoints return data with proper relationships
2. ✅ Frontend displays bookings without infinite loading
3. ✅ Both tabs work independently
4. ✅ Empty states display when no data
5. ✅ Error states display with retry button
6. ✅ Pull-to-refresh works on both tabs
7. ✅ Status badges show correct colors
8. ✅ Dates and prices format correctly
9. ✅ User names display correctly
10. ✅ Responsive design works on all devices
11. ✅ No crashes or null pointer exceptions
12. ✅ Network errors handled gracefully
13. ✅ Token expiration handled gracefully
14. ✅ Feature works after app restart

---

## Quick Start Commands

### Backend Testing (Postman)
```
Base URL: http://localhost:8000/api

// Get bookings
GET /bookings
Headers: Authorization: Bearer {TOKEN}

// Get apartment bookings
GET /my-apartment-bookings
Headers: Authorization: Bearer {TOKEN}
```

### Frontend Testing
```bash
# Run with verbose logging
flutter run -v

# Run with specific device
flutter run -d {device_id}

# Clear app state and run fresh
flutter clean && flutter pub get && flutter run
```

### Database Testing (Laravel Tinker)
```bash
php artisan tinker

# Check bookings for user
Booking::where('user_id', 1)->with(['apartment.user', 'user'])->get()

# Check apartment bookings
Booking::whereHas('apartment', fn($q) => $q->where('user_id', 1))->with(['apartment.user', 'user'])->get()
```

---

## Known Issues & Solutions

### Issue: Loading spinner never stops
**Cause**: API returning error or not returning proper data structure
**Solution**: 
1. Check API response with Postman
2. Verify relationships are eager-loaded
3. Check console logs for error messages

### Issue: Empty list when data exists
**Cause**: Response structure not matching expected format
**Solution**:
1. Check if response has pagination structure
2. Verify response has `data.data` array
3. Check if Booking.fromJson() is parsing correctly

### Issue: User names not showing
**Cause**: Nested user object not being sent from API
**Solution**:
1. Verify API eager-loads `user` relationship
2. Check if response includes nested user data
3. Verify Booking model handles nullable user

### Issue: Dates show incorrectly
**Cause**: DateTime parsing error
**Solution**:
1. Check database has valid date values
2. Verify API returns ISO 8601 format dates
3. Check Booking model date parsing

---

## Support

If any test fails:
1. Collect console logs
2. Check API response structure
3. Verify database data
4. Review error messages
5. Check relation configurations
