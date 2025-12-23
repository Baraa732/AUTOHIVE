@extends('admin.layout')

@section('title', 'Notifications')
@section('icon', 'fas fa-bell')

@section('content')
<div class="content-card">
    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
        <h3 class="card-title">
            <i class="fas fa-bell"></i>
            User Approval Notifications
        </h3>
        <button onclick="refreshNotifications()" id="refreshBtn" style="background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px), linear-gradient(135deg, #0e1330, #17173a); color: white; border: none; padding: 8px 16px; border-radius: 8px; cursor: pointer; font-size: 0.8rem; position: relative; overflow: hidden;">
            <div style="position: absolute; width: 180%; height: 120%; left: -40%; top: -10%; transform: rotate(-18deg); background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%); clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%); pointer-events: none;"></div>
            <div style="position: absolute; width: 15px; height: 15px; right: 3px; top: 25%; border-radius: 50%; background: radial-gradient(circle at 30% 30%, #ff6f2d 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%); opacity: 0.8; pointer-events: none;"></div>
            <span style="position: relative; z-index: 2;"><i class="fas fa-sync-alt"></i> Refresh</span>
        </button>
    </div>
    <div id="notificationsContent" style="padding: var(--space-lg);">
        <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
            <i class="fas fa-spinner fa-spin" style="font-size: 2rem; margin-bottom: var(--space-md);"></i>
            <p>Loading notifications...</p>
        </div>
    </div>
</div>

