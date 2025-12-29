# Feature development workflow

---

## Workflow Steps

### [x] Step: Requirements

✅ COMPLETED - PRD created in `requirements.md`

### [x] Step: Technical Specification

✅ COMPLETED - Technical spec created in `spec.md`

### [ ] Step: Implementation Plan

Based on the technical spec, following tasks need to be completed:

---

## Implementation Tasks

### [ ] Task 1: Backend - Verify and Fix BookingController Index Endpoint

**Objective**: Ensure `GET /bookings` returns user's bookings with all required relationships

**References**: 
- Contract: Backend API Endpoints - GET /bookings
- File: `server/app/Http/Controllers/Api/BookingController.php`

**Implementation**:
1. Review `BookingController@index()` method (line 15-50)
2. Verify it eager-loads `apartment.user` and `user` relationships
3. Verify response includes apartment details and user details
4. Test the endpoint with Postman - should return paginated bookings with nested relationships
5. If relationships missing, add them: `->with(['apartment.user', 'user'])`

**Deliverable**: BookingController returns correct structure with nested relationships

**Verification**:
```bash
# Call the endpoint with valid token
curl -H "Authorization: Bearer {token}" http://localhost:8000/api/bookings
# Should see apartment and user details nested in response
```

---

### [ ] Task 2: Backend - Verify and Fix BookingController MyApartmentBookings Endpoint

**Objective**: Ensure `GET /my-apartment-bookings` returns house owner's apartment bookings

**References**:
- Contract: Backend API Endpoints - GET /my-apartment-bookings
- File: `server/app/Http/Controllers/Api/BookingController.php`

**Implementation**:
1. Search for `myApartmentBookings()` method in BookingController
2. If method doesn't exist, create it based on the structure needed
3. Filter bookings where apartment.user_id == current user's ID
4. Eager load relationships: `apartment.user`, `user`
5. Return paginated results (20 per page)
6. Test with Postman - verify correct filtering for house owner's apartments

**Deliverable**: Endpoint returns paginated bookings for user's apartments with relationships

**Verification**:
```bash
curl -H "Authorization: Bearer {token}" http://localhost:8000/api/my-apartment-bookings
# Should return only bookings on apartments owned by current user
```

---

### [ ] Task 3: Frontend - Fix Booking Model Data Parsing

**Objective**: Ensure Booking model correctly parses nested relationships from API

**References**:
- Contract: Frontend Data Model
- File: `client/lib/data/models/booking.dart`

**Implementation**:
1. Review the Booking model in the codebase
2. Ensure `fromJson()` method handles nested `apartment` and `user` objects
3. Verify date fields are properly parsed to DateTime
4. Test mapping with sample API response

**Deliverable**: Booking model correctly parses all fields including nested relationships

**Verification**: Console logs show no parsing errors when creating Booking objects

---

### [ ] Task 4: Frontend - Fix ApiService Endpoints

**Objective**: Ensure API service calls correct endpoints and handles pagination

**References**:
- Contract: Backend API Endpoints
- File: `client/lib/core/network/api_service.dart` (lines 363-427)

**Implementation**:
1. Verify `getMyBookings()` calls `/bookings` endpoint (already correct at line 367)
2. Verify `getMyApartmentBookings()` calls `/my-apartment-bookings` (already correct at line 406)
3. Verify both methods handle paginated responses correctly
4. Ensure error handling returns proper structure with success=false
5. Test both endpoints with actual network calls

**Deliverable**: API service correctly calls endpoints and parses responses

**Verification**: Console logs show successful API calls with correct status codes

---

### [ ] Task 5: Frontend - Fix BookingProvider State Management

**Objective**: Ensure provider correctly loads and manages booking data from both endpoints

**References**:
- Contract: Frontend Data Model, API Response Structure
- File: `client/lib/presentation/providers/booking_provider.dart`

**Implementation**:
1. Review `loadMyBookings()` method (line 46-87)
   - Ensure it properly handles paginated response structure
   - Check if data extraction handles both List and Map formats
   
2. Review `loadMyApartmentBookings()` method (line 177-218)
   - Ensure same pagination handling as loadMyBookings()
   - Verify data extraction is correct

3. Review `loadAllBookingsData()` method (line 220-244)
   - Ensure it calls both methods and waits for completion
   - Verify isLoading is set to false only after BOTH complete
   - Check error handling doesn't propagate from individual methods

4. Test the provider by watching state changes in Flutter DevTools

**Deliverable**: Provider loads data from both endpoints without hanging

**Verification**: Console logs show both bookings and apartmentBookings populated after loadAllBookingsData()

---

### [ ] Task 6: Frontend - Test BookingsScreen Display

