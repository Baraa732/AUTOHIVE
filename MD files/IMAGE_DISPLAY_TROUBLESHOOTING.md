# Image Display Troubleshooting Guide

## ✅ VERIFICATION CHECKLIST

### 1. Check Storage Link
```bash
# Run this command
php artisan storage:link

# Verify the link exists
dir public\storage
```

**Status**: ✅ Storage link exists

### 2. Check Database for Pending Users
```bash
php artisan tinker
```
```php
// Check pending users
$users = App\Models\User::where('status', 'pending')->get();
echo "Pending users: " . $users->count();

// Check a specific user's images
$user = App\Models\User::where('status', 'pending')->first();
if ($user) {
    echo "Profile Image: " . $user->profile_image . "\n";
    echo "ID Image: " . $user->id_image . "\n";
    echo "Profile URL: " . $user->profile_image_url . "\n";
    echo "ID URL: " . $user->id_image_url . "\n";
}
```

**Current Status**: No pending users found

### 3. Test Image Upload via API

Use Postman or similar tool to test registration:

**Endpoint**: `POST http://localhost:8000/api/register`

**Headers**:
```
Accept: application/json
Content-Type: multipart/form-data
```

**Body** (form-data):
```
phone: 0999999999
password: password123
password_confirmation: password123
role: tenant
first_name: Test
last_name: User
birth_date: 1990-01-01
profile_image: [SELECT IMAGE FILE]
id_image: [SELECT IMAGE FILE]
```

### 4. Check Browser Console

1. Open admin dashboard
2. Go to Notifications page
3. Press F12 to open Developer Tools
4. Go to Console tab
5. Look for any errors

### 5. Check Network Tab

1. Open Developer Tools (F12)
2. Go to Network tab
3. Refresh notifications page
4. Look for the request to `/admin/notifications/pending`
5. Click on it and check the Response

**Expected Response**:
```json
{
  "success": true,
  "data": [
    {
      "user": {
        "profile_image_url": "http://localhost/storage/profiles/xxx.jpg",
        "id_image_url": "http://localhost/storage/ids/xxx.jpg"
      }
    }
  ]
}
```

### 6. Verify Image Files Exist

Check if images are actually stored:
```bash
dir storage\app\public\profiles
dir storage\app\public\ids
```

### 7. Check Image Paths in Database

```bash
php artisan tinker
```
```php
$user = App\Models\User::latest()->first();
echo "Profile: " . $user->profile_image . "\n";
echo "ID: " . $user->id_image . "\n";
```

**Expected format**:
- `profiles/xxxxx.jpg`
- `ids/xxxxx.jpg`

## 🔧 COMMON ISSUES & FIXES

### Issue 1: Images Not Uploading
**Symptom**: `profile_image` and `id_image` are NULL in database

**Fix**: Check AuthController registration method
```php
// Should have this code
$profileImagePath = $request->file('profile_image')->store('profiles', 'public');
$idImagePath = $request->file('id_image')->store('ids', 'public');
```

### Issue 2: Storage Link Missing
**Symptom**: 404 error when accessing image URLs

**Fix**:
```bash
php artisan storage:link
```

### Issue 3: Wrong Image Path Format
**Symptom**: Images stored but URLs don't work

**Check**: Database should have:
- ✅ `profiles/filename.jpg` (correct)
- ❌ `storage/profiles/filename.jpg` (wrong)
- ❌ `/storage/profiles/filename.jpg` (wrong)

### Issue 4: Images Not Showing in Frontend
**Symptom**: API returns URLs but images don't display

**Debug**:
1. Open browser console
2. Check for JavaScript errors
3. Verify image URLs in HTML
4. Try opening image URL directly in browser

### Issue 5: CORS Issues
**Symptom**: Images blocked by CORS policy

**Fix**: Add to `.env`
```
APP_URL=http://localhost:8000
```

## 🧪 QUICK TEST

### Test 1: Direct URL Access
Try accessing an image directly:
```
http://localhost:8000/storage/profiles/[filename].jpg
```

If this works, the storage link is correct.

### Test 2: API Response
```bash
curl -X GET http://localhost:8000/admin/notifications/pending \
  -H "Accept: application/json" \
  -H "Cookie: [your-session-cookie]"
```

Check if `profile_image_url` and `id_image_url` are in the response.

### Test 3: JavaScript Console
Open notifications page and run in console:
```javascript
fetch('/admin/notifications/pending', {
    headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
    },
    credentials: 'same-origin'
})
.then(r => r.json())
.then(d => console.log(d));
```

## 📋 STEP-BY-STEP VERIFICATION

### Step 1: Register a Test User
Use mobile app or Postman to register with images

### Step 2: Check Database
```sql
SELECT id, first_name, last_name, profile_image, id_image, status 
FROM users 
WHERE status = 'pending' 
ORDER BY created_at DESC 
LIMIT 1;
```

### Step 3: Check Files
```bash
# Check if files exist
dir storage\app\public\profiles
dir storage\app\public\ids
```

### Step 4: Check Admin Dashboard
1. Login to admin dashboard
2. Go to Notifications page
3. You should see the pending user with images

### Step 5: Check Browser Console
Look for any errors or warnings

## 🎯 EXPECTED BEHAVIOR

When everything works correctly:

1. User registers via mobile app with profile_image and id_image
2. Images are stored in `storage/app/public/profiles/` and `storage/app/public/ids/`
3. Database stores paths: `profiles/xxx.jpg` and `ids/xxx.jpg`
4. Admin sees notification with both images displayed
5. Clicking ID image opens full size in new tab

## 🆘 STILL NOT WORKING?

### Check These Files:

1. **AuthController.php** - Line ~50-60 (image upload code)
2. **NotificationController.php** - Line 76-77 (image URLs in response)
3. **User.php** - Line 79-91 (image URL accessors)
4. **notifications.blade.php** - Line 61-68 (image display HTML)

### Enable Debug Mode

Add to notifications.blade.php before the fetch:
```javascript
console.log('Fetching notifications...');
```

Add after receiving data:
```javascript
console.log('Received data:', data);
if (data.data && data.data[0]) {
    console.log('First user:', data.data[0].user);
    console.log('Profile URL:', data.data[0].user.profile_image_url);
    console.log('ID URL:', data.data[0].user.id_image_url);
}
```

## 📞 CONTACT SUPPORT

If images still don't show after following this guide:
1. Check Laravel logs: `storage/logs/laravel.log`
2. Check browser console for errors
3. Verify file permissions on storage folder
4. Ensure PHP GD extension is installed for image processing
