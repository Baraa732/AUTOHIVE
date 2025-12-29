# Bookings Feature - Comprehensive Troubleshooting

## Issue: Bookings Screen Shows Loading Forever

The bookings screen displays a loading indicator indefinitely without showing any data. This guide helps identify and fix the root cause.

---

## 🔍 Root Cause Analysis

The issue could be at any of these layers:

```
┌─────────────────────────────────────────────────────────┐
│ 1. Frontend (Flutter) - UI not updating                │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 2. State Management (Riverpod) - State not changing    │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 3. API Service - Not calling endpoints or parsing fail │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 4. Network/HTTP - Request not reaching backend         │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 5. Backend API - Endpoint not responding correctly     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 6. Database - No data or missing relationships         │
└─────────────────────────────────────────────────────────┘
```

Each layer has specific checkpoints to verify.

---

## ✅ Checkpoint 1: Frontend UI Layer

**Problem**: UI is not responding to state changes

**Check**:
1. In `bookings_screen.dart`, line 41 should show build logs
2. Look for this pattern in console:
   ```
   🎨 BookingsScreen.build - isLoading: true, error: null, bookings: 0, apartmentBookings: 0
   ```
3. Then after loading:
   ```
   🎨 BookingsScreen.build - isLoading: false, error: null, bookings: 5, apartmentBookings: 2
   ```

**If Issue**:
- Loading state never changes from `true` to `false`
- State management layer issue (see checkpoint 2)

**If Okay**:
- Both logs appear and `isLoading` changes
- Continue to checkpoint 2

---

## ✅ Checkpoint 2: State Management Layer (Riverpod)

**Problem**: Provider state not updating

**Check** in console for:
1. `🔵 START: loadAllBookingsData` - Should appear immediately
2. `⏳ Waiting for both bookings APIs...` - Both APIs being called
3. `📱 loadMyBookings API call started` - First API call
4. `📱 loadMyApartmentBookings API call started` - Second API call
5. `✅ Both APIs completed` - Both finished
6. `🟢 FINISH: loadAllBookingsData - SUCCESS` - Completed successfully

**If Issue**:
- Missing any of these logs
- Or `🔴 FINISH: loadAllBookingsData - ERROR` appears
- API service layer issue (see checkpoint 3)

**If Okay**:
- All logs appear in sequence
- Continue to checkpoint 3

---

## ✅ Checkpoint 3: API Service Layer

**Problem**: API calls not working correctly

**Check** in console for:
1. API URL logs:
   ```
   🌐 HTTP GET: http://localhost:8000/api/bookings
   📋 Headers: {Authorization: Bearer ..., Content-Type: application/json}
   ```
2. Status code:
   ```
   ↩️ Status: 200
   ```
3. Response parsing:
   ```
   📦 Body: {"success":true,"data":{"data":[...]
   ✅ Successfully decoded response
   ```

**If Issue**:
- Status code is not 200 (e.g., 401, 404, 500)
- `✅ Successfully decoded response` doesn't appear
- Response body looks wrong
- Network/HTTP layer issue (see checkpoint 4)

**If Okay**:
- Status 200 OK
- Response is decoded
- Continue to checkpoint 4

---

## ✅ Checkpoint 4: Network/HTTP Layer

**Problem**: Request not reaching server or not formatted correctly

**Check**:
1. Verify server is running
2. Verify API URL is correct:
   ```
   http://localhost:8000/api/bookings  // Check this matches your setup
   ```
3. Verify token is being sent in headers
4. Test with manual request (cURL/Postman)

**Test with Postman**:
```
GET http://localhost:8000/api/bookings
Headers:
  Authorization: Bearer YOUR_TOKEN_HERE
  Content-Type: application/json
```

**Expected Response**: 200 OK with JSON

**If Issue**:
- Connection refused (server not running)
- 401 Unauthorized (token invalid)
- 404 Not Found (wrong URL or endpoint doesn't exist)
- 500 Server Error (backend issue)
- Backend API layer issue (see checkpoint 5)

**If Okay**:
- Request succeeds with 200 OK
- Continue to checkpoint 5

---

## ✅ Checkpoint 5: Backend API Layer

**Problem**: Endpoint not returning correct data

**Check Endpoint**: `GET /api/bookings`

**Required Response Structure**:
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": "1",
        "user_id": "2",
        "apartment_id": "5",
        "check_in": "2025-01-15",
        "check_out": "2025-01-20",
        "total_price": "250.00",
        "status": "pending",
        "created_at": "2025-01-01T10:00:00Z",
        "apartment": {
          "id": "5",
          "title": "Luxury Apartment",
          "user_id": "1",
          "user": {
            "id": "1",
            "first_name": "John",
            "last_name": "Owner"
          }
        },
        "user": {
          "id": "2",
          "first_name": "Jane",
          "last_name": "Tenant"
        }
      }
    ],
    "current_page": 1,
    "per_page": 20,
    "total": 10
  },
  "message": "Bookings retrieved successfully"
}
```

**Check**:
1. Response has `success: true`
2. Has `data` field with pagination structure
3. Has `data.data` array (the actual bookings)
4. Each booking has nested `apartment` with nested `user`
5. Each booking has nested `user` (tenant)

**Verify Controller**:
```php
// In BookingController.php line 21:
$query = Booking::with(['apartment.user', 'user'])
    ->where('user_id', $request->user()->id);
```

**Verify Method Exists**:
```php
// Line 15
public function index(Request $request)
{
    // Should exist and be public
}

