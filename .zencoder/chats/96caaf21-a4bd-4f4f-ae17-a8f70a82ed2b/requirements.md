# Feature Specification: Rental Request Management & Approval Workflow

## User Stories

### User Story 1 - Landlord Reviews Rental Request

**Acceptance Scenarios**:

1. **Given** a tenant has submitted a rental request, **When** the landlord navigates to their requests, **Then** they see the request with the tenant's profile details and all request information
2. **Given** a landlord is viewing a rental request, **When** they click "Approve", **Then** the request status changes to "Approved", the tenant is notified, and becomes a tenant of the apartment for the specified period
3. **Given** a landlord is viewing a rental request, **When** they click "Reject", **Then** the request status changes to "Rejected" and the tenant is notified

---

### User Story 2 - Tenant Modifies Pending/Approved Request

**Acceptance Scenarios**:

1. **Given** a rental request is in "Pending" status, **When** the tenant clicks "Modify", **Then** they can edit the request details and submit the modification
2. **Given** a rental request is in "Approved" status, **When** the tenant clicks "Modify", **Then** they can edit the request details and submit the modification
3. **Given** a rental request is in "Rejected" status, **When** the tenant tries to modify, **Then** they cannot modify the request
4. **Given** a tenant has submitted a modification, **When** the modification is submitted, **Then** the landlord is notified and the application status changes to "Modified - Pending Review"

---

### User Story 3 - Landlord Reviews Modification

**Acceptance Scenarios**:

1. **Given** a tenant has modified an approved or pending request, **When** the landlord views the request, **Then** they see the old values and new values (diff view) and can distinguish what changed
2. **Given** a landlord is reviewing a modification, **When** they click "Approve Modification", **Then** the request status changes to "Approved" with the new information, and the tenant is notified
3. **Given** a landlord is reviewing a modification, **When** they click "Reject Modification", **Then** the request reverts to the previous status and information, and the tenant is notified

---

### User Story 4 - Rental Period Management

**Acceptance Scenarios**:

1. **Given** a rental request is approved, **When** the rental period ends, **Then** the tenant's status automatically transitions to "Inactive" or "Rental Ended"
2. **Given** a tenant has an active rental, **When** viewing their profile, **Then** they see their rental end date

---

## Requirements

### Functional Requirements

1. **Landlord Request Visibility**
   - Landlord can view all rental requests for their apartments
   - Each request displays: tenant profile details, move-in date, move-out date, rental period, lease terms, and any additional request information

2. **Landlord Approval Workflow**
   - Landlord can approve rental requests (single action, no separate approvals for request vs modification)
   - Landlord can reject rental requests
   - All approvals/rejections trigger notifications to tenant

3. **Tenant Modification Capability**
   - Tenant can modify requests only if status is "Pending" OR "Approved"
   - Modification submits a new version of the request for landlord review
   - Status changes to "Modified - Pending Review" when modification is submitted
   - Tenant receives confirmation when modification is submitted

4. **Modification Review Workflow**
   - Landlord sees diff view (old vs new values) for modifications
   - Landlord can approve modification (full approval, no additional approval needed)
   - Landlord can reject modification (reverts to previous status and information)
   - All modification decisions trigger notifications to tenant

5. **Tenant Status Management**
   - Upon request approval, tenant status becomes "Active Tenant" for the specified rental period
   - Rental period is tracked based on move-in and move-out dates
   - When rental period ends, status automatically transitions to "Inactive"

### Non-Functional Requirements

1. **Notifications**
   - Real-time or near real-time notifications for request/modification decisions
   - Notifications must be trackable and visible in user dashboards

2. **Data Integrity**
   - Previous versions of requests must be stored for audit/history purposes
   - Rejected modifications should preserve previous values

3. **UI/UX**
   - Clear visual distinction between original and modified values
   - Status indicators should be clear and consistent

---

## Success Criteria

1. Landlord can view all rental requests with tenant details ✓
2. Landlord can approve/reject requests with single action ✓
3. Tenant can modify pending or approved requests ✓
4. Landlord can see diff view of modifications ✓
5. Landlord can approve/reject modifications with automatic status reversion on rejection ✓
6. Tenant status automatically transitions to "Active Tenant" upon approval ✓
7. Tenant status automatically transitions to "Inactive" when rental period ends ✓
8. Users are notified of all request/modification decisions ✓
9. Request history is maintained for audit purposes ✓
10. All statuses are consistent and clearly displayed across the application ✓
