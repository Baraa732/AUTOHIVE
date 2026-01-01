# Technical Specification: Enhanced Favorites Screen

## Technical Context

**Backend**: Laravel 12 with JWT Authentication (tymon/jwt-auth)
- ORM: Eloquent
- API: RESTful with Sanctum middleware
- Database: SQL with migrations

**Frontend**: Flutter with Riverpod State Management
- Language: Dart 3.10+
- Key packages: flutter_riverpod (2.4.9), dio (5.4.0)
- Architecture: BLoC-inspired with Riverpod providers

**Existing Infrastructure**:
- Favorite model and controller already exist
- API routes for favorites already defined (/api/favorites)
- Basic favorites screen exists but lacks filtering, sorting, and full controls
- ApartmentDetailsScreen handles favorite toggling
- Authentication via JWT with approved user middleware

---

## Technical Implementation Brief

The favorites feature already has a foundation (database model, API endpoints, basic UI). The implementation focuses on **enhancing the existing favorites screen** with:

1. **Advanced Filtering**: Price range, location (governorate/city), amenities/features
2. **Sorting**: By price, date added, availability status
3. **Full Controls**: View details, share, remove with confirmation, book
4. **Consistency**: Match home page controls and styling
5. **Caching & Performance**: Efficient API calls with pagination support
6. **Empty States**: Clear messaging when no favorites exist

**Key Technical Decisions**:
- Reuse existing `favoriteProvider` and extend it with filtering/sorting state
- Leverage FavoriteController's pagination capability (10 per page)
- Maintain favorites list in local state with remote sync
- Use same booking flow as apartment details screen
- Follow existing design patterns (ConsumerStatefulWidget, Riverpod StateNotifier)

---

## Source Code Structure

### Backend Changes
```
server/
├── app/
│   ├── Models/
│   │   └── Favorite.php (existing - no changes)
│   ├── Http/
│   │   ├── Controllers/Api/
│   │   │   ├── FavoriteController.php (existing - enhance pagination)
│   │   │   └── SearchController.php (reuse filter logic)
│   │   └── Requests/
│   │       └── (validation handled in controller)
│   └── Services/
│       └── (optional - consider adding FavoriteService for complex queries)
└── routes/
    └── api.php (existing routes - no changes)
```

### Frontend Changes
```
client/lib/
├── presentation/
│   ├── screens/shared/
│   │   ├── favorites_screen.dart (ENHANCE - add filters, sorting, controls)
│   │   ├── apartment_details_screen.dart (existing - no changes)
│   │   └── create_booking_screen.dart (existing - reuse)
│   ├── providers/
│   │   ├── favorite_provider.dart (EXTEND - add filter/sort state)
│   │   └── (other providers)
│   └── widgets/
│       ├── common/
│       └── (reuse existing apartment card widgets)
├── data/
│   ├── models/
│   │   ├── favorite.dart (existing)
│   │   └── apartment.dart (existing)
│   └── providers/
│       └── (API calls via ApiService)
└── core/
    ├── network/
    │   └── api_service.dart (existing - reuse getFavorites)
    └── utils/
        └── (share functionality)
```

---

## Contracts

### Data Models (No Changes Required)

#### Favorite Model (Backend)
```php
{
  "id": "integer",
  "user_id": "integer",
  "apartment_id": "integer",
  "apartment": { /* Apartment object */ },
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

#### Apartment Model (Frontend)
```dart
Apartment {
  id: String,
  title: String,
  price: double,
  bedrooms: int,
  bathrooms: int,
  city: String,
  governorate: String,
  images: List<String>,
  features: List<String>,
  isAvailable: bool,
  // ... other fields
}
```

### API Contracts (Existing - Minor Enhancement)

#### GET /api/favorites (Existing)
**Request**:
```
GET /api/favorites?page=1
Authorization: Bearer {token}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": "1",
        "user_id": "5",
        "apartment_id": "10",
        "apartment": { /* full apartment data */ },
        "created_at": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 5,
      "total": 42
    }
  }
}
```

#### POST /api/favorites (Existing)
**Request**:
```json
{
  "apartment_id": "10"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Added to favorites",
  "data": { /* favorite object */ }
}
```

#### DELETE /api/favorites/{id} (Existing)
**Response**:
```json
{
  "success": true,
  "message": "Removed from favorites"
}
```

### Frontend State Management

#### Enhanced FavoriteState
```dart
class FavoriteState {
  final List<Favorite> favorites;          // All loaded favorites
  final List<Favorite> filtered;           // Filtered/sorted favorites
  final bool isLoading;
  final String? error;
  
