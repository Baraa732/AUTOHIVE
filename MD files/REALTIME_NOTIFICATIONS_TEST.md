# 🔔 Real-time Notifications System - Test Guide

## ✅ System Implementation Complete

### Features Implemented:
1. **Role-based Access Control** - Tenants can only book, Owners can only list apartments
2. **Real-time Admin Notifications** - Instant notifications when users register
3. **User Approval System** - Admin can approve/reject with real-time feedback
4. **WebSocket-ready Architecture** - Broadcasting events for real-time updates

## 🧪 Testing Instructions

### Step 1: Start the Admin Dashboard
1. Open your browser and go to: `http://localhost:8000/admin-dashboard-test.html`
2. Login with admin credentials:
   - **Phone**: `01000000000`
   - **Password**: `admin123`
3. Keep this page open - notifications will appear automatically

### Step 2: Test User Registration via Postman

#### Create New User Registration Request:
```http
POST http://localhost:8000/api/register
Content-Type: application/json

{
    "phone": "01333333333",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "tenant",
    "first_name": "John",
    "last_name": "Doe",
    "birth_date": "1990-01-01"
}
```

**Expected Result**: 
- ✅ User created successfully
- 🔔 **Real-time notification appears on admin dashboard** (within 3 seconds)
- Notification shows: "John Doe (tenant) has registered and needs approval"

### Step 3: Test User Approval

#### Get Pending Users:
```http
GET http://localhost:8000/api/admin/users?status=pending
Authorization: Bearer {admin_token}
```

#### Approve User:
```http
POST http://localhost:8000/api/admin/users/{user_id}/approve
Authorization: Bearer {admin_token}
```

**Expected Result**:
- ✅ User approved successfully
- 🔔 Real-time notification sent to user (if they were online)

### Step 4: Test Role Restrictions

#### Try Tenant Creating Apartment (Should Fail):
```http
POST http://localhost:8000/api/apartments
Authorization: Bearer {tenant_token}
Content-Type: application/json

{
    "title": "Test Apartment",
    "description": "This should fail",
    "governorate": "Cairo",
    "city": "Nasr City",
    "address": "123 Test St",
    "price_per_night": 100,
    "max_guests": 4,
    "rooms": 2
}
```

**Expected Result**: ❌ 403 Forbidden - "Access denied. Owner role required."

#### Try Owner Making Booking (Should Fail):
```http
POST http://localhost:8000/api/bookings
Authorization: Bearer {owner_token}
Content-Type: application/json

{
    "apartment_id": 1,
    "check_in": "2024-12-15",
    "check_out": "2024-12-20"
}
```

**Expected Result**: ❌ 403 Forbidden - "This feature is for tenants only."

## 🔑 Test Accounts

### Admin Account:
- **Phone**: `01000000000`
- **Password**: `admin123`
- **Role**: `admin`

### Test Owner Account:
- **Phone**: `01111111111`
- **Password**: `password123`
- **Role**: `owner`

### Test Tenant Account:
- **Phone**: `01222222222`
- **Password**: `password123`
- **Role**: `tenant`

## 📡 Real-time Notification Flow

### 1. User Registration Flow:
```
User registers via API
    ↓
AuthController creates user
    ↓
notifyAdminsOfNewRegistration() called
    ↓
Notification saved to database
    ↓
AdminNotification event broadcasted
    ↓
Admin dashboard receives notification (real-time)
```

### 2. User Approval Flow:
```
Admin approves user via API
    ↓
AdminController updates user status
    ↓
notifyUserOfApprovalStatus() called
    ↓
Notification saved to database
    ↓
UserNotification event broadcasted
    ↓
User receives approval notification (if online)
```

## 🛠 Technical Implementation

### Broadcasting Events:
- `AdminNotification` - Sent to admin channels
- `UserNotification` - Sent to user channels

### Channels:
- `private-admin.{adminId}` - Admin-specific notifications
- `private-user.{userId}` - User-specific notifications
- `private-owner.{ownerId}` - Owner-specific notifications

### API Endpoints:
- `POST /api/broadcasting/auth` - WebSocket authentication
- `POST /api/test-notification` - Test notification system
- `GET /api/notifications` - Get user notifications

## 🎯 Expected Behavior

### ✅ What Should Work:
1. **Tenants can**:
   - Register and login
   - Search and view apartments
   - Make bookings
   - Leave reviews
   - Manage favorites

2. **Owners can**:
   - Register and login
   - Create and manage apartments
   - Receive and manage booking requests
   - View earnings and analytics

3. **Admins can**:
   - Approve/reject user registrations
   - Receive real-time notifications
   - Manage all system data

### ❌ What Should Be Blocked:
1. **Tenants cannot**:
   - Create apartments
   - Access owner dashboard
   - Approve bookings

2. **Owners cannot**:
   - Make bookings
   - Leave reviews
   - Access tenant-only features

## 🔍 Verification Checklist

- [ ] Admin dashboard loads successfully
- [ ] Admin can login with test credentials
- [ ] New user registration triggers real-time notification
- [ ] Notification appears on dashboard within 3 seconds
- [ ] User approval sends notification to user
- [ ] Tenant cannot create apartments (403 error)
- [ ] Owner cannot make bookings (403 error)
- [ ] Role restrictions are properly enforced

## 🚀 Production Deployment Notes

For production deployment:
1. Replace polling with actual WebSocket (Pusher/Socket.io)
2. Configure proper broadcasting driver in `.env`
3. Set up Redis for better performance
4. Implement proper error handling for offline users
5. Add notification persistence and retry logic

## 📱 Flutter Integration

The real-time notification system is ready for Flutter integration:
- WebSocket channels are configured
- Authentication endpoints are ready
- Event broadcasting is implemented
- Notification models are structured for mobile consumption

Your Flutter team can connect to the WebSocket channels and receive real-time notifications using the same authentication tokens.