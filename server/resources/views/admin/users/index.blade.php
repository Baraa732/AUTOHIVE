@extends('admin.layout')

@section('title', 'Users Management')
@section('icon', 'fas fa-users')

@section('content')
<!-- Stats Grid -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-icon">
                <i class="fas fa-users"></i>
            </div>
        </div>
        <div class="stat-number">{{ $stats['total_users'] }}</div>
        <div class="stat-label">Total Users</div>
    </div>
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-icon">
                <i class="fas fa-home"></i>
            </div>
        </div>
        <div class="stat-number">{{ $stats['total_with_apartments'] }}</div>
        <div class="stat-label">Users with Apartments</div>
    </div>
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-icon">
                <i class="fas fa-calendar"></i>
            </div>
        </div>
        <div class="stat-number">{{ $stats['total_with_bookings'] }}</div>
        <div class="stat-label">Users with Bookings</div>
    </div>
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-icon">
                <i class="fas fa-clock"></i>
            </div>
        </div>
        <div class="stat-number">{{ $stats['pending_approvals'] }}</div>
        <div class="stat-label">Pending Approvals</div>
    </div>
</div>

<!-- Users Table -->
<div class="content-card">
    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
        <h3 class="card-title">
            <i class="fas fa-users"></i>
            Approved Users
        </h3>
        
        <!-- Search and Filter -->
        <div style="display: flex; gap: var(--space-md); align-items: center;">
            <form method="GET" style="display: flex; gap: var(--space-sm);">
                <select name="role" style="padding: 8px 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm);">
                    <option value="">All Users</option>
                </select>
                <input type="text" name="search" placeholder="Search users..." value="{{ request('search') }}" style="padding: 8px 12px; border: 1px solid var(--border-grey); border-radius: var(--radius-sm); width: 200px;">
                <button type="submit" style="background: var(--deep-green); color: white; border: none; padding: 8px 16px; border-radius: var(--radius-sm); cursor: pointer;">
                    <i class="fas fa-search"></i>
                </button>
                @if(request('search') || request('role'))
                    <a href="{{ route('admin.users') }}" style="background: var(--text-grey); color: white; text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);">
                        <i class="fas fa-times"></i>
                    </a>
                @endif
            </form>
        </div>
    </div>
    
    <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="background: var(--light-grey);">
                    <th style="padding: var(--space-md); text-align: left; font-weight: 600; color: var(--text-dark); font-size: 0.85rem; border-bottom: 1px solid var(--border-grey);">User</th>
                    <th style="padding: var(--space-md); text-align: left; font-weight: 600; color: var(--text-dark); font-size: 0.85rem; border-bottom: 1px solid var(--border-grey);">Role</th>
                    <th style="padding: var(--space-md); text-align: left; font-weight: 600; color: var(--text-dark); font-size: 0.85rem; border-bottom: 1px solid var(--border-grey);">Phone</th>
                    <th style="padding: var(--space-md); text-align: left; font-weight: 600; color: var(--text-dark); font-size: 0.85rem; border-bottom: 1px solid var(--border-grey);">Status</th>
                    <th style="padding: var(--space-md); text-align: left; font-weight: 600; color: var(--text-dark); font-size: 0.85rem; border-bottom: 1px solid var(--border-grey);">Joined</th>
                    <th style="padding: var(--space-md); text-align: left; font-weight: 600; color: var(--text-dark); font-size: 0.85rem; border-bottom: 1px solid var(--border-grey);">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($users as $user)
                    <tr style="border-bottom: 1px solid var(--border-grey);">
                        <td style="padding: var(--space-md); font-size: 0.9rem;">
                            <div style="display: flex; align-items: center; gap: var(--space-sm);">
                                @if($user->profile_image_url)
                                    <img src="{{ $user->profile_image_url }}" alt="Profile" style="width: 40px; height: 40px; object-fit: cover; border-radius: 50%; border: 2px solid var(--border-grey);">
                                @else
                                    <div style="width: 40px; height: 40px; background: linear-gradient(135deg, var(--deep-green), var(--yellow-accent)); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: var(--white); font-size: 0.8rem; font-weight: 600;">
                                        {{ substr($user->first_name, 0, 1) }}{{ substr($user->last_name, 0, 1) }}
                                    </div>
                                @endif
                                <div>
                                    <div style="font-weight: 500; color: var(--text-dark);">{{ $user->first_name }} {{ $user->last_name }}</div>
                                    <div style="font-size: 0.8rem; color: var(--text-grey);">ID: {{ $user->display_id }}</div>
                                </div>
                            </div>
                        </td>
                        <td style="padding: var(--space-md); font-size: 0.9rem;">
                            <span style="padding: 4px 12px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 600; background: #10B98120; color: #10B981;">
                                User
                            </span>
                        </td>
                        <td style="padding: var(--space-md); font-size: 0.9rem; color: var(--text-dark);">{{ $user->phone }}</td>
                        <td style="padding: var(--space-md);">
                            <span style="padding: 4px 12px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 600; background: #10B98120; color: #10B981;">
                                Approved
                            </span>
                        </td>
                        <td style="padding: var(--space-md); font-size: 0.9rem; color: var(--text-dark);">{{ $user->created_at->format('M d, Y') }}</td>
                        <td style="padding: var(--space-md);">
                            <div style="display: flex; gap: var(--space-xs);">
                                <a href="{{ route('admin.users.show', $user->id) }}" style="background: var(--deep-green); color: white; text-decoration: none; padding: 6px 12px; border-radius: var(--radius-sm); font-size: 0.8rem;">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <button onclick="deleteUser({{ $user->id }}, '{{ $user->first_name }} {{ $user->last_name }}')" style="background: #EF4444; color: white; border: none; padding: 6px 12px; border-radius: var(--radius-sm); cursor: pointer; font-size: 0.8rem;">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" style="padding: var(--space-2xl); text-align: center; color: var(--text-grey);">
                            <i class="fas fa-users" style="font-size: 2rem; margin-bottom: var(--space-md); opacity: 0.5; display: block;"></i>
                            No approved users found
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    @if($users->hasPages())
        <div style="padding: var(--space-lg); border-top: 1px solid var(--border-grey);">
            {{ $users->links() }}
        </div>
    @endif
</div>
<script>
let deleteButton = null;

function deleteUser(userId, userName) {
    deleteButton = event.target.closest('button');
    showConfirmModal(
        'Delete User',
        `Are you sure you want to permanently delete "${userName}"? This will remove all their data including apartments, bookings, and reviews. This action cannot be undone.`,
        function() {
            performDeleteUser(userId, userName);
        }
    );
}

function performDeleteUser(userId, userName) {
    if (!deleteButton) return;
    
    const originalContent = deleteButton.innerHTML;
    deleteButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    deleteButton.disabled = true;
    
    fetch(`{{ url('/admin/users') }}/${userId}`, {
        method: 'DELETE',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            'Accept': 'application/json'
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        const row = deleteButton.closest('tr');
        row.style.transition = 'all 0.3s ease';
        row.style.opacity = '0';
        row.style.transform = 'translateX(-20px)';
        
        setTimeout(() => {
            row.remove();
            showNotification('success', 'User Deleted', `${userName} has been permanently deleted from the system.`);
        }, 300);
    })
    .catch(error => {
        console.error('Delete error:', error);
        showNotification('error', 'Delete Failed', 'An error occurred while deleting the user');
        deleteButton.innerHTML = originalContent;
        deleteButton.disabled = false;
    });
}
</script>
@endsection