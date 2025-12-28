# Rental Application Feature - Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AUTOHIVE SYSTEM                                    │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────┐    ┌──────────────────────────────────┐
│        FLUTTER CLIENT (Mobile)       │    │      LARAVEL SERVER (Backend)     │
│                                      │    │                                    │
│  ┌──────────────────────────────────┐│    │  ┌─────────────────────────────┐ │
│  │    Tenant Screens                ││    │  │  RentalApplicationController│ │
│  │  ┌──────────────────────────────┐││    │  │  ┌─────────────────────────┐ │ │
│  │  │ Form Screen                  │││    │  │  │ POST /rental-applications
│  │  │ - Date Picker                │││    │  │  │ GET  /my-applications   │ │ │
│  │  │ - Message Input              │││    │  │  │ GET  /{id}              │ │ │
│  │  │ - Validation                 │││    │  │  │ GET  /incoming (landlord)
│  │  └──────────────────────────────┘││    │  │  │ POST /{id}/approve      │ │ │
│  │  ┌──────────────────────────────┐││    │  │  │ POST /{id}/reject       │ │ │
│  │  │ Applications List Screen      │││    │  │  └─────────────────────────┘ │ │
│  │  │ - Status Display              │││    │  └─────────────────────────────┘ │
│  │  │ - Rejection Reason            │││    │                                  │
│  │  │ - Resubmit Option             │││    │  ┌─────────────────────────────┐ │
│  │  └──────────────────────────────┘││    │  │  RentalApplication Model     │ │
│  └──────────────────────────────────┘│    │  │  ┌─────────────────────────┐ │ │
│  ┌──────────────────────────────────┐│    │  │  │ - user_id              │ │ │
│  │    Landlord Screens              ││    │  │  │ - apartment_id         │ │ │
│  │  ┌──────────────────────────────┐││    │  │  │ - check_in/check_out   │ │ │
│  │  │ Incoming Applications List    │││    │  │  │ - message              │ │ │
│  │  │ - Tenant Avatar               │││    │  │  │ - submission_attempt   │ │ │
│  │  │ - Tenant Contact              │││    │  │  │ - status               │ │ │
│  │  │ - Message Preview             │││    │  │  │ - rejected_reason      │ │ │
│  │  └──────────────────────────────┘││    │  │  └─────────────────────────┘ │ │
│  │  ┌──────────────────────────────┐││    │  └─────────────────────────────┘ │
│  │  │ Application Detail Screen     │││    │                                  │
│  │  │ - Full Tenant Info            │││    │  ┌─────────────────────────────┐ │
│  │  │ - Approve Button              │││    │  │  Database Migrations        │ │
│  │  │ - Reject Dialog               │││    │  │  - rental_applications table│ │
│  │  │ - Rejection Reason Input      │││    │  └─────────────────────────────┘ │
│  │  └──────────────────────────────┘││    │                                  │
│  └──────────────────────────────────┘│    │  ┌─────────────────────────────┐ │
│                                      │    │  │  Notifications              │ │
│  ┌──────────────────────────────────┐│    │  │  - rental_application_      │ │
│  │    API Service Layer             ││    │  │    submitted               │ │
│  │  (api_service.dart)              ││    │  │  - rental_application_     │ │
│  │  ┌──────────────────────────────┐││    │  │    approved                │ │
│  │  │ Methods:                      │││    │  │  - rental_application_     │ │
│  │  │ • submitRentalApplication()   │││    │  │    rejected                │ │
│  │  │ • getMyRentalApplications()   │││    │  └─────────────────────────┘ │ │
│  │  │ • getIncomingApps()           │││    │                                  │
│  │  │ • approveRentalApplication()  │││    │  ┌─────────────────────────────┐ │
│  │  │ • rejectRentalApplication()   │││    │  │  Related Models            │ │
│  │  │ • getRentalApplicationDetail()│││    │  │  - User (tenant/landlord)  │ │
│  │  └──────────────────────────────┘││    │  │  - Apartment               │ │
│  └──────────────────────────────────┘│    │  │  - Booking (created on     │ │
│                                      │    │  │    approval)               │ │
│  ┌──────────────────────────────────┐│    │  │  - Notification            │ │
│  │    Data Models                   ││    │  └─────────────────────────────┘ │
│  │  (rental_application.dart)       ││    │                                  │
│  │  ┌──────────────────────────────┐││    └──────────────────────────────────┘
│  │  │ RentalApplication            │││
│  │  │ fromJson() / toJson()        │││    
│  │  └──────────────────────────────┘││
│  └──────────────────────────────────┘│
│                                      │
└──────────────────────────────────────┘

         ↓↑ HTTP/JSON APIs ↓↑
```

## Data Flow Diagrams

### Submission Flow
```
┌────────────────────────────────────────────────────────────────────────┐
│                     TENANT SUBMISSION FLOW                              │
└────────────────────────────────────────────────────────────────────────┘