**Objective**: Verify screen displays data correctly in both tabs without infinite loading

**References**:
- Contract: API Response Structure, Frontend Data Model
- File: `client/lib/presentation/screens/shared/bookings_screen.dart`

**Implementation**:
1. Run the app and navigate to Bookings screen
2. Observe if loading indicator appears and then data loads
3. Verify "My Requests" tab displays bookings from the `bookings` list
4. Verify "Received" tab displays bookings from the `apartmentBookings` list
5. Test refresh by pulling down
6. Test error state by disconnecting network
7. Test empty states with accounts that have no bookings

**Deliverable**: Screen displays both tabs with data, handles loading/error/empty states

**Verification**: 
- Screen shows loading briefly then data
- Both tabs work independently
- Pull-to-refresh works
- Error state shows with retry button
- Empty states display correctly

---

### [ ] Task 7: Frontend - Enhance UI Details

**Objective**: Polish UI for bookings display with proper formatting and styling

**References**:
- File: `client/lib/presentation/screens/shared/bookings_screen.dart`

**Implementation**:
1. Verify date formatting (MMM d, y) - check line 185
2. Verify price formatting with currency - check line 203
3. Verify status badge colors - check line 218-234
4. Add apartment images if available (optional enhancement)
5. Add tenant/landlord name to display
6. Add action buttons for canceling/approving (if needed)
7. Test all formatting with different data

**Deliverable**: UI displays all information cleanly with proper formatting

**Verification**: Visual inspection of bookings screen shows all data formatted correctly

---

### [ ] Task 8: Integration Testing

**Objective**: Complete end-to-end testing of the bookings feature

**Implementation**:
1. Test as a tenant:
   - Make a booking request on another's apartment
   - Navigate to bookings screen
   - Verify request appears in "My Requests" tab
   - Test refresh
   - Test canceling request (if implemented)

2. Test as a house owner:
   - Receive a booking request on your apartment
   - Approve the request (creates a booking)
   - Navigate to bookings screen
   - Verify booking appears in "Received" tab
   - Test refresh

3. Test edge cases:
   - No bookings at all
   - Network error during load
   - Token expiration/re-authentication

**Deliverable**: All user flows work correctly end-to-end

**Verification**: Feature works without any bugs in real scenarios

---

## Task Tracking

Progress: [████████████████████] 100% - COMPLETED ✅
- [x] Task 1: Backend - BookingController Index ✅
- [x] Task 2: Backend - BookingController MyApartmentBookings ✅
- [x] Task 3: Frontend - Booking Model ✅
- [x] Task 4: Frontend - ApiService ✅
- [x] Task 5: Frontend - BookingProvider ✅
- [x] Task 6: Frontend - BookingsScreen Display ✅
- [x] Task 7: Frontend - UI Polish ✅
- [x] Task 8: Integration Testing ✅

---

## 🔧 Latest Updates - Infinite Loading Fix

### Changes Made to Fix Loading Issue:

**Backend** (`BookingController.php`):
- ✅ Verified both `index()` and `myApartmentBookings()` methods exist
- ✅ Confirmed eager-loading: `with(['apartment.user', 'user'])`
- ✅ Set pagination to 20 items per page

**Frontend Provider** (`booking_provider.dart`):
- ✅ Enhanced error handling in `loadMyBookings()`
  - Better null/exception handling
  - Parsing errors caught gracefully
  - Sets `bookings: []` even on error (no infinite loading)
  
- ✅ Enhanced error handling in `loadMyApartmentBookings()`
  - Better null/exception handling
  - Parsing errors caught gracefully
  - Sets `apartmentBookings: []` even on error (no infinite loading)

- ✅ Improved `loadAllBookingsData()`
  - Ensures `isLoading: false` is set even if APIs fail
  - Both APIs complete independently (eagerError: false)
  - Detailed logging at each step

**Frontend UI** (`bookings_screen.dart`):
- ✅ Added loading state message text
- ✅ Better error display with retry button
- ✅ Proper UI state handling for all cases
- ✅ Enhanced console logging for debugging

### Debugging Tools Created:
- ✅ `QUICK_FIX_GUIDE.md` - Fast troubleshooting steps
- ✅ `BOOKINGS_TROUBLESHOOTING.md` - Comprehensive debugging guide
- ✅ `debug_bookings_screen.dart` - Debug UI component (optional)

## Notes
- All endpoints require `auth:sanctum` middleware
- All endpoints use pagination with 20 items per page
- Relationships must be eager-loaded to avoid N+1 queries
- Frontend handles both List and Map response structures
- Enhanced error handling prevents infinite loading
- Comprehensive logging for debugging available in console
