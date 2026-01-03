# Feature Specification: Apartment Rental Application & Approval Workflow

## User Stories

### User Story 1 - Tenant Submits Rental Application

**Acceptance Scenarios**:

1. **Given** a tenant views an apartment listing, **When** they submit a rental application with check-in/check-out dates and optional message, **Then** the application is saved as "pending" and the landlord receives a notification

2. **Given** a tenant has a pending application, **When** they attempt to submit another application for the same apartment (3+ times), **Then** the system prevents further submissions with a clear error message

---

### User Story 2 - Landlord Reviews Application & Tenant Profile

**Acceptance Scenarios**:

1. **Given** a landlord receives an incoming rental application, **When** they open the application detail, **Then** they see:
   - Applicant's profile (name, contact, city, governorate, verification status)
   - Applicant's review/rating history (average rating, review count, recent reviews)
   - Application details (check-in/check-out dates, message)
   - Application status and submission attempt number

2. **Given** a landlord is viewing an applicant's profile, **When** the applicant has no reviews, **Then** a helpful "No reviews yet" message is displayed

3. **Given** a landlord reviews an application with low tenant rating, **When** the rating is visible on screen, **Then** they can make an informed decision before approval

---

### User Story 3 - Landlord Approves or Rejects Application

**Acceptance Scenarios**:

1. **Given** a pending rental application is open, **When** the landlord clicks "Approve", **Then**:
   - Application status changes to "approved"
   - A booking is created for the specified dates
   - Apartment availability is marked as unavailable
   - Tenant's rental_status becomes "active" and rental_end_date is set
   - Tenant receives approval notification

2. **Given** a pending rental application is open, **When** the landlord clicks "Reject" and provides a reason, **Then**:
   - Application status changes to "rejected"
   - Rejection reason is stored and visible to tenant
   - Tenant receives rejection notification with reason
   - Tenant can resubmit (up to 3 attempts)

---

### User Story 4 - Tenant Modifies Approved or Pending Application

**Acceptance Scenarios**:

1. **Given** a tenant has a pending or approved application, **When** they open the application, **Then** a "Modify Application" button is available

2. **Given** the modify form is open, **When** the tenant changes check-in/check-out dates or message and submits, **Then**:
   - Application status changes to "modified-pending"
   - A modification record is created with old and new values
   - Landlord receives notification that application was modified
   - Tenant can view the modification history

3. **Given** a modification is submitted, **When** the tenant views their application, **Then** they can see:
   - The current application status as "modified-pending"
   - The modification submission timestamp
   - The changes they made (diff view)

---

### User Story 5 - Landlord Reviews & Approves/Rejects Modification

**Acceptance Scenarios**:

1. **Given** a "modified-pending" application is open, **When** the landlord reviews the modification, **Then** they see:
   - Side-by-side comparison of old vs new values (check-in, check-out, message)
   - Reason for modification (if provided)
   - Two action buttons: "Approve Modification" and "Reject Modification"

2. **Given** a modification is pending approval, **When** the landlord clicks "Approve Modification", **Then**:
   - Application status changes to "approved"
   - Booking is created/updated with new dates
   - Tenant becomes active immediately
   - Tenant receives approval notification
   - Application is finalized (same as initial approval)

3. **Given** a modification is pending approval, **When** the landlord clicks "Reject Modification" and provides a reason, **Then**:
   - Application reverts to its previous status (pending or approved)
   - All modification data is cleared
   - Tenant receives rejection notification with reason
   - Tenant can modify again if application is still pending/approved

---

## Requirements

### Functional Requirements

**FR1: Application Submission**
- Tenant can submit application with check-in, check-out, and message
- System prevents more than 3 submission attempts per tenant per apartment
- Application is created with "pending" status
- Landlord receives notification immediately

**FR2: Landlord Application Review**
- Landlord can view all incoming applications for their apartments
- Landlord can view detailed application information including:
  - Full applicant profile (name, email, phone, city, governorate)
  - Applicant verification status (is_approved)
  - Applicant review/rating history with average rating and recent reviews
  - Application dates, message, and submission attempt
- Landlord can approve or reject with reason

**FR3: Application Approval**
- On approval, system creates a booking with confirmed status
- Apartment is marked as unavailable
- Tenant's rental_status becomes "active"
- Tenant's rental_end_date is set to checkout date
- Notifications sent to tenant

**FR4: Application Rejection**
- On rejection, rejection reason is stored
- Tenant can resubmit (if under 3 attempts)
- Notifications sent to tenant with reason

**FR5: Application Modification**
- Tenant can only modify if application status is "pending" or "approved"
- Modification creates new record tracking old vs new values
- Application status temporarily becomes "modified-pending"
- Landlord notified of modification

**FR6: Modification Review**
- Landlord can view modification with diff (old vs new values)
- Landlord can approve modification (finalizes as approved, creates/updates booking)
- Landlord can reject modification with reason (reverts to previous status)
- Tenant notified of modification outcome

**FR7: Profile Visibility During Application Review**
- Landlord sees tenant's review history (if any)
- Average rating is displayed
- Recent reviews are listed
- "No reviews yet" message if tenant is new

---

## Success Criteria

**SC1: Landlord can review complete tenant profile**
- All profile fields visible in application detail screen
- Review/rating history displayed with average rating
- No broken links or missing data

**SC2: Application workflow functions correctly**
- Application moves through states: pending → approved/rejected
- Modification flow: modified-pending → approved/rejected (reverts)
- Single approval method (no dual approval)

**SC3: Data integrity**
- On modification rejection, all previous data is restored
- Booking is only created on final approval
- Tenant rental_status only becomes "active" on final approval

**SC4: Notifications sent correctly**
- Landlord notified on new application
- Tenant notified on approval/rejection
- Both parties notified on modification
- Notifications include reason when applicable

**SC5: UI/UX is professional**
- Clear status badges indicating current state
- Diff view shows changes clearly
- All actions have confirmation or feedback
- Error messages are helpful
