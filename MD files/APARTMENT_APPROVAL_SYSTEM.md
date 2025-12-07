# 🏠 APARTMENT APPROVAL SYSTEM

## 🎯 **COMPLETE APARTMENT APPROVAL WORKFLOW**

### **Step 1: Landlord Creates Apartment**
When landlord creates apartment, it's automatically set to **pending approval**:

**API:** `POST /api/apartments`
**Status:** `pending`, `is_approved: false`

```json
{
    "success": true,
    "message": "Apartment created successfully. Awaiting admin approval",
    "data": {
        "apartment": {
            "id": 7,
            "status": "pending",
            "is_approved": false
        }
    }
}
```

### **Step 2: Admin Reviews Pending Apartments**
**Admin Dashboard:** `/admin/apartments/pending`
**API:** `GET /api/admin/pending-apartments`

**Admin can:**
- ✅ **View Details** - See full apartment information
- ✅ **Approve** - Make apartment live and visible
- ❌ **Reject** - Reject with reason

### **Step 3: Admin Actions**

#### **Approve Apartment:**
**API:** `POST /api/admin/approve-apartment/{id}`
```json
{
    "success": true,
    "message": "Apartment approved successfully"
}
```

#### **Reject Apartment:**
**API:** `POST /api/admin/reject-apartment/{id}`
```json
{
    "reason": "Images are not clear enough"
}
```

### **Step 4: Landlord Notification**
Landlord receives notification about approval/rejection status.

---

## 🔄 **SYSTEM BEHAVIOR**

### **Public Apartment Listings:**
- ✅ **Only approved apartments** appear in public listings
- ✅ **Pending/rejected apartments** are hidden from tenants
- ✅ **Search results** only include approved apartments

### **Landlord Dashboard:**
- 📊 **Shows all apartments** (pending, approved, rejected)
- 🔍 **Status indicators** for each apartment
- 📝 **Rejection reasons** displayed if rejected

### **Admin Dashboard:**
- 📋 **Pending approvals list** with apartment details
- 👀 **Quick view** of apartment information
- ⚡ **One-click approve/reject** actions

---

## 📱 **API ENDPOINTS**

### **Landlord Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/apartments` | Create apartment (pending approval) |
| `GET` | `/api/my-apartments` | View all my apartments with status |

### **Admin Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/admin/pending-apartments` | Get pending apartments |
| `GET` | `/api/admin/apartment-details/{id}` | Get apartment details |
| `POST` | `/api/admin/approve-apartment/{id}` | Approve apartment |
| `POST` | `/api/admin/reject-apartment/{id}` | Reject apartment |

### **Public Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/apartments` | Only approved apartments |
| `GET` | `/api/apartments/{id}` | Only if approved |

---

## 🗄️ **DATABASE STRUCTURE**

### **Apartments Table:**
```sql
- is_approved: boolean (default: false)
- status: enum('pending', 'approved', 'rejected') (default: 'pending')
- rejection_reason: text (nullable)
```

### **Status Flow:**
```
pending → approved ✅
pending → rejected ❌
rejected → pending (if landlord resubmits)
```

---

## 🔒 **SECURITY & VALIDATION**

### **Landlord Restrictions:**
- ✅ Can create apartments (pending approval)
- ✅ Can view their own apartments (all statuses)
- ❌ Cannot see other landlords' apartments
- ❌ Cannot approve their own apartments

### **Admin Powers:**
- ✅ View all apartments (any status)
- ✅ Approve/reject any apartment
- ✅ See rejection reasons
- ✅ Activity logging for all actions

### **Public Access:**
- ✅ Only approved apartments visible
- ❌ No access to pending/rejected apartments
- ✅ Search only includes approved apartments

---

## 📊 **ADMIN DASHBOARD FEATURES**

### **Pending Apartments Page:**
- 📋 **List View** - All pending apartments
- 👤 **Landlord Info** - Name, phone, profile
- 🏠 **Apartment Details** - Title, description, price, location
- 🖼️ **Images** - View uploaded images
- ⚡ **Quick Actions** - Approve/Reject buttons

### **Approval Actions:**
- ✅ **One-Click Approve** - Instant approval
- ❌ **Reject with Reason** - Required rejection reason
- 📝 **Activity Logging** - All actions logged
- 🔔 **Auto Notifications** - Landlord notified automatically

---

## 🎯 **WORKFLOW EXAMPLE**

1. **Landlord Ahmed** creates "Luxury Apartment in Zamalek"
2. **Status:** `pending` - Not visible to public
3. **Admin receives notification** of new apartment
4. **Admin reviews** apartment details and images
5. **Admin approves** - Apartment goes live
6. **Ahmed gets notification** - "Your apartment has been approved!"
7. **Public can now see** apartment in search results

---

## ✅ **SYSTEM READY**

The complete apartment approval system is now operational:
- 🏠 **Landlord Creation** - Apartments created as pending
- 👨‍💼 **Admin Review** - Full approval workflow
- 🔔 **Notifications** - Automatic status updates
- 🔒 **Security** - Only approved apartments public
- 📊 **Dashboard** - Complete admin interface
- 📱 **API** - Full mobile app support

**Access pending apartments:** `/admin/apartments/pending` 🎯✨