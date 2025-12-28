# Technical Specification: Rental Application Submission & Approval Workflow

## Technical Context

**Backend**: Laravel 11 (PHP 8.x)
- Database: MySQL/PostgreSQL via Eloquent ORM
- Authentication: Laravel Sanctum (token-based API)
- Key dependencies: Laravel Framework, Eloquent models, database migrations

**Frontend**: Flutter (Dart)
- HTTP client: `http` package
- State management: Providers/Bloc pattern
- API communication: Custom ApiService class

**Database**: Relational model with foreign keys and cascading deletes

---

## Technical Implementation Brief

### Key Technical Decisions

1. **Data Source**: Use existing user profile and booking data (user_id, apartment_id, check_in, check_out) - no new data collection needed except optional message
2. **Resubmission Logic**: Track submission attempts via `submission_attempt` counter field (0-indexed, max 3 attempts = 0,1,2)
3. **Lease Automation**: Use existing Booking model structure; upon approval, create a booking with status "confirmed" and immediately mark apartment as unavailable
4. **Notifications**: Leverage existing Notification model; fire in-app notifications without email/SMS
5. **API Pattern**: Follow existing REST conventions from BookingRequestController as reference
6. **Database Integrity**: Use database transactions to ensure atomic approval operations
7. **Authorization**: Verify ownership of apartment for landlord actions; verify user_id for tenant actions

### Data Reuse Strategy

- **User Data**: Pull from existing User model (first_name, last_name, phone, city, governorate, birth_date, id_image, profile_image)
- **Booking Data**: Reference dates from apartment availability period (check_in, check_out)
- **Optional Message**: New text field allowing tenant to provide context for application

---

## Source Code Structure

### Backend (Server - Laravel)

```
server/
├── app/
│   ├── Models/
│   │   └── RentalApplication.php          (NEW)
│   ├── Http/Controllers/Api/
│   │   └── RentalApplicationController.php (NEW)
│   └── Events/
│       └── RentalApplicationSubmitted.php (NEW) [optional]
├── database/
│   └── migrations/
│       └── YYYY_MM_DD_HHMMSS_create_rental_applications_table.php (NEW)
└── routes/
    └── api.php (MODIFIED - add new routes)
```

### Frontend (Client - Flutter)

```
client/lib/
├── data/
│   └── models/
│       └── rental_application.dart        (NEW)
├── core/
│   └── network/
│       └── api_service.dart (MODIFIED - add rental app endpoints)
├── presentation/
│   ├── screens/
│   │   ├── tenant/
│   │   │   └── rental_applications_list.dart (NEW)
│   │   └── landlord/
│   │       ├── incoming_applications.dart (NEW)
│   │       └── application_detail.dart (NEW)
│   └── providers/ (if using provider pattern)
│       └── rental_application_provider.dart (NEW)
└── application/
    └── blocs/ (if using bloc pattern)
        └── rental_application_bloc.dart (NEW)
```

---

## Contracts

### Database Schema

**Table: `rental_applications`**

```sql
CREATE TABLE rental_applications (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    apartment_id BIGINT UNSIGNED NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    message TEXT NULLABLE,
    submission_attempt INT DEFAULT 0,  -- 0 = 1st submission, 1 = 2nd, 2 = 3rd
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    rejected_reason TEXT NULLABLE,
    submitted_at TIMESTAMP,
    responded_at TIMESTAMP NULLABLE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (apartment_id) REFERENCES apartments(id) ON DELETE CASCADE,
    UNIQUE KEY unique_submission (user_id, apartment_id, submission_attempt)
);
```

### Eloquent Model: `RentalApplication`

```php
namespace App\Models;

class RentalApplication extends Model {
    protected $fillable = [
        'user_id', 'apartment_id', 'check_in', 'check_out',
        'message', 'submission_attempt', 'status', 'rejected_reason',
        'submitted_at', 'responded_at'
    ];
    
    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'submitted_at' => 'datetime',
        'responded_at' => 'datetime',
    ];
    
    public function user() { return $this->belongsTo(User::class); }
    public function apartment() { return $this->belongsTo(Apartment::class); }
}
```

### API Endpoints

#### For Tenants

- **Submit Application**
  - `POST /rental-applications`
  - Request: `{ apartment_id, check_in, check_out, message? }`
  - Response: `{ success, data: RentalApplication, message }`
  - Validation: User authenticated, apartment exists, dates valid, max 3 attempts not exceeded

- **List My Applications**
  - `GET /rental-applications/my-applications`
  - Response: `{ success, data: [RentalApplication], pagination }`
  - Returns applications for authenticated user, ordered by newest first

- **Get Application Detail**
  - `GET /rental-applications/{id}`
  - Response: `{ success, data: RentalApplication, message }`
  - Validation: User is tenant who submitted OR landlord of apartment

#### For Landlords

- **List Incoming Applications**
  - `GET /rental-applications/incoming`
  - Response: `{ success, data: [RentalApplication], pagination }`
  - Returns pending applications for user's apartments with user details included

- **Get Application Detail**
  - `GET /rental-applications/{id}`
  - Response: `{ success, data: RentalApplication with user details, message }`
  - Validation: User is landlord of the apartment

- **Approve Application**
  - `POST /rental-applications/{id}/approve`
  - Response: `{ success, data: { application, booking }, message }`
  - Action: Update application status to 'approved', create Booking with status 'confirmed', create notification
  - Transaction: Atomic operation - all or nothing

- **Reject Application**
  - `POST /rental-applications/{id}/reject`
  - Request: `{ rejected_reason? }`
  - Response: `{ success, message }`
  - Action: Update application status to 'rejected', create notification

