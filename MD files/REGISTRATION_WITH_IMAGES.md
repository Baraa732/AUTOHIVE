# User Registration with Images

## Overview
Landlord and tenant users MUST provide `profile_image` and `id_image` during registration.

---

## Registration Endpoint

### POST /api/register

**Content-Type**: `multipart/form-data`

### Required Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| phone | string | ✅ | User's phone number (unique) |
| password | string | ✅ | Password (min 6 characters) |
| password_confirmation | string | ✅ | Password confirmation |
| role | string | ✅ | Must be "tenant" or "landlord" |
| first_name | string | ✅ | User's first name |
| last_name | string | ✅ | User's last name |
| birth_date | date | ✅ | Birth date (YYYY-MM-DD) |
| profile_image | file | ✅ | Profile image (max 2MB) |
| id_image | file | ✅ | ID/Passport image (max 2MB) |

---

## Postman Setup

### Step 1: Create New Request
1. Method: `POST`
2. URL: `http://localhost:8000/api/register`
3. Body Type: `form-data`

### Step 2: Add Form Fields

| Key | Type | Value |
|-----|------|-------|
| phone | Text | 1234567890 |
| password | Text | password123 |
| password_confirmation | Text | password123 |
| role | Text | tenant |
| first_name | Text | John |
| last_name | Text | Doe |
| birth_date | Text | 1990-01-01 |
| profile_image | File | [Select image file] |
| id_image | File | [Select image file] |

### Step 3: Send Request

**Success Response (201):**
```json
{
    "success": true,
    "message": "Registration successful. Awaiting admin approval.",
    "data": {
        "user": {
            "id": 1,
            "phone": "1234567890",
            "role": "tenant",
            "first_name": "John",
            "last_name": "Doe",
            "birth_date": "1990-01-01",
            "profile_image": "profiles/abc123.jpg",
            "id_image": "ids/xyz789.jpg",
            "is_approved": false,
            "status": "pending",
            "created_at": "2025-01-01T10:00:00.000000Z"
        }
    }
}
```

**Error Response (422) - Missing Images:**
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "profile_image": ["The profile image field is required."],
        "id_image": ["The id image field is required."]
    }
}
```

---

## cURL Example

```bash
curl -X POST http://localhost:8000/api/register \
  -F "phone=1234567890" \
  -F "password=password123" \
  -F "password_confirmation=password123" \
  -F "role=tenant" \
  -F "first_name=John" \
  -F "last_name=Doe" \
  -F "birth_date=1990-01-01" \
  -F "profile_image=@/path/to/profile.jpg" \
  -F "id_image=@/path/to/id.jpg"
```

---

## Image Requirements

### Profile Image
- **Format**: JPG, PNG, GIF
- **Max Size**: 2MB (2048KB)
- **Recommended**: Square image, at least 200x200px
- **Stored in**: `storage/app/public/profiles/`

### ID Image
- **Format**: JPG, PNG, GIF
- **Max Size**: 2MB (2048KB)
- **Content**: Government-issued ID or passport
- **Stored in**: `storage/app/public/ids/`

---

## Validation Rules

```php
'profile_image' => 'required|image|max:2048',
'id_image' => 'required|image|max:2048',
```

**Accepted formats**: jpg, jpeg, png, bmp, gif, svg, webp

---

## Testing in Postman

### 1. Prepare Test Images
- Create or download 2 test images
- Ensure they're under 2MB each
- One for profile, one for ID

### 2. Configure Request
```
POST http://localhost:8000/api/register
Body: form-data

Fields:
✅ phone: 1234567890
✅ password: password123
✅ password_confirmation: password123
✅ role: tenant
✅ first_name: John
✅ last_name: Doe
✅ birth_date: 1990-01-01
✅ profile_image: [File] Select image
✅ id_image: [File] Select image
```

### 3. Send Request
- Click "Send"
- User will be created with status "pending"
- Images will be uploaded to storage
- Admin receives real-time notification

---

## What Happens After Registration

1. ✅ User created with `is_approved=false`, `status=pending`
2. ✅ Profile image saved to `storage/app/public/profiles/`
3. ✅ ID image saved to `storage/app/public/ids/`
4. ✅ Notification sent to ALL admins
5. ✅ Real-time broadcast to admin channels
6. ⏳ User waits for admin approval

---

## Admin Review Process

Admins can:
1. View pending users: `GET /api/admin/pending-users`
2. See user details including images
3. Approve user: `POST /api/admin/approve-user/{id}`
4. Reject user: `POST /api/admin/reject-user/{id}`

---

## Accessing Uploaded Images

### Profile Image URL
```
http://localhost:8000/storage/profiles/filename.jpg
```

### ID Image URL
```
http://localhost:8000/storage/ids/filename.jpg
```

**Note**: Make sure storage is linked:
```bash
php artisan storage:link
```

---

## Error Handling

### Missing profile_image
```json
{
    "errors": {
        "profile_image": ["The profile image field is required."]
    }
}
```

### Missing id_image
```json
{
    "errors": {
        "id_image": ["The id image field is required."]
    }
}
```

### Image too large
```json
{
    "errors": {
        "profile_image": ["The profile image must not be greater than 2048 kilobytes."]
    }
}
```

### Invalid file type
```json
{
    "errors": {
        "profile_image": ["The profile image must be an image."]
    }
}
```

---

## Complete Postman Test Flow

### 1. Register User with Images
```
POST /api/register
- Add all text fields
- Upload profile_image
- Upload id_image
- Send request
```

### 2. Admin Login
```
POST /api/login
{
    "phone": "admin_phone",
    "password": "admin_password"
}
```

### 3. View Pending Users
```
GET /api/admin/pending-users
Authorization: Bearer {admin_token}
```

### 4. Approve User
```
POST /api/admin/approve-user/{user_id}
Authorization: Bearer {admin_token}
```

### 5. User Login
```
POST /api/login
{
    "phone": "1234567890",
    "password": "password123"
}
```

---

## Summary

✅ **Required Changes:**
- Registration now requires `profile_image` and `id_image`
- Both fields are mandatory for tenant and landlord roles
- Images are uploaded during registration
- Max size: 2MB per image

✅ **Benefits:**
- Complete user profile from registration
- Admin can verify user identity immediately
- Better security and trust
- No need for separate upload endpoints

✅ **Testing:**
- Use Postman with `form-data` body type
- Select files for both image fields
- All other fields remain the same

**Ready to test!** 🚀
