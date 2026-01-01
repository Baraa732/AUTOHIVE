# Technical Specification: Apartment Favorites System

## Technical Context

- **Backend**: Laravel 10+ with Eloquent ORM
- **Frontend**: Flutter with Riverpod state management
- **API**: RESTful API using sanctum authentication
- **Database**: SQLite (development) / MySQL (production)
- **Architecture**: Clean architecture with Models, Controllers, and Providers

## Technical Implementation Brief

### Key Issues to Fix

1. **Backend Error**: FavoriteController line 13 attempts to load `apartment.landlord` relationship which doesn't exist on Apartment model
2. **Fix**: Remove the landlord relationship and return only apartment data with user-facing fields
3. **Frontend**: Already has proper structure, needs filtering/sorting enhancements

### Architecture Decisions

- **Response Format**: Return paginated Favorite objects with nested Apartment data
- **Relationships**: Use only existing Eloquent relationships (apartment)
- **Frontend State**: Continue using Riverpod with FavoriteState
- **Filtering/Sorting**: Implement on frontend for simplicity; backend pagination handles data limits

## Source Code Structure

### Backend
```
server/
├── app/
│   ├── Models/
│   │   ├── Apartment.php (has relationship)
│   │   └── Favorite.php
│   ├── Http/
│   │   └── Controllers/Api/
│   │       └── FavoriteController.php (needs fix)
│   └── Resources/
│       └── FavoriteResource.php (if created)
└── routes/
    └── api.php (already has endpoints)
```

### Frontend
```
client/lib/
├── data/
│   └── models/
│       ├── favorite.dart
│       └── apartment.dart
├── presentation/
│   ├── providers/
│   │   └── favorite_provider.dart
│   └── screens/shared/
│       └── favorites_screen.dart
└── core/network/
    └── api_service.dart
```

## Contracts

### API Response Contract
**GET /api/favorites** (paginated)
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "user_id": 123,
        "apartment_id": 456,
        "created_at": "2025-01-01T10:00:00Z",
        "apartment": {
          "id": 456,
          "user_id": 789,
          "title": "Modern Apartment",
          "description": "...",
          "address": "...",
          "governorate": "Cairo",
          "city": "Heliopolis",
          "price_per_night": 100,
          "bedrooms": 2,
          "bathrooms": 1,
          "area": 85.5,
          "images": ["url1", "url2"],
          "features": ["wifi", "ac"],
          "is_available": true,
          "is_approved": true,
          "status": "approved",
          "rating": 4.5
        }
      }
    ],
    "per_page": 10,
    "total": 15,
    "last_page": 2
  }
}
```

### Model Updates
- **Favorite Model**: No changes needed
- **Apartment Model**: No changes needed
- **FavoriteController**: Remove `.with('apartment.landlord')` and use `.with('apartment')`

### Frontend Filter/Sort Logic
- Filters: price_min, price_max, bedrooms, bathrooms, governorate, city
- Sorting: date_added (desc), price (asc/desc), rating (asc/desc)
- Implementation: In-memory filtering on favorites list

## Delivery Phases

### Phase 1: Fix Backend Relationship Error
**Deliverable**: Backend returning correct apartment data without landlord relationship
- Fix FavoriteController::index() to remove landlord loading
- Ensure API returns proper pagination structure
- Verify no errors in responses

**Contracts**: API Response Contract

**Verification**: 
```bash
# Test GET /api/favorites endpoint returns valid response
# No RelationNotFoundException in logs
# Response follows contract structure
```

### Phase 2: Enhance Frontend Favorites Display
**Deliverable**: Favorites screen displaying apartments similar to home page with all necessary details
- Ensure apartment cards show price, location, bedrooms, bathrooms, rating
- Add ability to navigate to apartment details
- Add ability to remove from favorites
- Proper error handling and empty state

**Contracts**: Frontend model mappings, Riverpod provider state

**Verification**:
```bash
# Favorites screen loads without errors
# Apartment cards display all required info
# Navigation to details works
# Remove from favorites updates UI
```

### Phase 3: Add Filtering and Sorting
**Deliverable**: Filters and sorting options on favorites screen
- Add price range filter
- Add bedroom/bathroom filter
- Add location filter (governorate/city)
- Add sorting options (date, price, rating)
- Filter state management in provider
- UI with chips/bottom sheet for filters

**Contracts**: Enhanced FavoriteState with filter/sort parameters

**Verification**:
```bash
# Filters update favorites list correctly
# Sorting reorders list as expected
# Filter state persists during navigation
# Performance acceptable with large lists
```

### Phase 4: Add Booking from Favorites
**Deliverable**: Ability to book apartments directly from favorites screen
- Add booking button to apartment card
- Navigation to booking screen with apartment pre-selected
- Success notification after booking

**Contracts**: Integration with existing BookingProvider

**Verification**:
```bash
# Booking button navigates to booking screen
# Apartment data passed correctly
# Booking can be completed from favorites
```

## Verification Strategy

### Backend Verification

1. **Relationship Fix Verification**
```bash
# Run in Laravel shell
php artisan tinker
>>> $fav = Favorite::with('apartment')->first();
>>> dump($fav->apartment);
```

2. **API Endpoint Test**
```bash
# Using curl/Postman
GET http://localhost:8000/api/favorites
Authorization: Bearer {token}
# Should return 200 with proper structure
```

3. **Database Check**
```bash
# Verify no landlord relationship exists
# Check Apartment model relationships only include: user, bookings, reviews, favorites
```

### Frontend Verification

1. **Unit Tests**
- Test Favorite.fromJson() parsing
- Test FavoriteNotifier state management
- Test filter/sort logic

2. **Widget Tests**
- Test FavoritesScreen renders correctly
- Test empty state
- Test error state
- Test favorites list display

3. **Integration Tests**
- Test load favorites flow
- Test add/remove from favorites flow
- Test navigation to details
- Test filtering/sorting

4. **Manual Testing Checklist**
- [ ] Load favorites screen - no crashes
- [ ] Favorites list displays apartments with images
- [ ] Remove favorite updates UI immediately
- [ ] Filter by price works
- [ ] Sort by date/price/rating works
- [ ] Navigate to apartment details
- [ ] Book apartment from favorites

### Helper Scripts Needed

1. **test-favorites-api.sh** - Script to test favoriteAPI endpoints with sample data
2. **Migration to add test data** - Create sample apartments for testing

