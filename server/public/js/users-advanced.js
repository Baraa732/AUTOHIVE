// Advanced Users Page JavaScript

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    initializeSparklines();
    initializeRealTimeUpdates();
    initializeAnimations();
});

// Sparkline Charts
function initializeSparklines() {
    const sparklineData = {
        total: [45, 52, 48, 65, 70, 68, 75],
        approved: [30, 35, 38, 42, 48, 50, 55],
        pending: [5, 8, 6, 10, 12, 8, 10],
        recent: [2, 3, 5, 8, 10, 12, 15]
    };

    const sparklineConfig = {
        type: 'line',
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false }, tooltip: { enabled: false } },
            scales: {
                x: { display: false },
                y: { display: false }
            },
            elements: {
                line: { borderWidth: 2, tension: 0.4 },
                point: { radius: 0 }
            }
        }
    };

    // Create sparklines
    createSparkline('sparklineTotal', sparklineData.total, '#0e1330');
    createSparkline('sparklineApproved', sparklineData.approved, '#10B981');
    createSparkline('sparklinePending', sparklineData.pending, '#F59E0B');
    createSparkline('sparklineRecent', sparklineData.recent, '#ff6f2d');
}

function createSparkline(canvasId, data, color) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;

    new Chart(canvas, {
        type: 'line',
        data: {
            labels: data.map((_, i) => i),
            datasets: [{
                data: data,
                borderColor: color,
                backgroundColor: color + '20',
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false }, tooltip: { enabled: false } },
            scales: {
                x: { display: false },
                y: { display: false }
            },
            elements: {
                line: { borderWidth: 2, tension: 0.4 },
                point: { radius: 0 }
            }
        }
    });
}

// Real-time Updates
function initializeRealTimeUpdates() {
    // Fetch real-time stats every 30 seconds
    setInterval(() => {
        fetchRealTimeStats();
        animateKPICards();
    }, 30000);
    
    // Initial fetch
    fetchRealTimeStats();
}

function fetchRealTimeStats() {
    fetch('/admin/users/stats', {
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        updateKPIValues(data);
        updateLiveIndicator();
    })
    .catch(error => {
        console.error('Error fetching stats:', error);
    });
}

function updateKPIValues(data) {
    if (data.total) animateCounter(document.getElementById('kpiTotal'), data.total);
    if (data.approved) animateCounter(document.getElementById('kpiApproved'), data.approved);
    if (data.pending) animateCounter(document.getElementById('kpiPending'), data.pending);
    if (data.recent) animateCounter(document.getElementById('kpiRecent'), data.recent);
    
    // Update total users in header
    if (data.total) {
        const totalUsersSpan = document.getElementById('totalUsers');
        if (totalUsersSpan) {
            animateCounter(totalUsersSpan, data.total);
        }
    }
}

function updateLiveIndicator() {
    const indicator = document.querySelector('[style*="Live Updates Active"]');
    if (indicator) {
        indicator.style.animation = 'none';
        setTimeout(() => {
            indicator.style.animation = 'pulse 0.5s ease';
        }, 10);
    }
}

function animateKPICards() {
    document.querySelectorAll('.kpi-card-advanced').forEach((card, index) => {
        setTimeout(() => {
            card.style.animation = 'none';
            setTimeout(() => {
                card.style.animation = 'pulse 0.5s ease';
            }, 10);
        }, index * 100);
    });
}

// Advanced Search
let searchTimeout;
function advancedSearch() {
    clearTimeout(searchTimeout);
    const searchInput = document.getElementById('searchInput');
    const searchValue = searchInput.value.toLowerCase().trim();
    const clearBtn = document.querySelector('.clear-search');

    // Show/hide clear button
    clearBtn.style.display = searchValue ? 'block' : 'none';

    searchTimeout = setTimeout(() => {
        const cards = document.querySelectorAll('.user-card');
        const rows = document.querySelectorAll('.users-list-view tbody tr');
        let visibleCount = 0;

        // Search in grid view
        cards.forEach(card => {
            const text = card.textContent.toLowerCase();
            const isVisible = text.includes(searchValue);
            card.style.display = isVisible ? 'block' : 'none';
            if (isVisible) visibleCount++;
        });

        // Search in list view
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            const isVisible = text.includes(searchValue);
            row.style.display = isVisible ? '' : 'none';
        });

        // Show no results message
        showNoResults(visibleCount === 0 && searchValue !== '');
    }, 300);
}

