# Feature Specification: Owner Cannot Request to Rent Own Property

## User Stories

### User Story 1 - Owner View Their Listed Property
**Acceptance Scenarios**:
1. **Given** Ahmad has listed a house for rent, **When** Ahmad views the house details, **Then** Ahmad should see a "View" or "Manage" button instead of a "Request to Rent" button

### User Story 2 - Other Users Request a Property
**Acceptance Scenarios**:
1. **Given** Ahmad has listed a house for rent, **When** another user (not Ahmad) views the house details, **Then** that user should see a "Request to Rent" button and be able to submit a rental request

### User Story 3 - Owner Cannot Submit Rental Request
**Acceptance Scenarios**:
1. **Given** Ahmad has listed a house for rent, **When** Ahmad attempts to request to rent his own house (via API or UI), **Then** the request should be rejected with an appropriate error message
2. **Given** Ahmad has listed a house for rent, **When** Ahmad is the owner, **Then** the system should prevent the rental request at both client and server level

---

## Requirements

### Functional Requirements
1. **FR-1**: The system must identify the owner of a listed property
2. **FR-2**: The system must prevent the property owner from requesting to rent their own property
3. **FR-3**: The system must allow other users to request to rent any property they do not own
4. **FR-4**: The UI should hide or disable the "Request to Rent" button for property owners when viewing their own properties
5. **FR-5**: The server API should reject rental requests where the requester is the property owner
6. **FR-6**: Users should see appropriate error messages if they attempt to request their own property

### Non-Functional Requirements
1. **NFR-1**: The check for ownership should be performed on both client and server
2. **NFR-2**: The validation should be efficient and not impact existing rental request flow for valid users

---

## Success Criteria

1. ✅ A property owner cannot request to rent their own property via the UI
2. ✅ A property owner cannot request to rent their own property via the API
3. ✅ Other users can still request to rent properties they don't own
4. ✅ The UI correctly displays/hides "Request to Rent" button based on ownership
5. ✅ Server returns appropriate error (e.g., 403 Forbidden or validation error) when owner tries to request their own property
6. ✅ Existing rental requests from non-owners continue to work correctly
