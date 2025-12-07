# Quick Test - User Registration with Images

## ⚡ Postman Setup (2 Minutes)

### Step 1: Create Request
```
Method: POST
URL: http://localhost:8000/api/register
Body: form-data (NOT raw JSON!)
```

### Step 2: Add Fields

| Key | Type | Value |
|-----|------|-------|
| phone | Text | 1234567890 |
| password | Text | password123 |
| password_confirmation | Text | password123 |
| role | Text | tenant |
| first_name | Text | John |
| last_name | Text | Doe |
| birth_date | Text | 1990-01-01 |
| profile_image | **File** | [Click "Select Files"] |
| id_image | **File** | [Click "Select Files"] |

### Step 3: Select Images
- For `profile_image`: Select any image file (JPG, PNG) under 2MB
- For `id_image`: Select any image file (JPG, PNG) under 2MB

### Step 4: Send Request ✅

---

## ✅ Expected Response

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
            "profile_image": "profiles/xyz123.jpg",
            "id_image": "ids/abc456.jpg",
            "is_approved": false,
            "status": "pending"
        }
    }
}
```

---

## ❌ Common Errors

### Error: Missing Images
```json
{
    "errors": {
        "profile_image": ["The profile image field is required."],
        "id_image": ["The id image field is required."]
    }
}
```
**Fix**: Make sure to select files for both image fields!

### Error: Wrong Body Type
If you're using `raw` JSON, it won't work!
**Fix**: Change Body type to `form-data`

---

## 🎯 What Happens

1. ✅ User created with status "pending"
2. ✅ Images uploaded to storage
3. ✅ All admins receive real-time notification
4. ⏳ User waits for admin approval

---

## 📸 View Uploaded Images

After registration, images are accessible at:
```
Profile: http://localhost:8000/storage/profiles/filename.jpg
ID: http://localhost:8000/storage/ids/filename.jpg
```

---

## 🔄 Complete Test Flow

```
1. Register User (with images)
   ↓
2. Admin receives notification
   ↓
3. Admin approves user
   ↓
4. User receives notification
   ↓
5. User can login
```

---

## 📋 Checklist

- [ ] Postman request created
- [ ] Body type set to `form-data`
- [ ] All text fields added
- [ ] Profile image selected
- [ ] ID image selected
- [ ] Request sent successfully
- [ ] User created with pending status
- [ ] Images uploaded to storage

**Ready to test!** 🚀