function clearSearch() {
    document.getElementById('searchInput').value = '';
    document.querySelector('.clear-search').style.display = 'none';
    advancedSearch();
}

function showNoResults(show) {
    let noResultsDiv = document.getElementById('noResults');
    
    if (show && !noResultsDiv) {
        noResultsDiv = document.createElement('div');
        noResultsDiv.id = 'noResults';
        noResultsDiv.className = 'no-results';
        noResultsDiv.innerHTML = `
            <div style="text-align: center; padding: 60px 20px; color: #5A6C7D;">
                <i class="fas fa-search" style="font-size: 3rem; margin-bottom: 20px; opacity: 0.3;"></i>
                <h3 style="margin-bottom: 10px;">No users found</h3>
                <p>Try adjusting your search or filters</p>
            </div>
        `;
        document.querySelector('.users-grid-view').appendChild(noResultsDiv);
    } else if (!show && noResultsDiv) {
        noResultsDiv.remove();
    }
}

// Quick Filters
function quickFilter(filter, button) {
    // Update active button
    document.querySelectorAll('.chip').forEach(chip => chip.classList.remove('active'));
    button.classList.add('active');

    const cards = document.querySelectorAll('.user-card');
    const rows = document.querySelectorAll('.users-list-view tbody tr');

    cards.forEach(card => {
        let show = false;
        switch(filter) {
            case 'all':
                show = true;
                break;
            case 'approved':
                show = card.dataset.status === 'approved';
                break;
            case 'pending':
                show = card.dataset.status === 'pending';
                break;
            case 'recent':
                show = card.dataset.recent === 'true';
                break;
        }
        card.style.display = show ? 'block' : 'none';
    });

    rows.forEach(row => {
        let show = false;
        switch(filter) {
            case 'all':
                show = true;
                break;
            case 'approved':
                show = row.dataset.status === 'approved';
                break;
            case 'pending':
                show = row.dataset.status === 'pending';
                break;
            case 'recent':
                show = row.dataset.recent === 'true';
                break;
        }
        row.style.display = show ? '' : 'none';
    });

    // Animate filter change
    animateFilterChange();
}

function animateFilterChange() {
    const gridView = document.getElementById('gridView');
    const listView = document.getElementById('listView');
    
    [gridView, listView].forEach(view => {
        if (view.style.display !== 'none') {
            view.style.opacity = '0';
            view.style.transform = 'translateY(20px)';
            setTimeout(() => {
                view.style.transition = 'all 0.4s ease';
                view.style.opacity = '1';
                view.style.transform = 'translateY(0)';
            }, 50);
        }
    });
}

// View Switcher
function switchView(view, button) {
    // Update active button
    document.querySelectorAll('.view-btn').forEach(btn => btn.classList.remove('active'));
    button.classList.add('active');

    const gridView = document.getElementById('gridView');
    const listView = document.getElementById('listView');

    if (view === 'grid') {
        gridView.style.display = 'grid';
        listView.style.display = 'none';
        animateViewChange(gridView);
    } else {
        gridView.style.display = 'none';
        listView.style.display = 'block';
        animateViewChange(listView);
    }
}

function animateViewChange(element) {
    element.style.opacity = '0';
    element.style.transform = 'scale(0.95)';
    setTimeout(() => {
        element.style.transition = 'all 0.4s ease';
        element.style.opacity = '1';
        element.style.transform = 'scale(1)';
    }, 50);
}

// Quick Actions
function quickApprove(userId, userName) {
    if (confirm(`Approve user: ${userName}?`)) {
        showLoadingOverlay();
        document.getElementById(`approveForm${userId}`).submit();
    }
}

function quickDelete(userId, userName, action) {
    const actionText = action === 'delete' ? 'delete' : 'reject';
    if (confirm(`Are you sure you want to ${actionText} user: ${userName}?`)) {
        showLoadingOverlay();
        document.getElementById(`deleteForm${userId}`).submit();
    }
}

