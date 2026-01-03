# Technical Specification: Rental Application & Approval Workflow

## Technical Context

**Language/Framework**: 
- Backend: PHP 8.x (Laravel 10.x)
- Frontend: Flutter (Dart)
- Database: SQLite (development) / MySQL (production)

**Primary Dependencies**:
- Laravel Sanctum (authentication)
- Laravel Eloquent ORM
- Flutter Riverpod (state management)

**Current Implementation Status**:
- Core rental application workflow exists (submit, approve, reject, modify)
- Modification workflow partially implemented
- Review system exists for apartments (not tenants)
- Notification system in place

---

## Technical Implementation Brief

### Key Technical Decisions

**1. Tenant Profile Visibility**
- Enhance `RentalApplicationController::show()` to load tenant reviews
- Load user profile with verification status (is_approved)
- Fetch tenant's written reviews (to assess their quality as a tenant)
- Average rating calculated from all reviews written by the tenant

**2. Review Data Source**
- Use existing Review model (reviews written by tenant)
- Calculate average rating: `AVG(rating)` from reviews where `user_id = tenant_id`
- Load recent reviews (limit to 5 most recent)
- Display comment/feedback from each review to show landlord's assessment

**3. API Response Structure**
- Enhance existing `/api/rental-applications/{id}` endpoint
- Include nested `user.reviews` and `user.average_rating`
- Add computed fields: review_count, average_rating

**4. Frontend UI Updates**
- Enhanced tenant profile card with review section
- Star rating display with average rating
- Recent reviews list with reviewer's apartment and comment
- "No reviews yet" state for new tenants
- Responsive design for modification review screen

**5. Database Queries**
- Use Laravel eager loading to prevent N+1 queries
- Load reviews with apartment relationship for context
- Cache average rating if needed for performance

---

## Source Code Structure

### Backend Components

**Model Enhancements**:
- `app/Models/User.php` - Add accessor for average_rating
- `app/Models/Review.php` - Ensure relationships are correct

**Controller Enhancements**:
- `app/Http/Controllers/Api/RentalApplicationController.php`
  - Update `show()` method to include user reviews
  - Update `incoming()` method to include user reviews
  
**Service Enhancement**:
- `app/Services/RentalApplicationService.php` - No changes needed

### Frontend Components

**New Widgets**:
- `lib/presentation/widgets/tenant_review_card.dart` - Display single review
- `lib/presentation/widgets/tenant_rating_summary.dart` - Average rating + count

**Modified Screens**:
- `lib/presentation/screens/landlord/rental_application_detail.dart` - Add review section
- `lib/presentation/screens/shared/modification_review_screen.dart` - Show tenant info with reviews
- `lib/presentation/widgets/tenant_profile_card.dart` - Enhance with reviews

**API Service**:
- `lib/core/network/api_service.dart` - No endpoint changes needed (already loads user data)

**Data Models**:
- `lib/data/models/rental_application.dart` - No changes
- Create `lib/data/models/review.dart` if not exists - To parse review data

---

## Contracts

### API Response Contracts

