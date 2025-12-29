# Feature Specification: Bookings Management System

## User Stories

### User Story 1 - Tenant Viewing Their Booking Requests
**As a tenant**, I want to see all booking requests I've made on other people's apartments, so that I can track the status of my reservations.

**Acceptance Scenarios**:
1. **Given** I'm a logged-in tenant, **When** I navigate to the Bookings screen and select "My Requests" tab, **Then** I should see a list of all my booking requests with their status (pending, approved, rejected)
2. **Given** I have pending booking requests, **When** I view the list, **Then** I should see the apartment details, dates, and total price for each request
3. **Given** I have no booking requests, **When** I view the list, **Then** I should see an empty state message
4. **Given** the list is loading, **When** I view the screen, **Then** I should see a loading indicator instead of a blank page

### User Story 2 - House Owner Viewing Received Bookings
**As a house owner**, I want to see all bookings received for my apartments, so that I can manage my reservations.

**Acceptance Scenarios**:
1. **Given** I'm a logged-in house owner, **When** I navigate to the Bookings screen and select "Received" tab, **Then** I should see a list of all bookings on my apartments with their status
2. **Given** I have bookings on my apartments, **When** I view the list, **Then** I should see tenant details, dates, and total price for each booking
3. **Given** I have no bookings, **When** I view the list, **Then** I should see an empty state message
4. **Given** the list is loading, **When** I view the screen, **Then** I should see a loading indicator instead of a blank page

### User Story 3 - User Canceling Booking Requests
**As a tenant**, I want to be able to cancel my pending booking requests, so that I can withdraw from a reservation.

**Acceptance Scenarios**:
1. **Given** I have a pending booking request, **When** I view it in the "My Requests" tab, **Then** I should see a cancel button
2. **Given** I click the cancel button on a pending request, **When** the action completes, **Then** the request should be removed from my list and a success message should appear
3. **Given** an approved or rejected request, **When** I view it, **Then** I should not see a cancel button

---

## Requirements

### Functional Requirements
1. **View My Booking Requests** (Tenant):
   - API Endpoint: `GET /my-booking-requests`
   - Display all booking requests made by current user
   - Show: apartment title, check-in/check-out dates, total price, status, landlord info
   - Support pagination (20 items per page)
   - Show loading state while fetching
   - Show empty state when no requests

2. **View Received Bookings** (House Owner):
   - API Endpoint: `GET /my-apartment-bookings`
   - Display all confirmed bookings on user's apartments
   - Show: apartment title, check-in/check-out dates, total price, status, tenant info
   - Support pagination (20 items per page)
   - Show loading state while fetching
   - Show empty state when no bookings

3. **Display Data in Both Tabs**:
   - Show booking status with color coding (pending=orange, approved/confirmed=green, rejected/cancelled=red)
   - Display formatted dates (MMM d, y format)
   - Display total price with currency symbol
   - Show calendar and money icons for visual clarity

4. **Error Handling**:
   - Display error messages when API calls fail
   - Provide retry functionality
   - Handle network timeouts gracefully

5. **Refresh Functionality**:
   - Support pull-to-refresh on both tabs
   - Clear loading state after refresh completes

### Data Requirements
- **MyBookings (Bookings table)**: user_id, apartment_id, check_in, check_out, total_price, status
- **MyApartmentBookings (Bookings table)**: apartment_id (with user_id matching current user's apartment's owner)
- **BookingRequests**: user_id, apartment_id, check_in, check_out, status, total_price
- **Related Data**: Apartment details, User/Tenant details

---

## Success Criteria

1. ✅ Bookings screen displays both tabs without showing loading page indefinitely
2. ✅ "My Requests" tab shows all tenant's booking requests with complete information
3. ✅ "Received" tab shows all house owner's apartment bookings with complete information
4. ✅ Both tabs handle empty states gracefully
5. ✅ Error states display with retry option
6. ✅ Pull-to-refresh works on both tabs
7. ✅ All API endpoints return properly formatted data with relationships (apartment, user)
8. ✅ Status badges display with appropriate colors
9. ✅ Dates and prices format correctly on UI
10. ✅ Loading indicators show during initial load and refresh
