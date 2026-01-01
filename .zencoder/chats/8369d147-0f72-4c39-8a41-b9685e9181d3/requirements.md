# Feature Specification: Rental Application Management

## User Stories

### User Story 1 - Landlord Reviews Incoming Rental Applications

**Acceptance Scenarios**:

1. **Given** a landlord is logged in, **When** they access the rental applications section, **Then** they see a list of all incoming applications with status badges (pending, approved, rejected, modified-pending, modified-approved)
2. **Given** a landlord views an application, **When** they click on it, **Then** they can see:
   - Complete application details (dates, rent amount, number of tenants, etc.)
   - Full tenant profile (name, email, phone, profile picture, documents)
   - Application history and status timeline
3. **Given** an application is pending or has pending modification, **When** the landlord reviews it, **Then** approve and reject action buttons are visible

---

### User Story 2 - Landlord Approves/Rejects Initial Rental Application

**Acceptance Scenarios**:

1. **Given** a landlord views a pending application, **When** they click "Approve", **Then**:
   - Application status changes to "approved"
   - Tenant becomes associated with the apartment for the specified period
   - A booking is created
   - Modification capability is enabled for the tenant

2. **Given** a landlord views a pending application, **When** they click "Reject", **Then**:
   - Application status changes to "rejected"
   - Tenant cannot modify or reapply through this application
   - A rejection reason can optionally be recorded

---

### User Story 3 - Tenant Modifies Approved/Pending Application

**Acceptance Scenarios**:

1. **Given** a tenant has a pending or approved application, **When** they attempt to modify it, **Then** they can change any application field (dates, rent amount, tenant details, etc.)
2. **Given** a tenant submits a modification, **When** the system processes it, **Then**:
   - Application status changes to "modified-pending"
   - Modification is recorded with previous and new values
   - Landlord can see the modification in their application view

---

### User Story 4 - Landlord Reviews and Responds to Modification

**Acceptance Scenarios**:

1. **Given** a landlord views an application with "modified-pending" status, **When** they click "Approve Modification", **Then**:
   - Application status changes to "modified-approved"
   - Booking is updated with the new modified values
   - Tenant is now bound to the new contract terms
   - No further approvals are needed

2. **Given** a landlord views an application with "modified-pending" status, **When** they click "Reject Modification", **Then**:
   - Application reverts to its previous status with previous data
   - Modification history is preserved (showing it was rejected and why)
   - Tenant can create a new modification if application is still active

---

## Requirements

### Functional Requirements

#### Landlord Dashboard
- **FR1**: Display all incoming rental applications in a list view with status indicators
- **FR2**: Show detailed application modal/screen with complete tenant profile and application details
- **FR3**: Display modification history for applications with visual diff between previous and new values
- **FR4**: Provide action buttons (Approve/Reject) visible on pending and modified-pending applications
- **FR5**: Allow landlord to view and select rejection reason when rejecting

#### Tenant Side
- **FR6**: Allow tenant to modify pending or approved applications
- **FR7**: Show modification status and history in tenant's application view
- **FR8**: Prevent modifications on rejected or completed applications

#### Data & Status Management
- **FR9**: Track application status transitions (pending → approved/rejected, approved → modified-pending → modified-approved/rejected)
- **FR10**: Store modification history with timestamps, old values, new values, and approval status
- **FR11**: Maintain previous data/status for reversion on modification rejection

### UI/UX Requirements
- **UR1**: Action buttons must be clearly visible and contextually appropriate for each status
- **UR2**: Status badges should use consistent color coding (pending=yellow, approved=green, rejected=red, modified=orange)
- **UR3**: Modification diffs should be clearly shown (old value → new value)
- **UR4**: Tenant profile section should be distinct from application details

### Data Privacy
- **DR1**: Landlord can view full tenant profile (email, phone, documents)
- **DR2**: Tenant can only view their own applications and modifications

---

## Success Criteria

1. ✅ Landlord can view all incoming rental applications with status indicators
2. ✅ Landlord can click on an application and see full tenant profile and application details
3. ✅ Landlord can approve a pending application via visible "Approve" button
4. ✅ Landlord can reject a pending application via visible "Reject" button
5. ✅ Tenant can modify a pending or approved application
6. ✅ Modified applications appear in landlord's view with "modified-pending" status
7. ✅ Landlord can approve modifications, updating the booking with new terms
8. ✅ Landlord can reject modifications, reverting application to previous status
9. ✅ Modification history is maintained and visible to both parties
10. ✅ All status transitions are logged with timestamps
