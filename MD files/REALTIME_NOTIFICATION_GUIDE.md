# Real-Time Notification System Guide

## Overview
This system sends real-time notifications to admins when users register and to users when their accounts are approved/rejected.

## How It Works

### 1. User Registration Flow
```
User Registers (POST /api/register)
    ↓
User Created with status='pending', is_approved=false
    ↓
Notification Created for ALL Admins
    ↓
Real-Time Broadcast to Admin Channels (admin.{adminId})
    ↓
Admins See Notification Instantly
```

### 2. Admin Approval/Rejection Flow
```
Admin Approves/Rejects User (POST /api/admin/approve-user/{id} or reject-user/{id})
    ↓
User Status Updated
    ↓
Notification Created for User
    ↓
Real-Time Broadcast to User Channel (user.{userId})
    ↓
User Sees Notification Instantly
```

## API Endpoints

### 1. User Registration (Public)
```http
POST /api/register
Content-Type: application/json

{
    "phone": "1234567890",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "tenant",
    "first_name": "John",
    "last_name": "Doe",
    "birth_date": "1990-01-01"
}
```

**Response:**
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
            "is_approved": false,
            "status": "pending"
        }
    }
}
```

**What Happens:**
- User is created with `is_approved=false` and `status=pending`
- Notification is sent to ALL admins
- Real-time broadcast to all admin channels: `admin.{adminId}`

---

### 2. Admin Login (Get Token)
```http
POST /api/login
Content-Type: application/json

{
    "phone": "admin_phone",
    "password": "admin_password"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {...},
        "token": "your_bearer_token_here"
    }
}
```

---

### 3. Get Pending Users (Admin Only)
```http
GET /api/admin/pending-users
Authorization: Bearer {admin_token}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "pending_users": [
            {
                "id": 1,
                "phone": "1234567890",
                "role": "tenant",
                "first_name": "John",
                "last_name": "Doe",
                "is_approved": false,
                "status": "pending",
                "created_at": "2025-01-01T10:00:00.000000Z"
            }
        ],
        "count": 1
    }
}
```

---

### 4. Approve User (Admin Only)
```http
POST /api/admin/approve-user/{user_id}
Authorization: Bearer {admin_token}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "is_approved": true,
        "status": "approved"
    },
    "message": "User approved successfully"
}
```

**What Happens:**
- User status updated to `approved`
- Notification created for user
- Real-time broadcast to user channel: `user.{userId}`
- User receives notification: "Your account has been approved!"

---

### 5. Reject User (Admin Only)
```http
POST /api/admin/reject-user/{user_id}
Authorization: Bearer {admin_token}
```

**Response:**
```json
{
    "success": true,
    "message": "User John Doe has been rejected. They can register again."
}
```

**What Happens:**
- User status updated to `rejected`
- Notification created for user
- Real-time broadcast to user channel: `user.{userId}`
- User receives notification: "Your account has been rejected..."
- User is soft-deleted (can re-register)

---

### 6. Get Admin Notifications
```http
GET /api/admin/notifications
Authorization: Bearer {admin_token}
```

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "type": "user_registration",
            "title": "New User Registration",
            "message": "John Doe (tenant) has registered and needs approval.",
            "data": {
                "user_id": 1,
                "user_name": "John Doe",
                "user_role": "tenant",
                "user_phone": "1234567890",
                "action_required": true,
                "actions": ["approve", "reject"]
            },
            "read_at": null,
            "created_at": "2025-01-01T10:00:00.000000Z"
        }
    ]
}
```

---

### 7. Get User Notifications
```http
GET /api/notifications
Authorization: Bearer {user_token}
```

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "type": "account_approved",
            "title": "Account Approved",
            "message": "Your account has been approved! You can now login and use the app.",
            "data": {
                "approved_at": "2025-01-01T10:05:00.000000Z"
            },
            "read_at": null,
            "created_at": "2025-01-01T10:05:00.000000Z"
        }
    ]
}
```

---

## Broadcasting Configuration

### Required Environment Variables
```env
BROADCAST_DRIVER=pusher