Tenant App                          API Server                         Database
    │                                  │                                  │
    │ 1. Fill Form                     │                                  │
    │ - Apartment ID                   │                                  │
    │ - Check-in Date                  │                                  │
    │ - Check-out Date                 │                                  │
    │ - Optional Message               │                                  │
    │                                  │                                  │
    │ 2. Submit Application            │                                  │
    ├─────────────────────────────────→│ POST /rental-applications        │
    │                                  │                                  │
    │                                  │ 3. Validate                      │
    │                                  │    - Apartment exists            │
    │                                  │    - Dates valid                 │
    │                                  │    - Max 3 submissions check     │
    │                                  │                                  │
    │                                  │ 4. Create Application           │
    │                                  ├─────────────────────────────────→│
    │                                  │ INSERT rental_applications       │
    │                                  │ (submission_attempt = count)     │
    │                                  │←─────────────────────────────────│
    │                                  │                                  │
    │                                  │ 5. Create Notification          │
    │                                  │ For: Landlord                    │
    │                                  │ Type: rental_application_        │
    │                                  │       submitted                  │
    │                                  ├─────────────────────────────────→│
    │                                  │ INSERT notifications             │
    │                                  │←─────────────────────────────────│
    │                                  │                                  │
    │ 6. Success Response              │                                  │
    │←─────────────────────────────────│ 201 Created + Application data   │
    │                                  │                                  │
    │ 7. Show Success Message          │                                  │
    │ 8. Redirect to My Applications   │                                  │
```

### Approval Flow
```
┌────────────────────────────────────────────────────────────────────────┐
│                     LANDLORD APPROVAL FLOW                              │
└────────────────────────────────────────────────────────────────────────┘

Landlord App                        API Server                         Database
    │                                  │                                  │
    │ 1. View Incoming Apps            │                                  │
    ├─────────────────────────────────→│ GET /rental-applications/        │
    │                                  │     incoming                     │
    │                                  ├─────────────────────────────────→│
    │                                  │ SELECT * FROM                    │
    │                                  │ rental_applications WHERE        │
    │                                  │ status = 'pending' AND...        │
    │                                  │←─────────────────────────────────│
    │←─────────────────────────────────│ 200 Applications List            │
    │                                  │                                  │
    │ 2. Click on Application          │                                  │
    ├─────────────────────────────────→│ GET /rental-applications/{id}    │
    │                                  ├─────────────────────────────────→│
    │                                  │ SELECT with User & Apartment     │
    │                                  │←─────────────────────────────────│
    │←─────────────────────────────────│ 200 Full Application Details     │
    │                                  │                                  │
    │ 3. Click Approve Button          │                                  │
    ├─────────────────────────────────→│ POST /rental-applications/       │
    │                                  │      {id}/approve               │
    │                                  │                                  │
    │                                  │ 4. BEGIN TRANSACTION             │
    │                                  │                                  │
    │                                  │ 5a. Update RentalApplication   │
    │                                  ├─────────────────────────────────→│
    │                                  │ UPDATE rental_applications       │
    │                                  │ SET status = 'approved'          │
    │                                  │←─────────────────────────────────│
    │                                  │                                  │
    │                                  │ 5b. Create Booking              │
    │                                  ├─────────────────────────────────→│
    │                                  │ INSERT INTO bookings             │
    │                                  │ (user_id, apartment_id,          │
    │                                  │  status = 'confirmed')           │
    │                                  │←─────────────────────────────────│
    │                                  │                                  │
    │                                  │ 5c. Mark Apartment Unavailable  │
    │                                  ├─────────────────────────────────→│
    │                                  │ UPDATE apartments                │
    │                                  │ SET is_available = false         │
    │                                  │←─────────────────────────────────│
    │                                  │                                  │
    │                                  │ 5d. Create Notification         │
    │                                  ├─────────────────────────────────→│
    │                                  │ INSERT notifications             │
    │                                  │ Type: rental_application_        │
    │                                  │       approved                   │
    │                                  │←─────────────────────────────────│
    │                                  │                                  │
    │                                  │ 6. COMMIT TRANSACTION            │
    │                                  │                                  │
    │ 7. Success Response              │                                  │
    │←─────────────────────────────────│ 200 Application + Booking        │
    │                                  │                                  │
    │ 8. Show Success Message          │                                  │
    │ 9. Refresh Applications List     │                                  │
```

### Rejection Flow
```
┌────────────────────────────────────────────────────────────────────────┐
│                     LANDLORD REJECTION FLOW                             │
└────────────────────────────────────────────────────────────────────────┘

