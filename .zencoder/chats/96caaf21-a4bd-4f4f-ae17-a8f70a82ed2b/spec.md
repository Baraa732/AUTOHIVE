# Technical Specification: Rental Request Management & Modification Workflow

## Technical Context

- **Backend**: Laravel 12 with Sanctum API authentication
- **Frontend**: Flutter 3.10.3 with Riverpod state management
- **Database**: SQLite/MySQL (Laravel Eloquent ORM)
- **Real-time**: Pusher notifications (already integrated)
- **Primary Dependencies**: 
  - Backend: Laravel Framework, Pusher, Spatie Permission
  - Frontend: Flutter Riverpod, Flutter Bloc, HTTP, Socket.io

## Current State Analysis

**Existing Implementation**:
- `RentalApplication` model with status: `['pending', 'approved', 'rejected']`
- API endpoints for submit, list, approve, reject
- Approval creates a `Booking` with status `confirmed`
- Notification system for submission and decisions
- Basic tenant and landlord screens

**Gaps to Address**:
- No modification workflow support (model, API, UI)
- No status tracking for modified applications ("modified-pending", "modified-approved")
- No diff view for changes
- No auto-transition of tenant status at rental end
- No history/audit trail of modifications
- Limited validation of modification eligibility

## Technical Implementation Brief

### 1. **Database Schema Changes**

**RentalApplication Model Enhancement**:
- Add `previous_status` field to track status before modification
- Add `modification_reason` field (optional, for tenant explanation)
- Add `previous_data` JSON field to store old values for diff view
- Add `current_data` JSON field to store new values
- Add `modification_submitted_at` timestamp
- Expand status enum to include: `'modified-pending'`, `'modified-approved'`

**New RentalApplicationModification Model** (for audit trail):
- Track each modification version
- Store original values, modified values, timestamps
- Link to RentalApplication

**User Model Enhancement**:
- Add `rental_status` field for tracking active/inactive tenant status
- Add `rental_end_date` field for automatic transition

### 2. **Backend API Changes**

**New Endpoints**:
- `POST /rental-applications/{id}/modify` - Submit modification
- `GET /rental-applications/{id}/modifications` - Get modification history with diffs
- `POST /rental-applications/{id}/modifications/{modId}/approve` - Approve specific modification
- `POST /rental-applications/{id}/modifications/{modId}/reject` - Reject and revert to previous

**Modified Endpoints**:
- `POST /rental-applications/{id}/approve` - Handle both original and modified requests with single approval
- Validation: Can only approve if status is 'pending' OR 'modified-pending'

**Approval Flow**:
- On approve: Always creates/updates Booking with 'confirmed' status
- Sets user `rental_status` to 'active', stores `rental_end_date`
- No separate approval for "modification" - single approval applies to all

### 3. **Frontend Data Model Changes**

**RentalApplication Enhancement**:
- Add `previousStatus`, `previousData`, `currentData` fields
- Add `modificationSubmittedAt` timestamp
- Helper methods: `isModifiable()`, `showDiffView()`

**New RentalModification Model**:
- Represents modification history
- Methods to show before/after values

### 4. **Notification System**

**Types to Add**:
- `rental_application_modified` - Notify landlord when tenant modifies
- `rental_application_modification_approved` - Notify tenant when modification approved
- `rental_application_modification_rejected` - Notify tenant when modification rejected
- `rental_status_changed` - Notify user when status transitions (auto or manual)

### 5. **Auto-Transition System**

**Background Job/Scheduler**:
- Laravel scheduler task to run daily
- Checks approvals where `rental_end_date <= today`
- Transitions `rental_status` from 'active' to 'inactive'
- Creates notification for user and landlord

## Source Code Structure

