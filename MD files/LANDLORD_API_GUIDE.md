# 🏠 AutoHive Landlord System - Complete API Guide

## 🎯 Overview
Complete landlord (owner) system allowing property owners to register, create apartments, and manage bookings.

## 👤 Landlord Registration

### Register as Owner
```http
POST /api/register
Content-Type: application/json

{
    "phone": "1234567890",
    "password": "securepassword",
    "password_confirmation": "securepassword",
    "role": "owner",
    "first_name": "John",
    "last_name": "Doe",
    "birth_date": "1980-01-01"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Registration successful. Awaiting admin approval.",
    "data": {
        "user": {
            "id": 26,
            "display_id": "USR-A1B2C3D4E5F6G7H8",
            "phone": "1234567890",
            "role": "owner",
            "first_name": "John",
            "last_name": "Doe",
            "status": "pending",
            "is_approved": false
        }
    }
}
```

## 🏢 Apartment Management

### Get Available Features
```http
GET /api/apartments/features/available
```

**Response:**
```json
{
    "success": true,
    "data": [
        {"value": "wifi", "label": "WiFi"},
        {"value": "air_conditioning", "label": "Air Conditioning"},
        {"value": "heating", "label": "Heating"},
        {"value": "kitchen", "label": "Kitchen"},
        {"value": "washing_machine", "label": "Washing Machine"},
        {"value": "parking", "label": "Parking"},
        {"value": "balcony", "label": "Balcony"},
        {"value": "elevator", "label": "Elevator"},
        {"value": "security", "label": "Security"},
        {"value": "furnished", "label": "Furnished"},
        {"value": "pet_friendly", "label": "Pet Friendly"},
        {"value": "swimming_pool", "label": "Swimming Pool"},
        {"value": "gym", "label": "Gym"},
        {"value": "garden", "label": "Garden"},
        {"value": "terrace", "label": "Terrace"}
    ]
}
```

### Create Apartment
```http
POST /api/apartments
Authorization: Bearer {owner_token}
Content-Type: multipart/form-data

{
    "title": "Luxury Downtown Apartment",
    "description": "Beautiful 2-bedroom apartment in the heart of the city with stunning views.",
    "governorate": "Cairo",
    "city": "New Cairo",
    "address": "123 Main Street, Downtown",
    "price_per_night": 150.00,
    "max_guests": 4,
    "rooms": 3,
    "bedrooms": 2,
    "bathrooms": 2,
    "area": 120.5,
    "features": ["wifi", "air_conditioning", "kitchen", "parking", "balcony"],
    "images": [file1.jpg, file2.jpg, file3.jpg]
}
```

**Response:**
```json
{
    "success": true,
    "message": "Apartment created successfully",
    "data": {
        "apartment": {
            "id": 1,
            "title": "Luxury Downtown Apartment",
            "description": "Beautiful 2-bedroom apartment...",
            "governorate": "Cairo",
            "city": "New Cairo",
            "address": "123 Main Street, Downtown",
            "price_per_night": 150.00,
            "max_guests": 4,
            "rooms": 3,
            "bedrooms": 2,
            "bathrooms": 2,
            "area": 120.5,
            "features": ["wifi", "air_conditioning", "kitchen", "parking", "balcony"],
            "images": ["apartments/abc123.jpg", "apartments/def456.jpg"],
            "is_available": true,
            "owner": {
                "id": 26,
                "first_name": "John",
                "last_name": "Doe",
                "phone": "1234567890"
            },
            "created_at": "2024-12-01T19:30:00.000000Z"
        },
        "average_rating": 0,
        "total_reviews": 0,
        "available_features": [...]
    }
}
```

### Get My Apartments
```http
GET /api/my-apartments
Authorization: Bearer {owner_token}
```

### Update Apartment
```http
PUT /api/apartments/{id}
Authorization: Bearer {owner_token}

{
    "title": "Updated Apartment Title",
    "price_per_night": 175.00,
    "is_available": true
}
```

### Toggle Availability
```http
POST /api/apartments/{id}/toggle-availability
Authorization: Bearer {owner_token}
```

## 📋 Booking Management