function viewUserDetails(userId) {
    const modal = document.getElementById('userDetailModal');
    const content = document.getElementById('userDetailContent');
    
    // Show modal
    modal.style.display = 'flex';
    
    // Fetch user details
    fetch(`/admin/users/${userId}`, {
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json'
        }
    })
    .then(response => response.text())
    .then(html => {
        // If response is JSON, handle it; otherwise it's HTML
        try {
            const data = JSON.parse(html);
            content.innerHTML = formatUserDetails(data);
        } catch (e) {
            // It's HTML, show it directly or navigate
            window.location.href = `/admin/users/${userId}`;
        }
    })
    .catch(error => {
        console.error('Error:', error);
        content.innerHTML = `
            <div style="text-align: center; padding: 40px; color: #EF4444;">
                <i class="fas fa-exclamation-circle" style="font-size: 3rem; margin-bottom: 20px;"></i>
                <h3>Error loading user details</h3>
                <p>Please try again later</p>
            </div>
        `;
    });
}

function closeUserModal() {
    const modal = document.getElementById('userDetailModal');
    modal.style.animation = 'fadeOut 0.3s ease';
    setTimeout(() => {
        modal.style.display = 'none';
        modal.style.animation = '';
    }, 300);
}

function formatUserDetails(user) {
    return `
        <div style="display: grid; gap: 20px;">
            <div style="text-align: center; padding: 20px; background: linear-gradient(135deg, #F9FAFB, #F3F4F6); border-radius: 12px;">
                <div style="width: 100px; height: 100px; margin: 0 auto 16px; background: linear-gradient(135deg, #0e1330, #ff6f2d); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 2.5rem; font-weight: 700;">
                    ${user.first_name.charAt(0)}${user.last_name.charAt(0)}
                </div>
                <h3 style="margin: 0 0 8px 0; color: #0e1330;">${user.first_name} ${user.last_name}</h3>
                <p style="margin: 0; color: #5A6C7D; font-size: 0.9rem;">ID: ${user.id}</p>
            </div>
            
            <div style="display: grid; gap: 16px;">
                <div style="padding: 16px; background: white; border: 1px solid #E5E7EB; border-radius: 12px;">
                    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 8px;">
                        <i class="fas fa-phone" style="color: #ff6f2d; width: 20px;"></i>
                        <strong style="color: #0e1330;">Phone:</strong>
                    </div>
                    <p style="margin: 0; padding-left: 32px; color: #5A6C7D;">${user.phone}</p>
                </div>
                
                <div style="padding: 16px; background: white; border: 1px solid #E5E7EB; border-radius: 12px;">
                    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 8px;">
                        <i class="fas fa-calendar" style="color: #ff6f2d; width: 20px;"></i>
                        <strong style="color: #0e1330;">Registered:</strong>
                    </div>
                    <p style="margin: 0; padding-left: 32px; color: #5A6C7D;">${new Date(user.created_at).toLocaleDateString()}</p>
                </div>
                
                <div style="padding: 16px; background: white; border: 1px solid #E5E7EB; border-radius: 12px;">
                    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 8px;">
                        <i class="fas fa-check-circle" style="color: #ff6f2d; width: 20px;"></i>
                        <strong style="color: #0e1330;">Status:</strong>
                    </div>
                    <p style="margin: 0; padding-left: 32px;">
                        <span style="padding: 6px 12px; border-radius: 8px; font-size: 0.85rem; font-weight: 600; background: ${user.is_approved ? 'rgba(16, 185, 129, 0.1)' : 'rgba(245, 158, 11, 0.1)'}; color: ${user.is_approved ? '#10B981' : '#F59E0B'};">
                            ${user.is_approved ? 'Approved' : 'Pending'}
                        </span>
                    </p>
                </div>
            </div>
            
            <div style="display: flex; gap: 12px; margin-top: 20px;">
                <button onclick="window.location.href='/admin/users/${user.id}'" style="flex: 1; padding: 14px; background: #0e1330; color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; transition: all 0.3s ease;" onmouseover="this.style.background='#ff6f2d'" onmouseout="this.style.background='#0e1330'">
                    <i class="fas fa-external-link-alt"></i> View Full Profile
                </button>
                <button onclick="closeUserModal()" style="padding: 14px 24px; background: #E5E7EB; color: #0e1330; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; transition: all 0.3s ease;" onmouseover="this.style.background='#D1D5DB'" onmouseout="this.style.background='#E5E7EB'">
                    Close
                </button>
            </div>
        </div>
    `;
}