```
Server (Laravel):
├── database/migrations/
│   ├── add_modification_fields_to_rental_applications_table.php
│   ├── create_rental_application_modifications_table.php
│   └── add_rental_status_to_users_table.php
├── app/Models/
│   ├── RentalApplication.php (modify existing)
│   ├── RentalApplicationModification.php (new)
│   └── User.php (modify existing)
├── app/Http/Controllers/Api/
│   └── RentalApplicationController.php (extend existing)
├── app/Services/
│   ├── RentalApplicationService.php (new - business logic)
│   └── RentalStatusTransitionService.php (new - auto-transition)
├── app/Jobs/
│   └── TransitionRentalStatusJob.php (new - scheduler)
├── app/Events/
│   └── RentalApplicationModified.php (new)
└── routes/api.php (extend with new endpoints)

Client (Flutter):
├── lib/data/models/
│   ├── rental_application.dart (modify existing)
│   └── rental_modification.dart (new)
├── lib/core/network/
│   └── api_service.dart (add new methods)
├── lib/presentation/screens/
│   ├── landlord/
│   │   └── modification_review_screen.dart (new)
│   ├── tenant/
│   │   ├── modify_application_form.dart (new)
│   │   └── rental_applications_list.dart (modify existing)
│   └── shared/
│       └── diff_view_widget.dart (new reusable widget)
└── lib/presentation/providers/
    └── rental_application_provider.dart (if using Riverpod)
```

## Contracts

### API Contracts

#### 1. Modify Rental Application
```
POST /rental-applications/{id}/modify
Headers: Authorization: Bearer {token}
Body: {
  "check_in": "2025-02-15",
  "check_out": "2025-02-28",
  "message": "Can I extend the stay?" // optional
}
Response: {
  "success": true,
  "data": {
    "id": "app_id",
    "status": "modified-pending",
    "previous_status": "approved",
    "previous_data": {
      "check_in": "2025-02-01",
      "check_out": "2025-02-15"
    },
    "current_data": {
      "check_in": "2025-02-15",
      "check_out": "2025-02-28"
    },
    "modification_submitted_at": "2025-01-05T10:30:00Z"
  }
}
```

#### 2. Get Modification History
```
GET /rental-applications/{id}/modifications
Response: {
  "success": true,
  "data": [
    {
      "id": "mod_1",
      "from_status": "approved",
      "to_status": "modified-pending",
      "previous_values": { "check_in": "...", "check_out": "..." },
      "new_values": { "check_in": "...", "check_out": "..." },
      "modification_reason": "...",
      "submitted_at": "...",
      "status": "pending" // pending, approved, rejected
    }
  ]
}
```

#### 3. Approve/Reject Modification
```
POST /rental-applications/{id}/modifications/{modId}/approve
Response: {
  "success": true,
  "data": {
    "application": { ...application with new values, status: "approved" },
    "booking": { ...updated booking }
  }
}

POST /rental-applications/{id}/modifications/{modId}/reject
Body: {
  "rejection_reason": "...", // optional
}
Response: {
  "success": true,
  "message": "Modification rejected, application reverted to previous status",
  "data": {
    "application": { ...reverted application with old values, status: "approved" }
  }
}
```

### Data Model Contracts

#### RentalApplication (Enhanced)
```php
Schema::table('rental_applications', function (Blueprint $table) {
    $table->enum('status', ['pending', 'approved', 'rejected', 'modified-pending', 'modified-approved'])->change();
    $table->string('previous_status')->nullable();
    $table->json('previous_data')->nullable();
    $table->json('current_data')->nullable();
    $table->text('modification_reason')->nullable();
    $table->timestamp('modification_submitted_at')->nullable();
});
```

#### Users (Enhanced)
```php
Schema::table('users', function (Blueprint $table) {
    $table->enum('rental_status', ['active', 'inactive', 'pending'])->default('pending');
    $table->date('rental_end_date')->nullable();
});
```

#### RentalApplicationModifications (New)
```php
Schema::create('rental_application_modifications', function (Blueprint $table) {
    $table->id();
    $table->foreignId('rental_application_id')->constrained()->onDelete('cascade');
    $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
    $table->json('previous_values');
    $table->json('new_values');
    $table->text('modification_reason')->nullable();
    $table->text('rejection_reason')->nullable();
    $table->timestamp('submitted_at');
    $table->timestamp('responded_at')->nullable();
    $table->timestamps();
});
```

## Delivery Phases

### Phase 1: Backend Foundation (Deliverable 1)
**Scope**: Database schema, models, business logic services
- [ ] Create migrations for enhanced schema
- [ ] Extend RentalApplication model with modification logic
- [ ] Create RentalApplicationModification model
- [ ] Extend User model with rental status tracking
- [ ] Create RentalApplicationService for modification business logic
- [ ] Update existing approve/reject to handle both original and modified states
- [ ] Add validation: Can only modify if status is 'pending' OR 'approved'

**Verification**:
- Database migrations run without errors
- Models have correct relationships
- Existing tests still pass
- Manual API testing with Postman

