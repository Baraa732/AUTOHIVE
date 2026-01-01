# Technical Specification: Rental Application Management

## Technical Context
- **Frontend**: Flutter (Dart), using Riverpod for state management
- **Backend**: Laravel (PHP), with REST API
- **Database**: SQL (migrations already created for rental applications)
- **Key Dependencies**: 
  - Flutter: flutter_riverpod, http
  - Laravel: Eloquent ORM, Laravel Notifications

## Technical Implementation Brief

The rental application management system is **partially implemented** on both backend and frontend:

**What's Already Built:**
- Backend API endpoints for rental applications (approve, reject, modify, review modifications)
- Data models and migrations for RentalApplication and RentalApplicationModification
- Frontend screens for landlord (incoming_rental_applications.dart, rental_application_detail.dart)
- Frontend screens for tenant (rental_application_form.dart, rental_applications_list.dart)
- Modification review screen (modification_review_screen.dart)
- API service methods for all operations

**Current Issues:**
- **Frontend UI Problem**: Approve/Reject buttons ARE in the detail screen but may not be rendering properly or responding to user interactions
- **Missing State Management**: No Riverpod providers for managing rental application state, causing potential UI synchronization issues
- **No Navigation after Actions**: After approve/reject/modify, screen doesn't properly refresh or navigate
- **Missing Status Validation**: Frontend doesn't validate which statuses allow which actions before rendering buttons

**Required Implementation:**
1. Create Riverpod providers for rental application state management
2. Implement proper error handling and user feedback
3. Add status-based UI logic for showing/hiding action buttons
4. Ensure proper navigation and screen refresh after actions
5. Add visual indicators for application status
6. Implement modification history display

## Source Code Structure

```
client/lib/
├── core/network/
│   ├── api_service.dart          # API methods (already have most endpoints)
│   └── error_handler.dart         # Error handling
├── data/
│   ├── models/
│   │   ├── rental_application.dart     # Model (needs status helpers)
│   │   └── rental_modification.dart    # NEW - Need to create
│   └── providers/
│       ├── rental_applications_provider.dart  # NEW - Riverpod provider
│       └── rental_modification_provider.dart  # NEW - Riverpod provider
├── presentation/
│   ├── screens/
│   │   ├── landlord/
│   │   │   ├── incoming_rental_applications.dart  # List (exists, may need fixes)
│   │   │   └── rental_application_detail.dart     # Detail (exists, needs status logic)
│   │   ├── tenant/
│   │   │   ├── rental_application_form.dart       # Form (exists)
│   │   │   └── rental_applications_list.dart      # List (exists)
│   │   └── shared/
│   │       └── modification_review_screen.dart    # Modification review (exists)
│   └── widgets/
│       ├── application_status_badge.dart          # NEW - Status indicator
│       ├── modification_diff_viewer.dart          # NEW - Show diffs
│       └── tenant_profile_card.dart               # NEW - Tenant info display

server/app/
├── Http/Controllers/Api/
│   └── RentalApplicationController.php  # All endpoints exist
├── Models/
│   ├── RentalApplication.php            # Model exists
│   └── RentalApplicationModification.php # Model exists
└── Services/
    └── RentalApplicationService.php      # Business logic exists
```

## Contracts

### Data Models

**RentalApplication Status Values:**
- `pending` - Initial submission, waiting for landlord review
- `approved` - Approved by landlord, booking created, tenant can modify
- `rejected` - Rejected by landlord, cannot be modified
- `modified-pending` - Tenant requested modification on approved app, waiting for landlord review
- `modified-approved` - Modification approved, fully finalized

**API Endpoints (Already Exist):**

```php
POST   /api/rental-applications                    # Submit application
GET    /api/rental-applications/my-applications    # Get tenant's applications
GET    /api/rental-applications/incoming            # Get landlord's incoming applications
GET    /api/rental-applications/{id}               # Get application details
POST   /api/rental-applications/{id}/approve       # Approve application
POST   /api/rental-applications/{id}/reject        # Reject application (with reason)
POST   /api/rental-applications/{id}/modify        # Submit modification
GET    /api/rental-applications/{id}/modifications # Get modification history
POST   /api/rental-applications/{id}/modifications/{modId}/approve     # Approve modification
POST   /api/rental-applications/{id}/modifications/{modId}/reject      # Reject modification
```

### Frontend Models Needed

**RentalModification Model:**
```dart
class RentalModification {
  final String id;
  final String rentalApplicationId;
  final String status;           // 'pending', 'approved', 'rejected'
  final Map<String, dynamic> previousValues;
  final Map<String, dynamic> newValues;
  final Map<String, dynamic> diff;
  final String? modificationReason;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? respondedAt;
}
```

## Delivery Phases

### Phase 1: State Management & Provider Setup
**Goal**: Establish proper state management foundation

**Tasks**:
1. Create `rental_applications_provider.dart` with Riverpod providers for:
   - `getIncomingApplicationsProvider` - Fetch landlord's incoming applications
   - `getMyApplicationsProvider` - Fetch tenant's applications
   - `applicationDetailProvider` - Get single application details
   - `modificationHistoryProvider` - Get modification history

2. Create `rental_modification_provider.dart` for handling modifications

3. Update `incoming_rental_applications.dart` to use providers instead of direct API calls

**Deliverable**: Screens use Riverpod for state, avoiding setState issues