// Line 333
public function myApartmentBookings(Request $request)
{
    // Should exist and be public
}
```

**If Issue**:
- Wrong response structure
- Missing relationships
- Response has `success: false`
- Database layer issue (see checkpoint 6)

**If Okay**:
- Response structure matches
- All relationships present
- Continue to checkpoint 6

---

## ✅ Checkpoint 6: Database Layer

**Problem**: No data or missing relationships

**Check**:
1. Data exists in tables
2. Foreign keys are correct
3. Relationships are configured

**Test with Laravel Tinker**:
```bash
php artisan tinker

# Check if bookings exist
>>> Booking::count()
=> 5  // Should be > 0

# Check for specific user
>>> Booking::where('user_id', 2)->count()
=> 3  // Should be > 0 for logged-in user

# Check with relationships
>>> Booking::with(['apartment.user', 'user'])->first()
=> Booking {
     id: 1,
     user_id: 2,
     apartment_id: 5,
     apartment: Apartment { ...user... },
     user: User { ... }
   }

# Check apartment bookings (for house owner)
>>> Booking::whereHas('apartment', fn($q) => $q->where('user_id', 1))->count()
=> 2  // Should be > 0 for landlord
```

**If Issue**:
- No bookings in database
- Relationships not returning data
- Create test data (see section below)

**If Okay**:
- Data exists with relationships
- Issue is in one of the layers above

---

## 🛠️ Quick Fixes

### Fix 1: Create Test Data
```bash
php artisan tinker

# Get test user
>>> $user = User::first();

# Get test apartment
>>> $apartment = Apartment::first();

# Create test booking
>>> Booking::create([
  'user_id' => $user->id,
  'apartment_id' => $apartment->id,
  'check_in' => now()->addDays(5),
  'check_out' => now()->addDays(10),
  'total_price' => 500,
  'status' => 'confirmed',
  'payment_details' => ['method' => 'card']
])

# Refresh app and check
```

### Fix 2: Clear App Cache
```bash
flutter clean
flutter pub get
flutter run
```

### Fix 3: Verify API URL
Check `client/lib/core/constants/app_config.dart`:
```dart
class AppConfig {
  static Future<String> get baseUrl async {
    return 'http://YOUR_API_URL/api';  // Should be correct
  }
}
```

### Fix 4: Check Token Validity
```bash
# In app console after login, should see:
📋 Headers: {Authorization: Bearer eyJ...}

# Token should not be null
```

### Fix 5: Check User Approval
```bash
php artisan tinker

>>> $user = User::find(2);
>>> $user->is_approved  // Should be true
=> true
```

---

## 🎯 Step-by-Step Debugging Process

### Step 1: Check Logs
1. Run app with `flutter run -v`
2. Look for `🟢 FINISH` or `🔴 FINISH` in console
3. Note which checkpoint fails

### Step 2: Identify Layer
Based on logs, identify which layer is failing:
- No logs → Checkpoint 1 or 2
- API logs but wrong status → Checkpoint 4
- 200 status but wrong data → Checkpoint 5
- Empty data → Checkpoint 6

### Step 3: Test That Layer
Use the tests in that checkpoint to verify:
- Manually test API with Postman
- Query database with Tinker
- Check configuration files

### Step 4: Fix
Apply the appropriate fix from "Quick Fixes" section

### Step 5: Verify
1. Clear app cache
2. Rebuild and rerun
3. Check console logs again
4. Verify `🟢 FINISH` appears

---

## 📋 Complete Debugging Checklist

**Frontend**:
- [ ] Build logs appear (`🎨 BookingsScreen.build`)
- [ ] `isLoading` changes from `true` to `false`
- [ ] No UI errors in console

**State Management**:
- [ ] `🔵 START: loadAllBookingsData` appears
- [ ] Both API calls start (`📱 loadMyBookings`, `📱 loadMyApartmentBookings`)
- [ ] `🟢 FINISH` appears (either SUCCESS or ERROR)
- [ ] Loading state clears

**API Service**:
- [ ] `🌐 HTTP GET` shows correct URL
- [ ] `↩️ Status: 200` appears
- [ ] `✅ Successfully decoded response` appears
- [ ] No parsing errors (`⚠️ Error parsing`)

**Network**:
- [ ] Server is running
- [ ] API URL is correct
- [ ] Token is being sent in headers
- [ ] No connection errors

**Backend**:
- [ ] Endpoint exists and is public
- [ ] Returns 200 OK with JSON
- [ ] Response has `success: true`
- [ ] Response has nested relationships

**Database**:
- [ ] Bookings table has data
- [ ] Foreign keys are correct
- [ ] Relationships are configured
- [ ] Eloquent models have proper relationships

---

## 🚀 Performance Considerations

If everything works but is slow:

1. **API Response Time**:
   - Check database query performance
   - Add database indexes on foreign keys
   - Verify eager-loading is working

2. **Frontend Rendering**:
   - Check if lists with 100+ items cause slowdown
   - Consider pagination (already implemented)
   - Profile with Flutter DevTools

3. **Network**:
   - Check WiFi/network speed
   - Increase timeout values if needed
   - Consider caching

---

## 📞 Support Information

**If you need help**:
1. Collect all console logs (full `flutter run -v` output)
2. Get API response from Postman
3. Get database query results from Tinker
4. Check Laravel logs in `storage/logs/laravel.log`
5. Share the checkpoint where it fails

This will help identify the exact issue quickly.