// Export Users
function exportUsers() {
    showNotification('Exporting users...', 'info');
    
    // Simulate export
    setTimeout(() => {
        showNotification('Users exported successfully!', 'success');
    }, 1500);
}

// Refresh Users
let isRefreshing = false;
function refreshUsers() {
    if (isRefreshing) return;
    isRefreshing = true;
    
    const refreshIcon = document.getElementById('refreshIcon');
    if (refreshIcon) {
        refreshIcon.style.animation = 'spin 1s linear infinite';
    }
    
    showNotification('Refreshing data...', 'info');
    
    fetchRealTimeStats();
    
    setTimeout(() => {
        if (refreshIcon) {
            refreshIcon.style.animation = '';
        }
        isRefreshing = false;
    }, 1500);
}

// Loading Overlay
function showLoadingOverlay() {
    let overlay = document.getElementById('loadingOverlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'loadingOverlay';
        overlay.innerHTML = `
            <div style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(14, 19, 48, 0.9); display: flex; align-items: center; justify-content: center; z-index: 9999;">
                <div style="text-align: center; color: white;">
                    <div class="spinner" style="width: 50px; height: 50px; border: 4px solid rgba(255, 255, 255, 0.3); border-top-color: #ff6f2d; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 20px;"></div>
                    <p style="font-size: 1.1rem; font-weight: 600;">Loading...</p>
                </div>
            </div>
        `;
        document.body.appendChild(overlay);
    }
}

// Notifications
function showNotification(message, type = 'info') {
    if (!message || message === 'undefined') return;
    
    // Prevent duplicate notifications
    const existingNotifications = document.querySelectorAll('.notification');
    existingNotifications.forEach(notif => notif.remove());
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 16px 24px;
        background: ${type === 'success' ? '#10B981' : type === 'error' ? '#EF4444' : '#0e1330'};
        color: white;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        z-index: 10000;
        animation: slideInRight 0.4s ease;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 12px;
    `;
    
    const icon = type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle';
    notification.innerHTML = `
        <i class="fas fa-${icon}"></i>
        <span>${message}</span>
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.4s ease';
        setTimeout(() => notification.remove(), 400);
    }, 3000);
}

// Initialize Animations
function initializeAnimations() {
    // Add entrance animations to cards
    const cards = document.querySelectorAll('.user-card');
    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        setTimeout(() => {
            card.style.transition = 'all 0.4s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, index * 50);
    });
}

// Keyboard Shortcuts
document.addEventListener('keydown', function(e) {
    // Escape: Close modal
    if (e.key === 'Escape') {
        const modal = document.getElementById('userDetailModal');
        if (modal && modal.style.display === 'flex') {
            closeUserModal();
        }
    }
});

// Close modal on outside click
document.getElementById('userDetailModal')?.addEventListener('click', function(e) {
    if (e.target === this) {
        closeUserModal();
    }
});

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
    
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    @keyframes pulse {
        0%, 100% {
            transform: scale(1);
        }
        50% {
            transform: scale(1.02);
        }
    }
`;
document.head.appendChild(style);

// Real-time user count animation
function animateCounter(element, target) {
    const duration = 1000;
    const start = parseInt(element.textContent) || 0;
    const increment = (target - start) / (duration / 16);
    let current = start;
    
    const timer = setInterval(() => {
        current += increment;
        if ((increment > 0 && current >= target) || (increment < 0 && current <= target)) {
            element.textContent = target;
            clearInterval(timer);
        } else {
            element.textContent = Math.round(current);
        }
    }, 16);
}

// Handle form submissions with AJAX for better UX
document.addEventListener('submit', function(e) {
    if (e.target.matches('form[id^="approveForm"], form[id^="deleteForm"]')) {
        e.preventDefault();
        
        const form = e.target;
        const formData = new FormData(form);
        
        fetch(form.action, {
            method: form.method,
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content || ''
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification(data.message || 'Action completed successfully!', 'success');
                setTimeout(() => location.reload(), 1500);
            } else {
                showNotification(data.message || 'Action failed!', 'error');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showNotification('An error occurred. Please try again.', 'error');
        })
        .finally(() => {
            document.getElementById('loadingOverlay')?.remove();
        });
    }
});