**Verification**:
- Run Flutter app on debug mode
- Check that incoming applications load from provider
- Verify data persists across navigation
- Confirm no setState errors in console

---

### Phase 2: Fix Action Buttons & Response Handling
**Goal**: Make approve/reject buttons functional and responsive

**Tasks**:
1. Fix `rental_application_detail.dart`:
   - Ensure status validation logic is correct
   - Add debug logging for button visibility
   - Implement proper loading states for approve/reject
   - Add error handling with user feedback

2. Implement success feedback:
   - Navigate back to list after successful action
   - Show snackbar with success/error message
   - Refresh parent list automatically

3. Add abort/cancel functionality for in-progress actions

**Deliverable**: Buttons appear, respond to taps, show feedback

**Verification**:
- Tap "Approve" button → Should show loading → Success snackbar → Navigate back
- Tap "Reject" button → Show dialog → Fill reason → Submit → Success → Navigate back
- Check debug logs to confirm status checks are passing
- Test with different application statuses (pending, approved, etc)

---

### Phase 3: Modification Workflow
**Goal**: Complete modification submission, review, approval cycle

**Tasks**:
1. Create `modification_diff_viewer.dart` widget:
   - Display previous vs new values side-by-side
   - Highlight changed fields
   - Show modification metadata (submitted date, reason)

2. Implement `modification_review_screen.dart`:
   - Display modification details
   - Show approve/reject buttons with proper status validation
   - Handle modification approval/rejection responses

3. Update `rental_application_detail.dart`:
   - Show modification pending section only when status = 'modified-pending'
   - Display modification history
   - Link to modification review screen

**Deliverable**: Landlord can review and respond to modifications

**Verification**:
- Create rental application
- Approve it
- Tenant modifies it
- Landlord sees "modified-pending" status
- Landlord clicks "Review Modification"
- Modification review screen shows with approve/reject buttons
- Approve → Application status changes to 'modified-approved'
- Reject → Application status reverts to previous status

---

### Phase 4: Status Indicators & Status Display
**Goal**: Visual clarity on application status across all screens

**Tasks**:
1. Create `application_status_badge.dart` widget:
   - Color-coded status display (pending=yellow, approved=green, rejected=red, modified=orange)
   - Show status with icon
   - Display last action timestamp

2. Create `tenant_profile_card.dart` widget:
   - Display tenant name, email, phone in consistent format
   - Show profile picture/avatar
   - Used in both list and detail views

3. Update all screens to use these widgets:
   - `incoming_rental_applications.dart`
   - `rental_application_detail.dart`
   - `rental_applications_list.dart`

**Deliverable**: Clear visual status indicators throughout app

**Verification**:
- Visual inspection: Status badges match status values
- Check all statuses display correctly: pending, approved, rejected, modified-pending, modified-approved
- Verify consistency across list and detail views

---

### Phase 5: Integration & Bug Fixes
**Goal**: End-to-end functionality and polish

**Tasks**:
1. Test complete workflows:
   - Tenant submits application
   - Landlord reviews and approves
   - Tenant sees approved status
   - Tenant modifies dates
   - Landlord reviews modification
   - Landlord approves/rejects

2. Fix edge cases:
   - Refresh while processing
   - Network errors during approval
   - Rapid button clicks
   - Back navigation during loading

3. Performance optimization:
   - Cache application list
   - Lazy load modifications
   - Optimize list scrolling

**Deliverable**: Fully functional, polished feature

**Verification**: Manual end-to-end testing of all user stories

---

## Verification Strategy

### For Each Phase:

**Phase 1 Verification:**
```bash
# Run flutter analyze to check for errors
flutter analyze

# Run tests if available
flutter test

# Manual verification:
# 1. Open debug_bookings_screen.dart in the app
# 2. Click "GET /incoming" button
# 3. Verify data loads and shows in console
# 4. Check that incoming_rental_applications_screen shows applications
```

**Phase 2 Verification:**
```bash
# Device testing (Android/iOS):
# 1. Build app: flutter run
# 2. Navigate to incoming applications
# 3. Click on an application with pending status
# 4. Verify Approve and Reject buttons are visible
# 5. Click Approve button
# 6. Verify loading indicator shows
# 7. Verify success message appears
# 8. Verify navigation returns to list
# 9. Repeat for Reject button with rejection reason
```

**Phase 3 Verification:**
```bash
# Modification workflow test:
# 1. With debug screen, approve a pending application
# 2. Navigate to that application in list
# 3. Use modify button (if available) or submit modification
# 4. Go back to landlord view - should show modified-pending
# 5. Click on it, tap "Review Modification"
# 6. Verify diff display
# 7. Click approve/reject
# 8. Verify status change
```

**Phase 4 Verification:**
Visual inspection: Check all screens for consistent status badges with correct colors

**Phase 5 Verification:**
Manual end-to-end testing of all user stories from requirements.md

### Helper Scripts

If needed, create `test_rental_workflow.dart` script to automate the test flow.

### Sample Test Data

Use debug_bookings_screen.dart to generate test data by:
1. Creating multiple rental applications
2. Approving some
3. Rejecting some  
4. Submitting modifications on approved ones

### MCP Servers

None required - all verification can be done with:
- Flutter's built-in tools (analyzer, tests)
- Manual UI testing on device/emulator
- Debug logging via print() and console inspection