  // Filter state
  final double minPrice;
  final double maxPrice;
  final String selectedGovernorate;        // 'All' or specific value
  final String selectedCity;               // 'All' or specific value
  final List<String> selectedFeatures;
  
  // Sort state
  final String sortBy;                     // 'newest', 'oldest', 'price_low', 'price_high'
  
  // Pagination
  final int currentPage;
  final int lastPage;
  final int totalCount;
}
```

---

## Delivery Phases

### Phase 1: Enhance FavoriteProvider with Filtering & Sorting
**Deliverable**: Extended Riverpod state management with filter/sort capabilities
- Add filter state (price, location, features)
- Add sort state and logic
- Implement filter/sort application methods
- Maintain pagination state
- Keep API calls efficient (only full reload when necessary)

**Files to Modify**: `client/lib/presentation/providers/favorite_provider.dart`

### Phase 2: Enhanced Favorites Screen UI
**Deliverable**: Full-featured favorites screen with controls and responsiveness
- Add expandable filter panel (price, governorate, city, features)
- Add sort dropdown
- Display favorite count badge
- Implement apartment cards with all controls (view, share, remove, book)
- Add empty state with call-to-action
- Add refresh indicator for manual refresh
- Implement confirmation dialog for removal

**Files to Modify**: `client/lib/presentation/screens/shared/favorites_screen.dart`

### Phase 3: Integration with Booking Flow
**Deliverable**: Book from favorites using existing booking screen
- "Book Now" button navigates to ApartmentDetailsScreen (existing)
- User can proceed with same booking flow
- After booking, favorite persists

**Files**: No new files - reuse existing create_booking_screen.dart

### Phase 4: Share Functionality
**Deliverable**: Share apartment details from favorites
- Add share button on each apartment card
- Implement share intent (uses Flutter's Share plugin)
- Share apartment title, price, location, link

**Files to Modify**: `client/lib/presentation/screens/shared/favorites_screen.dart`

### Phase 5: Testing & Verification
**Deliverable**: Verify all features work end-to-end
- Manual testing on device/emulator
- Test filter combinations
- Test sorting accuracy
- Test removal with confirmation
- Test booking flow
- Test share functionality
- Verify empty state

---

## Verification Strategy

### Unit Tests (Dart/Flutter)
Create unit tests in `client/test/` (if test directory exists):
```bash
# Test the favorite provider logic
flutter test test/presentation/providers/favorite_provider_test.dart

# Test filtering logic
flutter test test/utils/filter_helper_test.dart

# Test sorting logic
flutter test test/utils/sort_helper_test.dart
```

### Manual Testing Checklist
1. **Load & Display**:
   - Navigate to favorites screen
   - Verify list loads and displays apartments
   - Verify empty state shows when no favorites
   - Verify favorite count badge displays (only if > 0)

2. **Filtering**:
   - Filter by price range (select multiple ranges)
   - Filter by governorate/city
   - Filter by features/amenities
   - Verify filtered results update correctly
   - Verify count badge shows total (not filtered count)

3. **Sorting**:
   - Sort by newest/oldest
   - Sort by price low-to-high and high-to-low
   - Verify sort order matches expectations

4. **Controls**:
   - Click apartment card → navigates to details
   - Click remove button → shows confirmation dialog
   - Confirm removal → apartment disappears from list
   - Click share button → share intent dialog appears
   - Share → content can be shared to messaging apps

5. **Booking**:
   - Click "Book Now" → navigates to apartment details with booking button
   - Complete booking flow → returns to favorites
   - Verify apartment remains in favorites after booking

6. **Performance**:
   - Verify screen loads within 2 seconds
   - Verify smooth scrolling on list
   - Verify no lag during filtering/sorting

### API Testing
Use Postman collection (AUTOHIVE_API_Complete.postman_collection.json):
1. Call GET /api/favorites → verify paginated response
2. Call POST /api/favorites → verify can add
3. Call DELETE /api/favorites/{id} → verify can remove

### Helper Scripts (if complex testing needed)
- None required for MVP - all testing is manual/UI based
- Future: Add E2E test automation with integration_test package

### Sample Data/Artifacts
- Use existing test apartments from the database
- Ensure logged-in user has 3+ favorites before testing
- Test with both empty favorites and populated favorites

### MCP Servers
- No additional MCP servers required
- Use built-in Flutter testing and bash commands

