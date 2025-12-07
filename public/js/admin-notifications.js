class AdminNotifications {
    constructor(apiBaseUrl = 'http://localhost:8000/api') {
        this.apiUrl = apiBaseUrl;
        this.token = localStorage.getItem('admin_token');
        this.container = null;
        this.pollInterval = null;
    }

    init(containerId = 'notifications-section') {
        this.container = document.getElementById(containerId);
        if (!this.container) {
            this.container = this.createContainer();
            document.body.appendChild(this.container);
        }
        this.startPolling();
    }

    createContainer() {
        const container = document.createElement('div');
        container.id = 'notifications-section';
        container.innerHTML = `
            <div class="notification-header">
                <h3>Admin Notifications</h3>
                <span class="notification-count">0</span>
            </div>
            <div class="notification-list"></div>
        `;
        return container;
    }

    async fetchNotifications() {
        try {
            const response = await fetch(`${this.apiUrl}/admin/notifications-with-actions`, {
                headers: { 'Authorization': `Bearer ${this.token}` }
            });
            const data = await response.json();
            if (data.success) {
                this.renderNotifications(data.data);
            }
        } catch (error) {
            console.error('Failed to fetch notifications:', error);
        }
    }

    renderNotifications(notifications) {
        const list = this.container.querySelector('.notification-list');
        const count = this.container.querySelector('.notification-count');
        
        count.textContent = notifications.length;
        
        if (notifications.length === 0) {
            list.innerHTML = '<p class="no-notifications">No pending notifications</p>';
            return;
        }

        list.innerHTML = notifications.map(notification => `
            <div class="notification-item" data-id="${notification.id}">
                <div class="notification-content">
                    <h4>${notification.title}</h4>
                    <p>${notification.message}</p>
                    ${notification.user ? `
                        <div class="user-details">
                            <strong>User:</strong> ${notification.user.name} (${notification.user.email})
                            <br><strong>Role:</strong> ${notification.user.role}
                        </div>
                    ` : ''}
                </div>
                <div class="notification-actions">
                    <button onclick="adminNotifications.approveUser(${notification.user?.id})" class="btn-approve">Approve</button>
                    <button onclick="adminNotifications.rejectUser(${notification.user?.id})" class="btn-reject">Reject</button>
                </div>
            </div>
        `).join('');
    }

    async approveUser(userId) {
        try {
            const response = await fetch(`${this.apiUrl}/admin/approve-user/${userId}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${this.token}` }
            });
            const data = await response.json();
            if (data.success) {
                this.showMessage('User approved successfully', 'success');
                this.fetchNotifications();
            }
        } catch (error) {
            this.showMessage('Failed to approve user', 'error');
        }
    }

    async rejectUser(userId) {
        try {
            const response = await fetch(`${this.apiUrl}/admin/reject-user/${userId}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${this.token}` }
            });
            const data = await response.json();
            if (data.success) {
                this.showMessage('User rejected successfully', 'success');
                this.fetchNotifications();
            }
        } catch (error) {
            this.showMessage('Failed to reject user', 'error');
        }
    }

    showMessage(message, type) {
        const msg = document.createElement('div');
        msg.className = `message ${type}`;
        msg.textContent = message;
        document.body.appendChild(msg);
        setTimeout(() => msg.remove(), 3000);
    }

    startPolling() {
        this.fetchNotifications();
        this.pollInterval = setInterval(() => this.fetchNotifications(), 5000);
    }

    stopPolling() {
        if (this.pollInterval) {
            clearInterval(this.pollInterval);
        }
    }
}

// Global instance
const adminNotifications = new AdminNotifications();

// CSS styles
const style = document.createElement('style');
style.textContent = `
#notifications-section {
    position: fixed;
    top: 20px;
    right: 20px;
    width: 400px;
    max-height: 600px;
    background: white;
    border: 1px solid #ddd;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    z-index: 1000;
    overflow: hidden;
}

.notification-header {
    background: #007bff;
    color: white;
    padding: 15px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.notification-header h3 {
    margin: 0;
    font-size: 16px;
}

.notification-count {
    background: rgba(255,255,255,0.3);
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
}

.notification-list {
    max-height: 500px;
    overflow-y: auto;
}

.notification-item {
    padding: 15px;
    border-bottom: 1px solid #eee;
}

.notification-content h4 {
    margin: 0 0 8px 0;
    color: #333;
    font-size: 14px;
}

.notification-content p {
    margin: 0 0 10px 0;
    color: #666;
    font-size: 13px;
}

.user-details {
    background: #f8f9fa;
    padding: 8px;
    border-radius: 4px;
    font-size: 12px;
    margin: 8px 0;
}

.notification-actions {
    display: flex;
    gap: 8px;
    margin-top: 10px;
}

.btn-approve, .btn-reject {
    padding: 6px 12px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
}

.btn-approve {
    background: #28a745;
    color: white;
}

.btn-reject {
    background: #dc3545;
    color: white;
}

.btn-approve:hover {
    background: #218838;
}

.btn-reject:hover {
    background: #c82333;
}

.no-notifications {
    padding: 20px;
    text-align: center;
    color: #666;
    font-style: italic;
}

.message {
    position: fixed;
    top: 10px;
    left: 50%;
    transform: translateX(-50%);
    padding: 10px 20px;
    border-radius: 4px;
    color: white;
    z-index: 1001;
}

.message.success {
    background: #28a745;
}

.message.error {
    background: #dc3545;
}
`;
document.head.appendChild(style);