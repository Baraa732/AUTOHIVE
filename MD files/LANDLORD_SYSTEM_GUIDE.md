# 🏠 AUTOHIVE LANDLORD SYSTEM GUIDE

## ✅ SYSTEM CHANGES COMPLETED

All "owner" references have been successfully changed to "landlord" throughout the entire system:

### 🔄 Database Changes
- ✅ Users table: `role` enum updated (`tenant`, `landlord`, `admin`)
- ✅ Apartments table: `owner_id` → `landlord_id`
- ✅ All existing data migrated automatically

### 🔧 Code Changes
- ✅ `OwnerMiddleware` → `LandlordMiddleware`
- ✅ All controllers updated to use `landlord` instead of `owner`
- ✅ All models updated (`User`, `Apartment`)
- ✅ All API routes updated
- ✅ All validation rules updated

---

## 🚀 HOW TO CREATE LANDLORD ACCOUNT & ADD APARTMENTS

### Step 1: Create Landlord Account

**API Endpoint:** `POST /api/register`

```json
{
    "phone": "01234567890",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "landlord",
    "first_name": "Ahmed",
    "last_name": "Hassan",
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
            "id": 27,
            "phone": "01234567890",
            "role": "landlord",
            "first_name": "Ahmed",
            "last_name": "Hassan",
            "is_approved": false,
            "status": "pending"
        }
    }
}
```

### Step 2: Admin Approval Process

#### 2.1 Admin Login
**API Endpoint:** `POST /api/login`
```json
{
    "phone": "admin_phone",
    "password": "admin_password"
}
```

#### 2.2 View Pending Users
**API Endpoint:** `GET /api/admin/pending-users`
**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 27,
            "phone": "01234567890",
            "role": "landlord",
            "first_name": "Ahmed",
            "last_name": "Hassan",
            "status": "pending",
            "created_at": "2025-12-01T19:30:00.000000Z"
        }
    ]
}
```

#### 2.3 Approve Landlord
**API Endpoint:** `POST /api/admin/approve-user/27`
**Headers:** `Authorization: Bearer {admin_token}`

**Response:**
```json
{
    "success": true,
    "message": "User approved successfully"
}
```

### Step 3: Landlord Login & Add Apartment

#### 3.1 Landlord Login
**API Endpoint:** `POST /api/login`
```json
{
    "phone": "01234567890",
    "password": "password123"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 27,
            "role": "landlord",
            "is_approved": true
        },
        "token": "27|landlord_access_token_here"
    }
}
```

#### 3.2 Create Apartment
**API Endpoint:** `POST /api/apartments`
**Headers:** `Authorization: Bearer {landlord_token}`
**Content-Type:** `multipart/form-data`

```json
{
    "title": "Luxury 2BR Apartment in Zamalek",
    "description": "Beautiful apartment with Nile view, fully furnished",
    "governorate": "Cairo",
    "city": "Zamalek",
    "address": "26th July Street, Zamalek, Cairo",
    "price_per_night": 150.00,
    "max_guests": 4,
    "rooms": 3,
    "bedrooms": 2,
    "bathrooms": 2,
    "area": 120,
    "features": ["wifi", "air_conditioning", "kitchen", "parking"],
    "images": ["image1.jpg", "image2.jpg", "image3.jpg"]
}
```

**Response:**
```json
{
    "success": true,
    "message": "Apartment created successfully",
    "data": {
        "apartment": {
            "id": 15,
            "landlord_id": 27,
            "title": "Luxury 2BR Apartment in Zamalek",
            "price_per_night": "150.00",
            "is_available": true,
            "landlord": {
                "id": 27,
                "first_name": "Ahmed",
                "last_name": "Hassan"
            }
        }
    }
}
```

---

## 🎯 LANDLORD API ENDPOINTS

### Authentication Required: `Authorization: Bearer {landlord_token}`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/landlord/dashboard` | Get landlord dashboard data |
| `POST` | `/api/apartments` | Create new apartment |
| `GET` | `/api/my-apartments` | Get landlord's apartments |
| `PUT` | `/api/apartments/{id}` | Update apartment |
| `DELETE` | `/api/apartments/{id}` | Delete apartment |
| `POST` | `/api/apartments/{id}/toggle-availability` | Toggle availability |
| `GET` | `/api/landlord/bookings` | Get landlord's bookings |
| `GET` | `/api/landlord/bookings/{id}` | Get booking details |
| `POST` | `/api/bookings/{id}/approve` | Approve booking |
| `POST` | `/api/bookings/{id}/reject` | Reject booking |

---

## 🏗️ APARTMENT FEATURES AVAILABLE

```json
[
    "wifi", "air_conditioning", "kitchen", "parking", 
    "pool", "gym", "balcony", "garden", "elevator", 
    "security", "furnished", "washing_machine", 
    "dishwasher", "tv", "heating"
]
```

---

## 📊 LANDLORD DASHBOARD DATA

**API Endpoint:** `GET /api/landlord/dashboard`

**Response includes:**
- Total apartments count
- Active apartments count  
- Total bookings received
- Pending bookings count
- Total earnings
- Monthly earnings
- Recent bookings list
- Apartments performance metrics

---

## 🔐 ROLE RESTRICTIONS

- **Landlords can:**
  - Create, update, delete their apartments
  - View and manage bookings for their apartments
  - Approve/reject booking requests
  - View earnings and statistics

- **Landlords cannot:**
  - Book apartments (including their own)
  - Leave reviews
  - Add apartments to favorites
  - Access admin functions

---

## 🧪 TESTING COMMANDS

```bash
# Create test landlord
php artisan tinker --execute="App\Models\User::create(['phone' => '01111111111', 'password' => bcrypt('test123'), 'role' => 'landlord', 'first_name' => 'Test', 'last_name' => 'Landlord', 'birth_date' => '1985-01-01', 'is_approved' => false, 'status' => 'pending']);"

# Create admin to approve users
php artisan tinker --execute="App\Models\User::create(['phone' => 'admin', 'password' => bcrypt('admin123'), 'role' => 'admin', 'first_name' => 'Admin', 'last_name' => 'User', 'birth_date' => '1980-01-01', 'is_approved' => true, 'status' => 'approved']);"

# Check database changes
php artisan tinker --execute="echo 'Users with landlord role: ' . App\Models\User::where('role', 'landlord')->count();"
```

---

## ✨ SYSTEM IS READY!

The complete landlord system is now operational with:
- ✅ Database schema updated
- ✅ All code references changed
- ✅ API endpoints functional
- ✅ Role-based access control
- ✅ Admin approval workflow
- ✅ Apartment management system
- ✅ Booking management system

**Test landlord created:** Phone: `01234567890`, Password: `password123`