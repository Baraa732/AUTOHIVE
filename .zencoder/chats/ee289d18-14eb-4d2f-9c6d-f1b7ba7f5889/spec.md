# Technical Specification: Owner Cannot Request to Rent Own Property

## Technical Context

**Language/Version**:
- **Backend**: PHP 8.x with Laravel 11
- **Frontend**: Flutter with Dart
- **Primary Dependencies**: Eloquent ORM, Riverpod state management

**Current Implementation**:
- The `BookingController::requestBooking()` creates `BookingRequest` records but does not validate apartment ownership
- The `ApartmentDetailsScreen` displays a "Book Now" button without checking if the current user owns the apartment
- The `CreateBookingScreen` collects booking details without any pre-submission validation

---

## Technical Implementation Brief

The fix requires two-layer validation:

1. **Server-side validation** (Primary security layer):
   - Add ownership check in `BookingController::requestBooking()` method
   - Compare `$request->user()->id` with `$apartment->user_id`
   - Return 403 Forbidden or 422 Unprocessable Entity if user is the owner
   - This prevents malicious API calls

2. **Client-side validation** (UX layer):
   - Modify `ApartmentDetailsScreen::_buildBookingButton()` to conditionally render button based on ownership
   - Show alternative UI (e.g., "Manage Listing" or "Edit Listing" button) for owners
   - Prevent users from even navigating to `CreateBookingScreen` if they own the apartment

---

## Source Code Structure

**Server Files to Modify**:
- `server/app/Http/Controllers/Api/BookingController.php` - `requestBooking()` method (line 649+)

**Client Files to Modify**:
- `client/lib/presentation/screens/shared/apartment_details_screen.dart` - `_buildBookingButton()` and property owner detection
- `client/lib/presentation/screens/shared/create_booking_screen.dart` - Optional: Add server error handling

---

## Contracts

### Server API Response Changes

**Current**: `POST /api/booking-requests` accepts any user's request for any apartment

**Updated**: `POST /api/booking-requests` now validates ownership

**Error Response (when user is apartment owner)**:
```json
{
  "success": false,
  "message": "You cannot request to rent your own property.",
  "errors": {
    "apartment_id": ["Cannot request to rent own property"]
  }
}
```

**HTTP Status Code**: 422 (Unprocessable Entity)

### Data Model Changes

**BookingRequest Model**: No changes needed (ownership check happens before creation)

**Apartment Model**: No changes needed (already has `user_id` field)

### UI State Changes

**ApartmentDetailsScreen**: 
- Load current user data (already doing this)
- Compare `_currentUser['id']` with `_apartment['user']['id']`
- Conditionally render button

---

## Delivery Phases

### Phase 1: Server-side Ownership Validation
**Deliverable**: Prevent the backend API from accepting booking requests where the requester owns the apartment

**Implementation**:
1. Add ownership check in `BookingController::requestBooking()` before creating BookingRequest
2. Return appropriate error response if user is the owner

**Verification**: Use Postman/curl to test:
- Owner attempts to request own apartment → 422 error
- Non-owner requests apartment → 201 success

### Phase 2: Client-side UI Validation
**Deliverable**: Hide/disable the "Book Now" button for apartment owners, show alternative action instead

**Implementation**:
1. Modify `_buildBookingButton()` to check ownership
2. Render different button for owners (navigate to edit/manage screen)
3. Optionally update `CreateBookingScreen` to handle server error gracefully

**Verification**: 
- Login as owner of apartment → Button shows "Manage Listing" instead of "Book Now"
- Login as non-owner → Button shows "Book Now" and allows booking
- Non-logged-in user → Button shows "Login Required"

---

## Verification Strategy

### 1. Manual Testing (Primary)

**Setup**:
- Two user accounts (Ahmad - owner, and another user - renter)
- An apartment owned by Ahmad

**Test Scenarios**:

**Scenario A - Owner attempts via API**:
```bash
curl -X POST http://localhost:8000/api/booking-requests \
  -H "Authorization: Bearer {OWNER_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "apartment_id": 1,
    "check_in": "2025-12-28",
    "check_out": "2025-12-30",
    "guests": 2,
    "message": "I want to rent my own place"
  }'
```
**Expected**: 422 error response with message "You cannot request to rent your own property."

**Scenario B - Non-owner requests via API**:
```bash
curl -X POST http://localhost:8000/api/booking-requests \
  -H "Authorization: Bearer {RENTER_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "apartment_id": 1,
    "check_in": "2025-12-28",
    "check_out": "2025-12-30",
    "guests": 2,
    "message": "I would like to book this"
  }'
```
**Expected**: 201 success response with booking request data

**Scenario C - Owner views apartment in UI**:
- Login as Ahmad (owner)
- Navigate to apartment details screen
- Verify "Book Now" button is NOT visible
- Verify alternative button (e.g., "Manage Listing") IS visible

**Scenario D - Non-owner views apartment in UI**:
- Login as another user
- Navigate to same apartment
- Verify "Book Now" button IS visible
- Verify button is clickable and leads to CreateBookingScreen

### 2. Automated Testing (Optional - if test suite exists)

The project should have tests in:
- `server/tests/Feature/` for API tests
- `client/test/` for widget tests

Create tests to verify:
- API rejects owner's booking request with 422 status
- API accepts non-owner's booking request with 201 status
- UI shows "Manage Listing" for owners
- UI shows "Book Now" for non-owners

### 3. Helper Scripts

None required for this phase.

### 4. MCP Servers

None required.

### 5. Sample Input Artifacts

Required:
- Ahmad's account (ID: can be discovered from database)
- Another user's account
- An apartment owned by Ahmad (ID: can be discovered from database)

These can be generated by the developer or the user can provide existing accounts.
