# 🎛️ Web Dashboard Integration Guide

## ✅ COMPLETE SOLUTION READY

I've created a **complete notification system** that shows user registration requests with approve/reject actions that **DON'T DISAPPEAR** when clicked.

## 🧪 **Test the Complete Dashboard**

### **Open**: `http://localhost:8000/admin-notifications-dashboard.html`
- **Login**: `01000000000` / `admin123`
- **Click**: "Create Test User" to generate notifications
- **See**: User details with approve/reject buttons
- **Action**: Click approve/reject - user details stay visible until action is taken

## 📡 **API Endpoints for Your Web Dashboard**

### **1. Get Notifications with User Details & Actions**
```javascript
GET /api/admin/notifications-with-actions

Response:
{
    "success": true,
    "data": {
        "notifications": [
            {
                "id": 1,
                "title": "New User Registration",
                "message": "John Doe (tenant) has registered and needs approval",
                "type": "new_user_registration",
                "read_at": null,
                "created_at": "2024-12-02T10:30:00Z",
                "related_user": {
                    "id": 15,
                    "first_name": "John",
                    "last_name": "Doe",
                    "phone": "01999888777",
                    "role": "tenant",
                    "is_approved": false,
                    "created_at": "2024-12-02T10:30:00Z"
                },
                "actions_available": true,
                "can_approve": true,
                "can_reject": true
            }
        ],
        "unread_count": 5,
        "total_count": 10
    }
}
```

### **2. Approve User**
```javascript
POST /api/admin/approve-user/{userId}
Authorization: Bearer {token}

Response:
{
    "success": true,
    "data": { /* user object */ },
    "message": "User approved successfully"
}
```

### **3. Reject User**
```javascript
POST /api/admin/reject-user/{userId}
Authorization: Bearer {token}

Response:
{
    "success": true,
    "message": "User John Doe has been rejected and removed"
}
```

### **4. Get Pending Users List**
```javascript
GET /api/admin/pending-users
Authorization: Bearer {token}

Response:
{
    "success": true,
    "data": {
        "pending_users": [...],
        "count": 3
    }
}
```

## 🔧 **Integration Code for Your Dashboard**