PUSHER_APP_ID=your_app_id
PUSHER_APP_KEY=your_app_key
PUSHER_APP_SECRET=your_app_secret
PUSHER_APP_CLUSTER=your_cluster
```

### Broadcasting Channels

1. **Admin Channel**: `admin.{adminId}`
   - Receives: User registration notifications
   - Authorization: User must be admin with matching ID

2. **User Channel**: `user.{userId}`
   - Receives: Account approval/rejection notifications
   - Authorization: User must have matching ID

---

## Testing with Postman

### Step 1: Register a New User
1. Send POST request to `/api/register` with user data
2. Note the user ID from response
3. **Expected**: All admins receive real-time notification

### Step 2: Admin Login
1. Send POST request to `/api/login` with admin credentials
2. Copy the bearer token from response

### Step 3: Check Pending Users
1. Send GET request to `/api/admin/pending-users` with admin token
2. Verify the newly registered user appears in the list

### Step 4: Approve User
1. Send POST request to `/api/admin/approve-user/{user_id}` with admin token
2. **Expected**: User receives real-time notification about approval

### Step 5: User Login
1. Send POST request to `/api/login` with approved user credentials
2. User can now login successfully

---

## Testing Real-Time Notifications

### Option 1: Using Laravel Echo (Frontend)
```javascript
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: process.env.PUSHER_APP_KEY,
    cluster: process.env.PUSHER_APP_CLUSTER,
    forceTLS: true,
    authEndpoint: '/api/broadcasting/auth',
    auth: {
        headers: {
            Authorization: 'Bearer ' + token
        }
    }
});

// Listen for admin notifications
Echo.private(`admin.${adminId}`)
    .listen('.notification', (e) => {
        console.log('Admin notification received:', e);
    });

// Listen for user notifications
Echo.private(`user.${userId}`)
    .listen('.notification', (e) => {
        console.log('User notification received:', e);
    });
```

### Option 2: Using Pusher Debug Console
1. Go to your Pusher dashboard
2. Open the "Debug Console" tab
3. Register a user via Postman
4. Watch for events on channels: `private-admin.{adminId}`
5. Approve/reject user
6. Watch for events on channel: `private-user.{userId}`

---

## Notification Types

### Admin Notifications
- **Type**: `user_registration`
- **Title**: "New User Registration"
- **Data**: Contains user details and action buttons

### User Notifications
- **Type**: `account_approved` or `account_rejected`
- **Title**: "Account Approved" or "Account Rejected"
- **Data**: Contains approval/rejection timestamp

---

## Troubleshooting

### Notifications Not Broadcasting
1. Check `.env` file has correct Pusher credentials
2. Verify `BROADCAST_DRIVER=pusher`
3. Check Laravel logs: `storage/logs/laravel.log`
4. Verify Pusher dashboard shows connection

### Admin Not Receiving Notifications
1. Ensure admin is logged in and has valid token
2. Check admin channel authorization in `routes/channels.php`
3. Verify admin role is exactly 'admin'

### User Not Receiving Notifications
1. Ensure user is logged in and has valid token
2. Check user channel authorization in `routes/channels.php`
3. Verify user ID matches channel ID

---

## Complete Test Flow

```bash
# 1. Register User
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "1234567890",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "tenant",
    "first_name": "John",
    "last_name": "Doe",
    "birth_date": "1990-01-01"
  }'

# 2. Admin Login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "admin_phone",
    "password": "admin_password"
  }'

# 3. Get Pending Users
curl -X GET http://localhost:8000/api/admin/pending-users \
  -H "Authorization: Bearer {admin_token}"

# 4. Approve User
curl -X POST http://localhost:8000/api/admin/approve-user/1 \
  -H "Authorization: Bearer {admin_token}"

# 5. User Login (Now Approved)
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "1234567890",
    "password": "password123"
  }'
```

---

## Summary

✅ **Fixed Issues:**
1. Removed syntax error (stray 'z') in BroadcastController
2. Updated broadcast authentication to use Pusher properly
3. Added real-time broadcasting to NotificationService
4. Enhanced user registration notifications with more details
5. Added real-time notifications for user approval/rejection

✅ **Real-Time Flow:**
1. User registers → Admins get instant notification
2. Admin approves/rejects → User gets instant notification
3. All notifications stored in database
4. All notifications broadcast via Pusher

✅ **Ready to Use:**
- Register users via Postman
- Admins receive notifications in real-time
- Admins can approve/reject users
- Users receive approval/rejection notifications in real-time