Landlord App                        API Server                         Database
    │                                  │                                  │
    │ 1. View Application Detail       │                                  │
    │ 2. Click Reject Button           │                                  │
    │                                  │                                  │
    │ 3. Optional: Enter Reason        │                                  │
    │    Dialog opens                  │                                  │
    │                                  │                                  │
    │ 4. Confirm Rejection             │                                  │
    ├─────────────────────────────────→│ POST /rental-applications/       │
    │                                  │      {id}/reject                │
    │                                  │ Body: { rejected_reason }        │
    │                                  │                                  │
    │                                  │ 5. Update RentalApplication    │
    │                                  ├─────────────────────────────────→│
    │                                  │ UPDATE rental_applications       │
    │                                  │ SET status = 'rejected'          │
    │                                  │     rejected_reason = ...        │
    │                                  │←─────────────────────────────────│
    │                                  │                                  │
    │                                  │ 6. Create Notification          │
    │                                  ├─────────────────────────────────→│
    │                                  │ INSERT notifications             │
    │                                  │ Type: rental_application_        │
    │                                  │       rejected                   │
    │                                  │←─────────────────────────────────│
    │                                  │                                  │
    │ 7. Success Response              │                                  │
    │←─────────────────────────────────│ 200 Success                      │
    │                                  │                                  │
    │ 8. Show Success Message          │                                  │
    │ 9. Refresh Applications List     │                                  │
    │                                  │                                  │
    │ (Tenant can now resubmit if      │                                  │
    │  submission_attempt < 2)         │                                  │
```

## Database Schema

```
rental_applications Table
┌─────────────────────────────────────────────────────────┐
│ id (PK)            │ BIGINT UNSIGNED                     │
├────────────────────┼─────────────────────────────────────┤
│ user_id (FK)       │ BIGINT UNSIGNED → users.id          │
├────────────────────┼─────────────────────────────────────┤
│ apartment_id (FK)  │ BIGINT UNSIGNED → apartments.id     │
├────────────────────┼─────────────────────────────────────┤
│ check_in           │ DATE                                │
├────────────────────┼─────────────────────────────────────┤
│ check_out          │ DATE                                │
├────────────────────┼─────────────────────────────────────┤
│ message            │ TEXT (nullable)                     │
├────────────────────┼─────────────────────────────────────┤
│ submission_attempt │ INT (0, 1, 2 = attempts 1-3)        │
├────────────────────┼─────────────────────────────────────┤
│ status             │ ENUM('pending', 'approved',         │
│                    │ 'rejected')                         │
├────────────────────┼─────────────────────────────────────┤
│ rejected_reason    │ TEXT (nullable)                     │
├────────────────────┼─────────────────────────────────────┤
│ submitted_at       │ TIMESTAMP                           │
├────────────────────┼─────────────────────────────────────┤
│ responded_at       │ TIMESTAMP (nullable)                │
├────────────────────┼─────────────────────────────────────┤
│ created_at         │ TIMESTAMP                           │
├────────────────────┼─────────────────────────────────────┤
│ updated_at         │ TIMESTAMP                           │
├────────────────────┼─────────────────────────────────────┤
│ UNIQUE CONSTRAINT  │ (user_id, apartment_id,             │
│                    │  submission_attempt)                │
└─────────────────────────────────────────────────────────┘
```

## State Machine

```
                     ┌─────────────┐
                     │   PENDING   │
                     └──────┬──────┘
                            │
                  ┌─────────┴─────────┐
                  │                   │
            ┌─────▼──────┐     ┌──────▼──────┐
            │  APPROVED  │     │  REJECTED   │
            └────────────┘     └──────┬──────┘
                  │                   │
            ┌─────▼──────┐            │
            │   BOOKING  │            │
            │  CREATED   │            │
            │(confirmed) │     Can Resubmit
            └────────────┘     (if attempt < 2)
                                     │
                              ┌──────▼──────┐
                              │   PENDING   │ (new)
                              └─────────────┘
```

## API Endpoint Summary

```
TENANT ENDPOINTS
├── POST   /rental-applications
│   ├── Input: apartment_id, check_in, check_out, message?
│   ├── Output: 201 + RentalApplication
│   └── Effect: Creates application, notifies landlord
│
├── GET    /rental-applications/my-applications
│   ├── Output: 200 + Paginated RentalApplications
│   └── Effect: Returns user's applications
│
└── GET    /rental-applications/{id}
    ├── Output: 200 + RentalApplication
    └── Auth: User is tenant or landlord

LANDLORD ENDPOINTS
├── GET    /rental-applications/incoming
│   ├── Output: 200 + Paginated RentalApplications
│   └── Filter: user's apartments, status=pending
│
├── POST   /rental-applications/{id}/approve
│   ├── Output: 200 + Application + Booking
│   ├── Transaction: Update app, create booking, mark unavailable
│   └── Effect: Notifies tenant
│
└── POST   /rental-applications/{id}/reject
    ├── Input: rejected_reason?
    ├── Output: 200 Success
    └── Effect: Notifies tenant, allows resubmission
```

## Security Model

```
Authentication Layer
├── Token-based (Sanctum)
├── Authorization checks (user ownership)
└── Middleware: auth:sanctum, approved

Validation Layer
├── Input validation (dates, apartment exists)
├── Business logic (max submissions, authorization)
└── Error responses (consistent format)

Data Protection
├── Eloquent ORM (SQL injection prevention)
├── Foreign key constraints
├── Cascading deletes
└── Transactions (atomic operations)
```

---

**Architecture is production-ready and follows Laravel/Flutter best practices.**