### **JavaScript Class for Notifications**
```javascript
class AdminNotificationManager {
    constructor(authToken) {
        this.token = authToken;
        this.notifications = [];
        this.pendingUsers = [];
        this.unreadCount = 0;
    }

    async loadNotificationsWithActions() {
        try {
            const response = await fetch('/api/admin/notifications-with-actions', {
                headers: { 'Authorization': `Bearer ${this.token}` }
            });

            const data = await response.json();
            
            if (data.success) {
                this.notifications = data.data.notifications;
                this.unreadCount = data.data.unread_count;
                this.renderNotifications();
                this.updateBadge();
            }
        } catch (error) {
            console.error('Error loading notifications:', error);
        }
    }

    renderNotifications() {
        const container = document.getElementById('notifications-container');
        
        if (this.notifications.length === 0) {
            container.innerHTML = '<p>No notifications</p>';
            return;
        }

        let html = '';
        this.notifications.forEach(notification => {
            const isUnread = !notification.read_at;
            const hasActions = notification.actions_available;
            
            html += `
                <div class="notification-item ${isUnread ? 'unread' : ''}" data-id="${notification.id}">
                    <div class="notification-header">
                        <h4>${notification.title}</h4>
                        <span class="time">${new Date(notification.created_at).toLocaleString()}</span>
                    </div>
                    
                    <p class="message">${notification.message}</p>
                    
                    ${notification.related_user ? `
                        <div class="user-details">
                            <div class="detail-row">
                                <strong>Name:</strong> ${notification.related_user.first_name} ${notification.related_user.last_name}
                            </div>
                            <div class="detail-row">
                                <strong>Phone:</strong> ${notification.related_user.phone}
                            </div>
                            <div class="detail-row">
                                <strong>Role:</strong> ${notification.related_user.role}
                            </div>
                            <div class="detail-row">
                                <strong>Registered:</strong> ${new Date(notification.related_user.created_at).toLocaleString()}
                            </div>
                        </div>
                    ` : ''}
                    
                    <div class="action-buttons">
                        ${hasActions && notification.related_user ? `
                            <button class="btn-approve" onclick="adminNotifications.approveUser(${notification.related_user.id}, '${notification.related_user.first_name} ${notification.related_user.last_name}')">
                                ✅ Approve
                            </button>
                            <button class="btn-reject" onclick="adminNotifications.rejectUser(${notification.related_user.id}, '${notification.related_user.first_name} ${notification.related_user.last_name}')">
                                ❌ Reject
                            </button>
                        ` : ''}
                        
                        ${isUnread ? `
                            <button class="btn-mark-read" onclick="adminNotifications.markAsRead(${notification.id})">
                                Mark as Read
                            </button>
                        ` : ''}
                    </div>
                </div>
            `;
        });
        
        container.innerHTML = html;
    }

    async approveUser(userId, userName) {
        if (!confirm(`Approve user: ${userName}?`)) return;
        
        try {
            const response = await fetch(`/api/admin/approve-user/${userId}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${this.token}` }
            });

            const data = await response.json();
            
            if (data.success) {
                this.showSuccess(`${userName} has been approved!`);
                await this.loadNotificationsWithActions();
                await this.loadPendingUsers();
            } else {
                this.showError(data.message);
            }
        } catch (error) {
            this.showError('Error approving user: ' + error.message);
        }
    }

    async rejectUser(userId, userName) {
        if (!confirm(`Reject and delete user: ${userName}? This cannot be undone.`)) return;
        
        try {
            const response = await fetch(`/api/admin/reject-user/${userId}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${this.token}` }
            });

            const data = await response.json();
            
            if (data.success) {
                this.showSuccess(`${userName} has been rejected and removed.`);
                await this.loadNotificationsWithActions();
                await this.loadPendingUsers();
            } else {
                this.showError(data.message);
            }
        } catch (error) {
            this.showError('Error rejecting user: ' + error.message);
        }
    }

    async markAsRead(notificationId) {
        try {
            await fetch(`/api/admin/notifications/${notificationId}/read`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${this.token}` }
            });
            
            await this.loadNotificationsWithActions();
        } catch (error) {
            console.error('Error marking as read:', error);
        }
    }

    updateBadge() {
        const badge = document.getElementById('notification-badge');
        if (badge) {
            badge.textContent = this.unreadCount;
            badge.style.display = this.unreadCount > 0 ? 'inline' : 'none';
        }
    }

    showSuccess(message) {
        // Implement your success notification UI
        alert('✅ ' + message);
    }

    showError(message) {
        // Implement your error notification UI
        alert('❌ ' + message);
    }

    // Auto-refresh every 10 seconds
    startAutoRefresh() {
        setInterval(() => {
            this.loadNotificationsWithActions();
        }, 10000);
    }
}

// Initialize in your dashboard
const adminNotifications = new AdminNotificationManager(authToken);
adminNotifications.loadNotificationsWithActions();
adminNotifications.startAutoRefresh();
```

### **CSS Styles**
```css
.notification-item {
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 1rem;
    background: white;
    transition: all 0.2s;
}

.notification-item.unread {
    border-left: 4px solid #007bff;
    background: #f8f9fa;
}

.notification-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.5rem;
}

.user-details {
    background: #f8f9fa;
    padding: 0.75rem;
    border-radius: 4px;
    margin: 0.5rem 0;
}

.detail-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.25rem;
}

.action-buttons {
    display: flex;
    gap: 0.5rem;
    margin-top: 1rem;
}

.btn-approve {
    background: #28a745;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    cursor: pointer;
}

.btn-reject {
    background: #dc3545;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    cursor: pointer;
}

.btn-mark-read {
    background: #6c757d;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    cursor: pointer;
}
```

## 🎯 **Key Features**

### ✅ **Notifications Don't Disappear**
- User details stay visible until action is taken
- Approve/reject buttons are always accessible
- Notifications are marked as read only when explicitly clicked

### ✅ **Complete User Information**
- Full user details in each notification
- Registration timestamp
- User role and contact info

### ✅ **Instant Actions**
- One-click approve/reject
- Immediate UI updates
- Confirmation dialogs for safety

### ✅ **Real-time Updates**
- Auto-refresh every 10 seconds
- Live notification badge updates
- Instant feedback on actions

## 🚀 **Integration Steps**

1. **Copy the JavaScript class** into your dashboard
2. **Add the CSS styles** to your stylesheet
3. **Create HTML container** with `id="notifications-container"`
4. **Initialize** with your admin token
5. **Test** by creating users via Postman

**Your web dashboard will now show persistent notifications with approve/reject actions that work perfectly!** 🎉