### Phase 2: API Endpoints (Deliverable 2)
**Scope**: New API endpoints for modification workflow
- [ ] Implement `POST /rental-applications/{id}/modify` endpoint
- [ ] Implement `GET /rental-applications/{id}/modifications` endpoint
- [ ] Implement modification approve/reject endpoints
- [ ] Add proper validation and error handling
- [ ] Update notification system for modification events
- [ ] Create/update tests for new endpoints

**Verification**:
- Run API tests: `php artisan test --filter Modification`
- Verify response structure matches contracts
- Test edge cases: remodify pending, reject and verify revert

### Phase 3: Tenant UI (Deliverable 3)
**Scope**: Tenant-side screens for modification workflow
- [ ] Update RentalApplication model in Flutter
- [ ] Create modify_application_form.dart screen
- [ ] Add API methods to ApiService for modifications
- [ ] Update rental_applications_list.dart to show modification status
- [ ] Add modify button (conditionally show if eligible)
- [ ] Handle modification success/error feedback

**Verification**:
- Build and run Flutter app: `flutter run`
- Test modification form with valid/invalid dates
- Verify status updates after submission
- Check notifications are received

### Phase 4: Landlord UI + Diff View (Deliverable 4)
**Scope**: Landlord-side screens for reviewing modifications with diff view
- [ ] Create modification_review_screen.dart
- [ ] Create diff_view_widget.dart (reusable diff component)
- [ ] Update incoming_rental_applications.dart to show modified status
- [ ] Implement approve/reject modification in detail screen
- [ ] Show before/after values clearly
- [ ] Add confirmation dialogs for modifications

**Verification**:
- Flutter app builds without errors
- Diff view displays correct values
- Approve/reject modification buttons work
- Status updates reflect in UI

### Phase 5: Auto-Transition System (Deliverable 5)
**Scope**: Automatic status transition when rental period ends
- [ ] Create RentalStatusTransitionService
- [ ] Create TransitionRentalStatusJob for Laravel scheduler
- [ ] Configure app/Console/Kernel.php to run job daily
- [ ] Add notification for auto-transition
- [ ] Add tests for scheduler

**Verification**:
- Run scheduler manually: `php artisan schedule:work`
- Check user rental_status updates correctly
- Verify notifications sent
- Check timestamps are recorded

## Verification Strategy

### Test Commands

**Backend Tests**:
```bash
# Run all tests
php artisan test

# Run specific test suite
php artisan test --filter RentalApplication
php artisan test --filter Modification

# Run with coverage
php artisan test --coverage
```

**Frontend Tests**:
```bash
# Build for iOS/Android
flutter build ios
flutter build apk

# Run with logging
flutter run --verbose

# Run unit tests (if added)
flutter test
```

### Helper Verification Scripts

**Create**: `scripts/test_rental_modification.php`
- Simulate tenant creating application
- Simulate landlord approving
- Simulate tenant modifying
- Simulate landlord reviewing and approving modification
- Verify final booking status

**Create**: `scripts/test_auto_transition.php`
- Create application with end date in past
- Run scheduler
- Verify status transitioned to inactive
- Verify notifications sent

### Sample Test Data

**Fixture**: Create test apartments, users
```php
- Landlord user with ID 1
- Tenant user with ID 2
- Apartment owned by landlord
- Rental application from tenant
```

### Postman Collection

**Create**: `RENTAL_MODIFICATION_API.postman_collection.json`
- Tests for all new endpoints
- Pre/post scripts for request chaining
- Environment variables for base URL

## Potential Risks & Mitigation

1. **Race Condition**: Tenant and landlord modifying simultaneously
   - Mitigation: Database transaction locks, optimistic locking with version field

2. **Data Loss**: Reverting modification loses intermediate data
   - Mitigation: RentalApplicationModifications table maintains full history

3. **Performance**: JSON field queries on large datasets
   - Mitigation: Add indexes on key fields, pagination

4. **Notification Failure**: User misses modification notification
   - Mitigation: In-app notification badge, email fallback

## Notes

- Single approval action handles both original and modified requests (no dual approval)
- All timestamps use UTC timezone
- Status transitions are one-way (no reverting approved to pending manually)
- Tenant can modify multiple times while pending/approved (resubmission tracking)
- Landlord sees full diff view of all changes in modifications history