**GET `/api/rental-applications/{id}` - Enhanced Response**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": 5,
    "apartment_id": 10,
    "check_in": "2025-01-15",
    "check_out": "2025-01-20",
    "message": "I love this apartment",
    "status": "pending",
    "submitted_at": "2025-01-10T10:30:00Z",
    "user": {
      "id": 5,
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@example.com",
      "phone": "+20123456789",
      "city": "Cairo",
      "governorate": "Cairo",
      "is_approved": true,
      "profile_image": "...",
      "average_rating": 4.5,
      "review_count": 12,
      "reviews": [
        {
          "id": 101,
          "rating": 5,
          "comment": "Great apartment, very clean",
          "created_at": "2025-01-05T14:20:00Z",
          "apartment": {
            "id": 8,
            "title": "Luxury Downtown Apartment"
          }
        },
        {
          "id": 100,
          "rating": 4,
          "comment": "Good location, responsive landlord",
          "created_at": "2024-12-20T09:15:00Z",
          "apartment": {
            "id": 7,
            "title": "Modern Studio"
          }
        }
      ]
    }
  }
}
```

**GET `/api/rental-applications/incoming` - Enhanced Response**

Same structure as above, applied to all items in the incoming applications list.

### Data Model Contracts

**Review Model** (Dart):
```dart
class Review {
  final int id;
  final double rating;
  final String? comment;
  final String createdAt;
  final Map<String, dynamic>? apartment;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.apartment,
  });

  factory Review.fromJson(Map<String, dynamic> json) { ... }
}
```

---

## Delivery Phases

### Phase 1: Backend Enhancement (Days 1-2)
**Deliverable**: Backend returns tenant reviews with rental applications

1. Update `User` model to add `reviews()` relationship
2. Enhance `RentalApplicationController::show()` to eager load reviews
3. Enhance `RentalApplicationController::incoming()` to eager load reviews
4. Create computed accessor `average_rating` in User model
5. Test API response includes reviews and rating

**MVP Test**: Landlord can call API and receive tenant review data

---

### Phase 2: Tenant Profile Widget (Days 3-4)
**Deliverable**: Frontend displays tenant reviews in application detail screen

1. Create `tenant_review_card.dart` widget
2. Create `tenant_rating_summary.dart` widget
3. Update `rental_application_detail.dart` to include review section
4. Handle "no reviews yet" state
5. Ensure responsive design

**MVP Test**: Open application detail, see tenant reviews with ratings and comments

---

### Phase 3: Modification Review Enhancement (Days 5)
**Deliverable**: Tenant profile visible when reviewing modifications

1. Update `modification_review_screen.dart` to show tenant reviews
2. Enhance `incoming_rental_applications.dart` list to show ratings
3. Polish UI/UX with proper spacing and colors

**MVP Test**: Landlord reviews pending modification and sees tenant's review history

---

### Phase 4: Polish & Testing (Day 6)
**Deliverable**: Complete feature with comprehensive testing

1. Handle edge cases (no reviews, very long reviews, etc.)
2. Verify state management (Riverpod) correctly refreshes
3. Test on multiple screen sizes
4. Verify performance (lazy load reviews if list is long)

---

## Verification Strategy

### Backend Verification (Phase 1)

**Manual API Testing**:
```bash
# Test with Postman/curl
GET /api/rental-applications/1
Authorization: Bearer {tenant-token}

# Verify response includes:
# - user.average_rating (number or null)
# - user.review_count (number)
# - user.reviews (array with id, rating, comment, created_at, apartment)
```

**Unit Test**:
- Create test in `tests/Feature/RentalApplicationControllerTest.php`
- Verify reviews are loaded when calling `show()` method
- Verify reviews are loaded when calling `incoming()` method

**Test Data**:
- Create tenant with 3-5 completed reviews
- Create rental application from that tenant
- Verify API response includes reviews

---

### Frontend Verification (Phases 2-3)

**Widget Tests**:
- Test `tenant_review_card.dart` renders correctly with data
- Test `tenant_rating_summary.dart` displays average rating
- Test "no reviews yet" state displays properly

**Integration Test**:
- Navigate to rental application detail screen
- Verify review section displays
- Verify review cards render with rating and comment
- Test with different data (no reviews, many reviews, etc.)

**Visual Verification**:
- Open `rental_application_detail.dart` on:
  - iPhone 12 (390px width)
  - iPad (768px width)
  - Android (360px width)
- Verify no overflow, text wraps properly
- Verify colors match existing theme

**Test Scenarios**:
1. ✅ Tenant with 5 reviews → All 5 displayed
2. ✅ Tenant with 0 reviews → "No reviews yet" message
3. ✅ Tenant with very long review comment → Text truncated/ellipsis
4. ✅ Tenant with low rating (2.5 stars) → Rating clearly visible
5. ✅ Tenant with high rating (4.8 stars) → Rating clearly visible

---

### Testing Tools & Artifacts

**No external MCP servers required** - Use existing Laravel/Flutter test frameworks

**Helper Scripts** (if needed):
- Create seed script to generate test tenants with reviews:
  - `database/seeders/TenantReviewSeeder.php`
  - Generates 10 test tenants with 2-8 reviews each
  - Use existing `ReviewFactory` and `ReviewFactory` factories

**Test Data Artifacts**:
- Use Laravel factories (already exist)
- No special data files needed

**Verification Command**:
```bash
# Backend
php artisan test tests/Feature/RentalApplicationControllerTest.php

# Frontend
flutter test test/presentation/screens/landlord/rental_application_detail_test.dart
```

---

## Performance Considerations

- Reviews should be eager loaded (not lazy loaded) to prevent N+1 queries
- Limit reviews display to most recent 5 (configurable)
- Consider caching `average_rating` if tenant has many reviews (100+)
- Frontend: Use Riverpod caching for application list (already implemented)

---

## Security Considerations

- ✅ Landlord can only see reviews of tenants applying to their apartments (existing controller check)
- ✅ Reviews are already public data (anyone can view apartment reviews)
- ✅ No sensitive tenant information exposed beyond what's already visible
- ✅ Authorization already enforced in `RentalApplicationController`