<script>
    console.log('🚀 Notifications page script loaded');
    
    // Load notifications on page load
    document.addEventListener('DOMContentLoaded', function() {
        console.log('✅ DOM Content Loaded - Starting notification load');
        loadUserApprovalNotifications();
        
        // Auto-refresh every 5 seconds
        setInterval(loadUserApprovalNotifications, 5000);
    });

    function loadUserApprovalNotifications() {
        console.log('📡 Fetching notifications from /admin/notifications/pending');
        fetch('/admin/notifications/pending', {
            method: 'GET',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            credentials: 'same-origin'
        })
        .then(response => {
            console.log('📥 Response received, status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('✅ Notifications API Response:', data);
            const content = document.getElementById('notificationsContent');
            
            if (data.success && data.data.length > 0) {
                console.log('📊 Total pending users:', data.data.length);
                let html = '';
                data.data.forEach((notification, index) => {
                    const user = notification.user;
                    const profileImg = user.profile_image_url || '';
                    const idImg = user.id_image_url || '';
                    
                    console.log(`👤 User ${index + 1}:`, {
                        name: user.name,
                        profile_image_url: profileImg,
                        id_image_url: idImg,
                        has_profile: !!profileImg,
                        has_id: !!idImg
                    });
                    
                    // Build images HTML
                    let imagesHtml = '';
                    if (profileImg || idImg) {
                        imagesHtml = '<div style="display: flex; gap: var(--space-md); margin-bottom: var(--space-md); padding: var(--space-md); background: #f9fafb; border-radius: 8px;">';
                        
                        if (profileImg) {
                            imagesHtml += `
                                <div>
                                    <strong style="display: block; margin-bottom: 8px; color: #374151; font-size: 0.875rem;">Profile Photo:</strong>
                                    <img src="${profileImg}" alt="Profile" style="width: 100px; height: 100px; object-fit: cover; border-radius: 12px; border: 3px solid #e5e7eb; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                                </div>
                            `;
                        }
                        
                        if (idImg) {
                            imagesHtml += `
                                <div>
                                    <strong style="display: block; margin-bottom: 8px; color: #374151; font-size: 0.875rem;">ID Image:</strong>
                                    <img src="${idImg}" alt="ID" style="width: 140px; height: 100px; object-fit: cover; border-radius: 12px; border: 3px solid #e5e7eb; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.1);" onclick="window.open('${idImg}', '_blank')" title="Click to view full size">
                                </div>
                            `;
                        }
                        
                        imagesHtml += '</div>';
                    }
                    
                    html += `
                    <div style="background: var(--white); border: 1px solid var(--border-grey); border-radius: var(--radius-md); padding: var(--space-lg); margin-bottom: var(--space-md); box-shadow: var(--shadow-soft);">
                        <h4 style="color: var(--text-dark); font-size: 1rem; font-weight: 600; margin-bottom: var(--space-sm);">${notification.title}</h4>
                        <p style="color: var(--text-grey); margin-bottom: var(--space-md); font-size: 0.9rem;">${notification.message}</p>
                        
                        <button onclick="toggleDetails('details-${user.id}', ${user.id})" id="btn-${user.id}" style="background: #3B82F6; color: white; border: none; padding: 10px 20px; border-radius: var(--radius-sm); cursor: pointer; font-weight: 500; margin-bottom: var(--space-md);">
                            <i class="fas fa-eye" id="icon-${user.id}"></i> <span id="text-${user.id}">Show Details</span>
                        </button>
                        
                        <div id="details-${user.id}" style="display: none;">
                            <div style="background: #f3f4f6; padding: var(--space-lg); border-radius: var(--radius-md); margin-bottom: var(--space-md);">
                                ${imagesHtml}
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-md); font-size: 0.9rem; margin-top: var(--space-md);">
                                    <div><strong>ID:</strong> ${user.display_id}</div>
                                    <div><strong>Name:</strong> ${user.name}</div>
                                    <div><strong>Email:</strong> ${user.email}</div>
                                    <div><strong>Role:</strong> <span style="text-transform: capitalize;">${user.role}</span></div>
                                    <div><strong>Phone:</strong> ${user.phone}</div>
                                    <div><strong>Status:</strong> <span style="color: #F59E0B; font-weight: 600;">Pending Approval</span></div>
                                </div>
                            </div>
                            
                            <div style="display: flex; gap: var(--space-sm);">
                                <button onclick="approveUser(${user.id})" style="background: #10B981; color: white; border: none; padding: 10px 20px; border-radius: var(--radius-sm); cursor: pointer; font-weight: 500;">
                                    <i class="fas fa-check"></i> Approve User
                                </button>
                                <button onclick="rejectUser(${user.id})" style="background: #EF4444; color: white; border: none; padding: 10px 20px; border-radius: var(--radius-sm); cursor: pointer; font-weight: 500;">
                                    <i class="fas fa-times"></i> Reject User
                                </button>
                            </div>
                        </div>
                    </div>
                    `;
                });
                content.innerHTML = html;
            } else {
                content.innerHTML = `
                    <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
                        <i class="fas fa-bell-slash" style="font-size: 3rem; margin-bottom: var(--space-md); opacity: 0.3;"></i>
                        <h3 style="margin-bottom: var(--space-sm);">No Pending Notifications</h3>
                        <p>All user approval requests have been processed.</p>
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('❌ Error loading notifications:', error);
            console.error('Error details:', error.message, error.stack);
            document.getElementById('notificationsContent').innerHTML = `
                <div style="text-align: center; padding: var(--space-2xl); color: #EF4444;">
                    <i class="fas fa-exclamation-triangle" style="font-size: 2rem; margin-bottom: var(--space-md);"></i>
                    <p>Failed to load notifications</p>
                </div>
            `;
        });
    }

    function approveUser(userId) {
        fetch(`/admin/notifications/approve-user/${userId}`, {
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            credentials: 'same-origin'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification('success', 'Success', 'User approved successfully');
                setTimeout(() => {
                    loadUserApprovalNotifications();
                    updateNotificationBadges();
                }, 500);
            } else {
                showNotification('error', 'Error', data.message || 'Failed to approve user');
            }
        })
        .catch(() => showNotification('error', 'Error', 'Failed to approve user'));
    }

    function rejectUser(userId) {
        showConfirmModal(
            'Reject User',
            'Are you sure you want to reject this user? This action cannot be undone.',
            function() {
                fetch(`/admin/notifications/reject-user/${userId}`, {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                        'Accept': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    credentials: 'same-origin'
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('success', 'Success', 'User rejected successfully');
                        setTimeout(() => {
                            loadUserApprovalNotifications();
                            updateNotificationBadges();
                        }, 500);
                    } else {
                        showNotification('error', 'Error', data.message || 'Failed to reject user');
                    }
                })
                .catch(() => showNotification('error', 'Error', 'Failed to reject user'));
            }
        );
    }

    function refreshNotifications() {
        const refreshBtn = document.getElementById('refreshBtn');
        const originalHTML = refreshBtn.innerHTML;
        
        refreshBtn.innerHTML = '<span style="position: relative; z-index: 2;"><i class="fas fa-spinner fa-spin"></i> Refreshing...</span>';
        refreshBtn.disabled = true;

        setTimeout(() => {
            loadUserApprovalNotifications();
            updateNotificationBadges();
            
            refreshBtn.innerHTML = originalHTML;
            refreshBtn.disabled = false;
        }, 1000);
    }

    function toggleDetails(detailsId, userId) {
        const details = document.getElementById(detailsId);
        const icon = document.getElementById('icon-' + userId);
        const text = document.getElementById('text-' + userId);
        
        if (details.style.display === 'none' || details.style.display === '') {
            details.style.display = 'block';
            icon.className = 'fas fa-eye-slash';
            text.textContent = 'Hide Details';
        } else {
            details.style.display = 'none';
            icon.className = 'fas fa-eye';
            text.textContent = 'Show Details';
        }
    }

    function updateNotificationBadges() {
        fetch('/admin/notifications/pending', {
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            credentials: 'same-origin'
        })
        .then(response => response.json())
        .then(data => {
            const count = data.success ? data.data.length : 0;
            const sidebarBadge = document.getElementById('sidebarNotificationBadge');
            const headerBadge = document.getElementById('notificationBadge');
            
            if (count > 0) {
                if (sidebarBadge) {
                    sidebarBadge.textContent = count;
                    sidebarBadge.style.display = 'inline';
                }
                if (headerBadge) {
                    headerBadge.textContent = count;
                    headerBadge.style.display = 'flex';
                }
            } else {
                if (sidebarBadge) sidebarBadge.style.display = 'none';
                if (headerBadge) headerBadge.style.display = 'none';
            }
        })
        .catch(error => console.log('Failed to update badges:', error));
    }
</script>
@endsection
