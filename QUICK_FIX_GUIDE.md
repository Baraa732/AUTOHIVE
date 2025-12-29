# Bookings Loading Issue - Quick Debugging Guide

## ⚠️ Current Issue
Bookings screen is stuck on loading page with no data showing.

## 🔍 Step 1: Check Console Logs

1. **Run the app with verbose logging**:
   ```bash
   flutter run -v
   ```

2. **Look for these log messages in the console**:
   - ✅ `🔵 START: loadAllBookingsData` - Should appear when screen loads
   - ✅ `📱 loadMyBookings API call started` - API call started
   - ✅ `📡 API response received` - Got response from API
   - ✅ `Full Response: {...}` - What the API returned
   - ✅ `🟢 FINISH: loadAllBookingsData - SUCCESS` - Loading finished

   **If you see**:
   - ❌ `🔴 FINISH: loadAllBookingsData - ERROR BUT LOADING STATE CLEARED` - APIs failed but loading stopped
   - ❌ Nothing after `loadMyBookings API call started` - API didn't respond
   - ❌ Parsing errors - Data format issue

## 🔧 Step 2: Test the API Endpoint Directly

### Using Postman:
1. **Open Postman**
2. **Create new request**:
   - Method: `GET`
   - URL: `http://YOUR_API_URL/api/bookings`
   - Headers:
     ```
     Authorization: Bearer YOUR_TOKEN_HERE
     Content-Type: application/json
     ```
3. **Click Send**
4. **Observe Response**:
   - Should get 200 OK
   - Response should look like:
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
             "apartment": {...},
             "user": {...}
           }
         ],
         "current_page": 1,
         "per_page": 20,
         "total": 1
       },
       "message": "Bookings retrieved successfully"
     }
     ```

### Using cURL:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     http://YOUR_API_URL/api/bookings
```

**Expected Response Status**: 200 OK
**Expected Field `success`**: `true`

---

## 🎯 Step 3: Check Database

### Check if bookings exist:
```bash
# SSH into server or use Laravel Tinker
php artisan tinker

# Check bookings for current user (assuming user_id = 2)
>>> Booking::where('user_id', 2)->count()
=> 5  // Should return number > 0

# Check with relationships
>>> Booking::where('user_id', 2)->with(['apartment.user', 'user'])->first()
=> ... // Should show booking with nested relationships
```

### If no bookings exist:
- **Option 1**: Create test data in database
- **Option 2**: Create a booking request through the app UI on another account

---

## 📱 Step 4: Check Frontend Logs

When running the app, check for:

1. **Loading state logs**:
   ```
   🎨 BookingsScreen.build - isLoading: true, error: null, bookings: 0, apartmentBookings: 0
   ```
   This is normal during initial load.

2. **After APIs respond**:
   ```
   🎨 BookingsScreen.build - isLoading: false, error: null, bookings: 5, apartmentBookings: 2
   ```
   This means success - should see data now.

3. **If you see**:
   ```
   🎨 BookingsScreen.build - isLoading: false, error: null, bookings: 0, apartmentBookings: 0
   ```
   Both lists are empty - either no data in DB or API returned empty.

---

## 🚨 Common Issues & Fixes

### Issue 1: 401 Unauthorized Error
**Symptom**: Console shows `401` status code
**Cause**: Token is invalid or expired
**Fix**:
1. Log out completely
2. Clear app cache: `flutter clean && flutter pub get`
3. Log in again
4. Retry bookings screen

### Issue 2: 404 Not Found
**Symptom**: Console shows `404` status code
**Cause**: API endpoint doesn't exist
**Fix**:
1. Verify routes are registered in `server/routes/api.php`
2. Check that controller methods exist:
   - `BookingController@index` for GET /api/bookings
   - `BookingController@myApartmentBookings` for GET /api/my-apartment-bookings

### Issue 3: API Returns Empty Array
**Symptom**: Response shows `data: {data: []}`
**Cause**: No bookings in database for this user
**Fix**:
1. Create test bookings in database, OR
2. Use another user account that has bookings, OR
3. Create a booking request through the app

### Issue 4: API Returns success: false
**Symptom**: Response shows `success: false`
**Cause**: Backend error
**Fix**:
1. Check Laravel logs: `storage/logs/laravel.log`
2. Look for error messages
3. Check if user is authenticated and approved

