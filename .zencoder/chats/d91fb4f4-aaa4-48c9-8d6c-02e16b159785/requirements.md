# Feature Specification: Apartment Favorites System

## User Stories

### User Story 1 - Add Apartment to Favorites
**Acceptance Scenarios**:
1. **Given** user is viewing an apartment details, **When** user clicks the favorite/heart button, **Then** the apartment is added to favorites and the button visual state changes
2. **Given** user is on the home/listings page, **When** user clicks the favorite button on an apartment card, **Then** the apartment is added to favorites

### User Story 2 - View Favorites List
**Acceptance Scenarios**:
1. **Given** user navigates to the favorites screen, **When** the screen loads, **Then** all favorited apartments are displayed in a list format similar to the home page
2. **Given** user has no favorited apartments, **When** they view favorites screen, **Then** an empty state message is displayed

### User Story 3 - Remove from Favorites
**Acceptance Scenarios**:
1. **Given** user is viewing their favorites list, **When** they click the favorite/heart button on an apartment, **Then** it's removed from favorites and the list updates
2. **Given** user is viewing apartment details of a favorited apartment, **When** they click the heart button, **Then** it's removed from favorites

### User Story 4 - Filter and Sort Favorites
**Acceptance Scenarios**:
1. **Given** user is viewing favorites, **When** they apply filters (price, location, etc.), **Then** the list displays only matching apartments
2. **Given** user is viewing favorites, **When** they sort by price/date/rating, **Then** the list is reordered accordingly

### User Story 5 - Book from Favorites
**Acceptance Scenarios**:
1. **Given** user is viewing favorites list, **When** they tap on an apartment or booking button, **Then** they are taken to apartment details or booking screen
2. **Given** user is on apartment details from favorites, **When** they initiate a booking, **Then** the booking flow proceeds normally

## Requirements

### Functional Requirements
- FR1: Users can add/remove apartments from favorites
- FR2: Favorites are persisted on the backend (database)
- FR3: Users can view their favorited apartments in a dedicated screen
- FR4: Favorites screen displays apartments in the same format as home page
- FR5: Users can filter favorites by criteria (price range, location, amenities, etc.)
- FR6: Users can sort favorites (by date added, price, rating)
- FR7: Users can initiate bookings directly from favorites screen
- FR8: Favorite status is reflected across all screens (home page, details, favorites list)

### Non-Functional Requirements
- NR1: Favorites load within 2 seconds
- NR2: Add/remove favorites completes within 1 second
- NR3: API should paginate results for large favorite lists
- NR4: No landlord/sensitive data leakage in favorites endpoint

## Success Criteria

- [ ] Backend: Favorites API returns apartment data without landlord relationship
- [ ] Backend: Favorites CRUD endpoints work correctly (Add, View, Remove)
- [ ] Backend: Pagination works on GET favorites endpoint
- [ ] Frontend: Favorites screen displays all favorited apartments
- [ ] Frontend: Favorite status updates across all screens (home, details, favorites)
- [ ] Frontend: Filtering and sorting works on favorites screen
- [ ] Frontend: Users can book apartments from favorites screen
- [ ] Frontend: Apartment cards in favorites show same information as home page
- [ ] Error handling: Proper messages shown for failures
- [ ] Performance: No network errors or timeouts