### Flutter Model: `RentalApplication`

```dart
class RentalApplication {
  final String id;
  final String userId;
  final String apartmentId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String? message;
  final int submissionAttempt;
  final String status; // pending, approved, rejected
  final String? rejectedReason;
  final DateTime submittedAt;
  final DateTime? respondedAt;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? apartment;
  
  // ... fromJson, toJson methods
}
```

### Notification Types

- **Type**: `rental_application_submitted`
  - Recipient: Landlord (apartment owner)
  - Message: "{tenant_name} has submitted a rental application for {apartment_title}"

- **Type**: `rental_application_approved`
  - Recipient: Tenant
  - Message: "Your rental application for {apartment_title} has been approved!"

- **Type**: `rental_application_rejected`
  - Recipient: Tenant
  - Message: "Your rental application for {apartment_title} was rejected. {reason}"
  - Contains: Application ID, optional rejection_reason

---

## Delivery Phases

### Phase 1: Backend Foundation (Database & Model)
**Deliverable**: Database migration and RentalApplication model with relationships

- Create migration for rental_applications table
- Create RentalApplication Eloquent model with relationships to User and Apartment
- Test: Run migration successfully, verify table structure with `php artisan tinker`

### Phase 2: Tenant API - Submission & List
**Deliverable**: Tenant can submit applications and view their application history

- Create RentalApplicationController with `store()` and `myApplications()` methods
- Add API routes for tenant submission and listing
- Implement resubmission attempt validation (max 3)
- Test: Submit application, verify it's saved, list applications, verify resubmission limits

### Phase 3: Landlord API - View & Approve/Reject
**Deliverable**: Landlord can view incoming applications and approve/reject them

- Implement `incoming()` method to list pending applications for landlord's apartments
- Implement `approve()` method with transaction to create Booking and update status
- Implement `reject()` method to update status and allow resubmission
- Test: View applications, approve application (verify Booking created), reject application

### Phase 4: Notifications
**Deliverable**: In-app notifications for all status changes

- Create notification events for application submission, approval, rejection
- Update controller actions to dispatch notifications to relevant users
- Test: Verify notifications are created when applications are submitted, approved, rejected

### Phase 5: Flutter Client - Tenant Side
**Deliverable**: Tenant can submit and view applications from Flutter app

- Create RentalApplication Dart model
- Add API methods to ApiService (submitApplication, getMyApplications, getApplicationDetail)
- Create UI screens for application submission and application history
- Test: Submit application from app, verify data sent correctly, list applications

### Phase 6: Flutter Client - Landlord Side
**Deliverable**: Landlord can view and manage incoming applications from Flutter app

- Add API methods for landlord endpoints (getIncomingApplications, approveApplication, rejectApplication)
- Create UI screens for viewing incoming applications and approving/rejecting
- Test: View applications, approve/reject from app, verify notifications received

---

## Verification Strategy

### Phase 1 Verification

1. **Database Migration**
   - Command: `php artisan migrate` → verify no errors
   - Command: `php artisan tinker` → `Schema::hasTable('rental_applications')` → should return `true`
   - Command: `DB::getSchemaBuilder()->getColumnListing('rental_applications')` → verify all columns exist

2. **Model Relationships**
   - Command: Create RentalApplication instance in tinker and verify relationships load:
     ```php
     $app = RentalApplication::first();
     $app->user; // should return User instance
     $app->apartment; // should return Apartment instance
     ```

### Phase 2 Verification

1. **Tenant Submission**
   - Use Postman/curl to POST to `/rental-applications`
   - Verify response contains application data with status "pending"
   - Verify database contains the application

2. **Resubmission Limits**
   - Submit 3 applications for same apartment
   - 4th submission should fail with appropriate error
   - Verify `submission_attempt` field increments correctly

3. **List Applications**
   - GET `/rental-applications/my-applications`
   - Verify response contains all submissions by authenticated user
   - Verify pagination works

### Phase 3 Verification

1. **Landlord View Applications**
   - GET `/rental-applications/incoming` as landlord
   - Verify only pending applications for user's apartments are returned
   - Verify includes tenant details

2. **Approval Flow**
   - POST `/rental-applications/{id}/approve` 
   - Verify application status changes to "approved"
   - Verify Booking is created with status "confirmed"
   - Verify apartment is marked unavailable
   - Verify notification is created for tenant

3. **Rejection Flow**
   - POST `/rental-applications/{id}/reject`
   - Verify application status changes to "rejected"
   - Verify notification is created for tenant
   - Verify tenant can resubmit

### Phase 4 Verification

1. **Notifications**
   - GET `/notifications` as tenant after application submission
   - Verify notification with type `rental_application_submitted` exists for landlord
   - Verify notification with type `rental_application_approved` exists for tenant after approval

### Phase 5 & 6 Verification

1. **Flutter API Integration**
   - Use Flutter debugger to verify API calls succeed
   - Verify Dart models parse responses correctly
   - Verify UI screens display data correctly

2. **End-to-End Test Script** (helper script to create)
   - Helper script: `tests/e2e_rental_application.sh` (Bash script)
   - Automates: Create test users, submit application, approve it, verify all state changes
   - Can be run via: `bash tests/e2e_rental_application.sh`

---

## Implementation Notes

1. **Use existing patterns**: Follow BookingRequestController structure for consistency
2. **Authorization checks**: Use middleware and policy checks (user ownership verification)
3. **Transaction safety**: Use DB::transaction() for approve operation (multiple writes)
4. **Error handling**: Return consistent error responses with helpful messages
5. **Status codes**: Use HTTP 200 for success, 422 for validation errors, 403 for unauthorized, 404 for not found