### Issue 5: Parsing Error
**Symptom**: Console shows `⚠️ Error parsing booking:`
**Cause**: API response structure doesn't match expected format
**Fix**:
1. Compare API response with expected structure
2. Check if `apartment` and `user` fields are present
3. Verify data types match (dates should be strings, prices should be numbers)

---

## 🧪 Step 5: Create Sample Test Data

If database is empty, create test bookings:

```bash
php artisan tinker

# Create a user (if needed)
>>> $user = User::where('email', 'test@example.com')->first();

# Create an apartment (if needed)
>>> $apartment = Apartment::first();

# Create test booking
>>> Booking::create([
  'user_id' => $user->id,
  'apartment_id' => $apartment->id,
  'check_in' => '2025-02-01',
  'check_out' => '2025-02-05',
  'total_price' => 500,
  'status' => 'confirmed',
  'payment_details' => ['method' => 'card']
])
=> Booking {#123 ...}

# Verify
>>> Booking::where('user_id', $user->id)->count()
=> 1
```

Then refresh the app and check if data appears.

---

## 💡 Step 6: Enable Enhanced Debugging

Add this to your app temporarily to get better logs:

1. Open `client/lib/presentation/providers/booking_provider.dart`
2. The file already has enhanced logging - just check the console

The following logs help debug:
- `📱 loadMyBookings API call started` - Request initiated
- `📡 API response received` - Response received
- `Full Response: {...}` - Complete response JSON
- `🔍 Data type:` - What type of data was returned
- `✅ Loaded X bookings` - Success
- `⚠️ API error:` - API returned error
- `❌ Exception:` - Code threw exception

---

## ✅ Checklist for Fixing

- [ ] Check console logs (look for error messages)
- [ ] Test API endpoint with Postman/cURL
- [ ] Verify database has bookings data
- [ ] Check if token is valid (not expired)
- [ ] Verify user is approved (if required)
- [ ] Check Laravel logs for backend errors
- [ ] Verify relationships are loaded in API
- [ ] Clear app cache and rebuild
- [ ] Try with different user account
- [ ] Check network connectivity

---

## 📊 Expected Console Output (Success Case)

```
🔵 START: loadAllBookingsData
⏳ Waiting for both bookings APIs...
  📱 loadMyBookings API call started
    🌐 HTTP GET: http://localhost:8000/api/bookings
    📋 Headers: {Authorization: Bearer ..., Content-Type: application/json}
  📡 API response received
    ↩️ Status: 200
    📦 Body: {"success":true,"data":{"data":[...]...
    ✅ Successfully decoded response
  🔍 Data type: _InternalLinkedHashMap<String, dynamic>
  ➡️ Data is a paginated Map
  ✅ Loaded 5 user bookings
  📱 loadMyApartmentBookings API call started
    🌐 HTTP GET: http://localhost:8000/api/my-apartment-bookings
  📡 API response received
    ✅ Successfully decoded response
  🔍 Data type: _InternalLinkedHashMap<String, dynamic>
  ➡️ Data is a paginated Map
  ✅ Loaded 3 apartment bookings
✅ Both APIs completed
📊 Current state: bookings=5, apartmentBookings=3
🎯 Has data: true
🟢 FINISH: loadAllBookingsData - SUCCESS
🎨 BookingsScreen.build - isLoading: false, error: null, bookings: 5, apartmentBookings: 3
```

If you see this pattern, the feature is working correctly and bookings should display!

---

## 🆘 Still Having Issues?

If none of the above fixes the problem:

1. **Collect all console logs** - Full output from "flutter run -v"
2. **API response JSON** - Paste actual response from Postman
3. **Database query results** - Run the tinker commands above
4. **Laravel error logs** - Check `storage/logs/laravel.log`
5. **API endpoint status** - Confirm controller methods exist

Then review the logs to identify the exact point of failure.

---

## 🎯 Quick Test

**Fastest way to test if it's working:**

1. Open your app (bookings screen loading)
2. Open browser DevTools/Flutter DevTools
3. Look at console output
4. Search for: "🟢 FINISH: loadAllBookingsData - SUCCESS"
   - **Found?** → Feature is working, data might be empty
   - **Not found?** → Look for errors above it

5. Search for: "✅ Loaded X user bookings"
   - **Found with X > 0?** → Data exists
   - **Found with X = 0?** → No data in database
   - **Not found?** → API error or parsing issue