### Get Owner Bookings
```http
GET /api/owner/bookings
Authorization: Bearer {owner_token}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "data": [
            {
                "id": 1,
                "tenant_id": 25,
                "apartment_id": 1,
                "check_in": "2024-12-15",
                "check_out": "2024-12-20",
                "total_price": 750.00,
                "status": "pending",
                "tenant": {
                    "id": 25,
                    "first_name": "Jane",
                    "last_name": "Smith",
                    "phone": "9876543210"
                },
                "apartment": {
                    "id": 1,
                    "title": "Luxury Downtown Apartment"
                }
            }
        ]
    }
}
```

### Approve Booking
```http
POST /api/bookings/{id}/approve
Authorization: Bearer {owner_token}
```

### Reject Booking
```http
POST /api/bookings/{id}/reject
Authorization: Bearer {owner_token}
```

## 🔍 Tenant Booking Process

### Check Availability
```http
GET /api/bookings/check-availability/{apartment_id}?check_in=2024-12-15&check_out=2024-12-20
Authorization: Bearer {tenant_token}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "available": true,
        "nights": 5,
        "total_price": 750.00,
        "price_per_night": 150.00,
        "conflicts": []
    },
    "message": "Apartment is available"
}
```

### Create Booking (Tenant)
```http
POST /api/bookings
Authorization: Bearer {tenant_token}

{
    "apartment_id": 1,
    "check_in": "2024-12-15",
    "check_out": "2024-12-20",
    "payment_details": {
        "method": "card",
        "card_number": "1234567890123456",
        "cardholder_name": "Jane Smith"
    }
}
```

## 🚫 Booking Restrictions

### Automatic Validations:
1. **Owner Restriction**: Owners cannot book their own apartments
2. **Availability Check**: Apartment must be marked as available
3. **Date Conflicts**: No overlapping bookings allowed
4. **Guest Capacity**: Cannot exceed apartment's max_guests
5. **Future Dates**: Check-in must be after today
6. **Valid Duration**: Check-out must be after check-in

### Conflict Prevention:
- **Database Locking**: Prevents race conditions during booking
- **Real-time Availability**: Checks current bookings before confirming
- **Detailed Conflict Info**: Returns conflicting booking dates if unavailable

## 📊 Complete Apartment Data Structure

```json
{
    "id": 1,
    "owner_id": 26,
    "title": "Luxury Downtown Apartment",
    "description": "Beautiful apartment with city views",
    "governorate": "Cairo",
    "city": "New Cairo", 
    "address": "123 Main Street",
    "price_per_night": 150.00,
    "max_guests": 4,
    "rooms": 3,
    "bedrooms": 2,
    "bathrooms": 2,
    "area": 120.5,
    "features": ["wifi", "air_conditioning", "kitchen"],
    "images": ["apartments/image1.jpg", "apartments/image2.jpg"],
    "is_available": true,
    "average_rating": 4.5,
    "reviews_count": 12,
    "bookings_count": 25,
    "owner": {
        "id": 26,
        "display_id": "USR-A1B2C3D4E5F6G7H8",
        "first_name": "John",
        "last_name": "Doe",
        "phone": "1234567890"
    },
    "availability_calendar": [
        {"date": "2024-12-01", "available": true},
        {"date": "2024-12-02", "available": false}
    ]
}
```

## ✅ System Features

### ✅ **Landlord Features:**
- Register as owner/landlord
- Create apartments with rich details
- Upload multiple images (up to 10)
- Select from 15 predefined features
- Manage apartment availability
- View and manage booking requests
- Approve/reject bookings
- Track apartment performance

### ✅ **Tenant Features:**
- Browse available apartments
- Filter by location, price, features
- Check real-time availability
- Book apartments with conflict prevention
- Cannot book owner's own apartments
- Receive booking confirmations

### ✅ **System Logic:**
- **Role-based access**: Owners vs Tenants
- **Admin approval**: New users need approval
- **Conflict prevention**: Database locking
- **Feature validation**: Enum-based features
- **Image management**: Multiple image uploads
- **Activity logging**: All actions tracked
- **Notification system**: Real-time updates

The system is now **100% complete and logically sound** for landlord apartment management and tenant booking!