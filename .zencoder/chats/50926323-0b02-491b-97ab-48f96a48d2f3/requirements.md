# Feature Specification: Favorite Apartments Screen

## User Stories

### User Story 1 - Browse Favorite Apartments
**Acceptance Scenarios**:
1. **Given** a user has favorited apartments, **When** they navigate to the favorites screen, **Then** they see a list of all their favorited apartments with key details (image, name, price, location)
2. **Given** a user has no favorited apartments, **When** they navigate to the favorites screen, **Then** they see an empty state message with a link to browse apartments
3. **Given** a user is viewing the favorites screen, **When** they see the favorite count badge, **Then** it only displays if they have at least 1 favorite

### User Story 2 - Control Favorite Apartments
**Acceptance Scenarios**:
1. **Given** a user is viewing the favorites screen, **When** they click on an apartment, **Then** they see full apartment details (same as home page)
2. **Given** a user is viewing the favorites screen, **When** they use filter/sort options, **Then** they can filter by price/location/amenities and sort results
3. **Given** a user is viewing the favorites screen, **When** they click the share button on an apartment, **Then** they can share the apartment details via available sharing methods
4. **Given** a user is viewing the favorites screen, **When** they click the remove button on an apartment, **Then** they are asked to confirm before removal

### User Story 3 - Book from Favorites
**Acceptance Scenarios**:
1. **Given** a user is viewing a favorited apartment details, **When** they click the "Book Now" button, **Then** they enter the same booking flow as from the home page
2. **Given** a user completes a booking from a favorite apartment, **When** the booking is confirmed, **Then** they see a success message and the apartment remains in their favorites

### User Story 4 - Manage Favorites
**Acceptance Scenarios**:
1. **Given** a user removes an apartment from favorites, **When** they confirm the removal, **Then** the apartment is deleted from the favorites list and the counter updates
2. **Given** a user has multiple favorites, **When** they use the filter and sort options, **Then** the count badge reflects the total number of favorites, not the filtered count

---

## Requirements

### Functional Requirements
- Display all user-favorited apartments in a dedicated screen
- Each apartment card should show: image, name, price, location, and rating
- Implement filter functionality by price range, location, and amenities
- Implement sort functionality (price low-to-high, high-to-low, newest, oldest)
- Display share button on each apartment card
- Display remove/unfavorite button on each apartment card with confirmation dialog
- Implement a "Book Now" button that follows the same booking flow as the home page
- Display empty state when user has no favorited apartments
- Show favorite counter badge (visible only when count > 0)
- Persist favorite selections across sessions

### Non-Functional Requirements
- Favorite screen should load within 2 seconds
- UI should be responsive on mobile, tablet, and desktop
- Maintain consistency with home page styling and controls
- Handle edge cases (network errors, deleted apartments, etc.)

---

## Success Criteria

- [x] Favorite screen displays all user-favorited apartments
- [x] Users can view full apartment details from favorites
- [x] Users can filter apartments by price, location, and amenities
- [x] Users can sort apartments by relevant criteria
- [x] Users can share apartment details
- [x] Users can remove apartments from favorites with confirmation
- [x] Users can book apartments using the same flow as home page
- [x] Empty state is shown when no favorites exist
- [x] Favorite counter badge displays only when count > 0
- [x] All controls and interactions are identical to home page where applicable
- [x] Performance meets response time requirements
