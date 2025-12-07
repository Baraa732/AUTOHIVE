# 🔔 Complete Notification System Test Guide

## ✅ STEP-BY-STEP TESTING

### Step 1: Test Notification System
1. **Open**: `http://localhost:8000/test-notifications.html`
2. **Login**: `01000000000` / `admin123`
3. **Click**: "Create Test Notification" - Should create a notification
4. **Click**: "Load All Notifications" - Should show the test notification

### Step 2: Test User Registration Notifications
1. **Keep the test page open**
2. **Click**: "Create Test User (Triggers Notification)" 
3. **Wait 2 seconds**
4. **Click**: "Load All Notifications" - Should show new user registration notification

### Step 3: Test via Postman
```http
POST http://localhost:8000/api/register
Content-Type: application/json

{
    "phone": "01888999000",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "tenant",
    "first_name": "Ahmed",
    "last_name": "Hassan",
    "birth_date": "1990-01-01"
}
```

Then check notifications again on the test page.

## 🔍 Debug Endpoints

### Check Current State:
```http
GET http://localhost:8000/api/debug/notifications
Authorization: Bearer {admin_token}
```

### Force Create Notification:
```http
POST http://localhost:8000/api/debug/force-notification
Authorization: Bearer {admin_token}
```

## 📡 API Endpoints for Your Dashboard

### Get All Notifications:
```http
GET /api/admin/notifications
Authorization: Bearer {admin_token}

Response:
{
    "success": true,
    "data": {
        "notifications": [...],
        "unread_count": 5,
        "total_count": 10
    }
}
```

### Get Unread Only:
```http
GET /api/admin/notifications/unread
Authorization: Bearer {admin_token}
```

### Mark as Read:
```http
POST /api/admin/notifications/{id}/read
Authorization: Bearer {admin_token}
```

### Mark All as Read:
```http
POST /api/admin/notifications/read-all
Authorization: Bearer {admin_token}
```

## 🎛️ Integration Code for Your Dashboard

### JavaScript for Real-time Notifications:
```javascript
class NotificationManager {
    constructor(adminToken) {
        this.token = adminToken;
        this.unreadCount = 0;
        this.notifications = [];
        this.init();
    }

    async init() {
        await this.loadNotifications();
        // Poll every 5 seconds for new notifications
        setInterval(() => this.checkForNewNotifications(), 5000);
    }

    async loadNotifications() {
        try {
            const response = await fetch('/api/admin/notifications', {
                headers: { 'Authorization': `Bearer ${this.token}` }
            });
            
            const data = await response.json();
            
            if (data.success) {
                this.notifications = data.data.notifications;
                this.unreadCount = data.data.unread_count;
                this.updateUI();
            }
        } catch (error) {
            console.error('Error loading notifications:', error);
        }
    }

    async checkForNewNotifications() {
        const oldCount = this.unreadCount;
        await this.loadNotifications();
        
        // If unread count increased, show alert
        if (this.unreadCount > oldCount) {
            this.showNewNotificationAlert();
        }
    }

    updateUI() {
        // Update notification badge
        const badge = document.getElementById('notification-badge');
        if (badge) {
            badge.textContent = this.unreadCount;
            badge.style.display = this.unreadCount > 0 ? 'block' : 'none';
        }

        // Update notification dropdown
        const dropdown = document.getElementById('notification-dropdown');
        if (dropdown) {
            this.renderNotifications(dropdown);
        }
    }

    renderNotifications(container) {
        if (this.notifications.length === 0) {
            container.innerHTML = '<p>No notifications</p>';
            return;
        }

        let html = '';
        this.notifications.slice(0, 10).forEach(notification => {
            const isUnread = !notification.read_at;
            html += `
                <div class="notification-item ${isUnread ? 'unread' : ''}" 
                     onclick="notificationManager.markAsRead(${notification.id})">
                    <strong>${notification.title}</strong>
                    <p>${notification.message}</p>
                    <small>${new Date(notification.created_at).toLocaleString()}</small>
                </div>
            `;
        });

        container.innerHTML = html;
    }

    async markAsRead(notificationId) {
        try {
            await fetch(`/api/admin/notifications/${notificationId}/read`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${this.token}` }
            });
            
            await this.loadNotifications();
        } catch (error) {
            console.error('Error marking as read:', error);
        }
    }

    async markAllAsRead() {
        try {
            await fetch('/api/admin/notifications/read-all', {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${this.token}` }
            });
            
            await this.loadNotifications();
        } catch (error) {
            console.error('Error marking all as read:', error);
        }
    }

    showNewNotificationAlert() {
        // Show toast notification or update UI
        console.log('New notification received!');
        
        // You can add toast notification here
        // this.showToast('New notification received!');
    }
}

// Initialize when admin logs in
const notificationManager = new NotificationManager(adminToken);
```

### CSS for Notification UI:
```css
.notification-badge {
    background: #ff4444;
    color: white;
    border-radius: 50%;
    padding: 2px 6px;
    font-size: 12px;
    position: absolute;
    top: -5px;
    right: -5px;
}

.notification-dropdown {
    position: absolute;
    top: 100%;
    right: 0;
    background: white;
    border: 1px solid #ddd;
    border-radius: 4px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    width: 300px;
    max-height: 400px;
    overflow-y: auto;
    z-index: 1000;
}

.notification-item {
    padding: 10px;
    border-bottom: 1px solid #eee;
    cursor: pointer;
}

.notification-item:hover {
    background: #f5f5f5;
}

.notification-item.unread {
    background: #e3f2fd;
    border-left: 3px solid #2196f3;
}
```

## ✅ Expected Behavior

1. **User registers** → Notification created in database
2. **Admin dashboard polls** → Gets new notifications
3. **Notification badge updates** → Shows unread count
4. **Admin clicks notification** → Marks as read
5. **Badge updates** → Decreases unread count

## 🚀 Production Ready

The notification system is now complete with:
- ✅ Database storage
- ✅ Real-time polling
- ✅ Read/unread status
- ✅ Admin-specific notifications
- ✅ Complete API endpoints
- ✅ Debug tools for troubleshooting

Your admin dashboard can now integrate these endpoints for full notification functionality!