@extends('admin.layout')

@section('title', 'Admin Management')
@section('icon', 'fas fa-user-shield')

@section('content')
<style>
    .btn {
        padding: 10px 20px;
        border: none;
        border-radius: var(--radius-md);
        font-weight: 600;
        font-size: 0.85rem;
        cursor: pointer;
        transition: var(--transition);
        display: inline-flex;
        align-items: center;
        gap: var(--space-xs);
        text-decoration: none;
    }

    /* Delete animation */
    .admin-table tr.deleting {
        animation: slideOutLeft 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards;
        opacity: 0;
        transform-origin: center;
    }

    @keyframes slideOutLeft {
        0% {
            transform: translateX(0) scale(1);
            opacity: 1;
            max-height: 80px;
        }
        50% {
            transform: translateX(-20px) scale(0.98);
            opacity: 0.8;
            max-height: 80px;
        }
        100% {
            transform: translateX(-120%);
            opacity: 0;
            max-height: 0;
            padding-top: 0;
            padding-bottom: 0;
            margin-top: 0;
            margin-bottom: 0;
        }
    }
    .btn-primary {
        background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px), linear-gradient(135deg, var(--deep-green) 0%, var(--dark-secondary) 100%);
        color: var(--white) !important;
        border: none;
        border-radius: var(--radius-md);
        font-family: var(--font-primary);
        font-size: 0.85rem;
        font-weight: 600;
        cursor: pointer;
        transition: var(--transition);
        position: relative;
        overflow: hidden;
        display: inline-flex;
        align-items: center;
        gap: var(--space-xs);
        text-decoration: none;
        box-shadow: 0 4px 12px rgba(14, 19, 48, 0.3);
    }

    .btn-primary::before {
        content: '';
        position: absolute;
        width: 180%;
        height: 120%;
        left: -40%;
        top: -10%;
        transform: rotate(-18deg);
        background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%);
        clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%);
        pointer-events: none;
    }

    .btn-primary::after {
        content: '';
        position: absolute;
        width: 35px;
        height: 35px;
        right: 15px;
        top: 30%;
        border-radius: 50%;
        background: radial-gradient(circle at 30% 30%, var(--yellow-accent) 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%);
        opacity: 0.8;
        pointer-events: none;
    }

    .btn-primary *,
    .btn-primary .btn-text,
    .btn-primary .btn-loader,
    .btn-primary i,
    .btn-primary span {
        position: relative;
        z-index: 10;
        color: #ffffff !important;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
    }
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-lg);
    }
    .btn-danger {
        background: #EF4444;
        color: var(--white);
        font-size: 0.8rem;
        padding: 6px 12px;
    }
    .btn-danger:hover {
        background: #DC2626;
    }
    .admin-table {
        width: 100%;
        border-collapse: collapse;
    }
    .admin-table th {
        padding: var(--space-md);
        text-align: left;
        font-weight: 600;
        color: var(--text-dark);
        font-size: 0.85rem;
        border-bottom: 2px solid var(--border-grey);
        background: var(--light-grey);
    }
    .admin-table td {
        padding: var(--space-md);
        border-bottom: 1px solid var(--border-grey);
        font-size: 0.9rem;
    }
    .admin-table tr:hover {
        background: var(--off-white);
    }
    .admin-avatar {
        width: 40px;
        height: 40px;
        background: linear-gradient(135deg, var(--deep-green), var(--yellow-accent));
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--white);
        font-weight: 600;
        font-size: 0.85rem;
    }
    .badge {
        padding: 4px 12px;
        border-radius: var(--radius-lg);
        font-size: 0.75rem;
        font-weight: 600;
    }
    .badge-success {
        background: #10B98120;
        color: #10B981;
    }
    .badge-primary {
        background: var(--deep-green)20;
        color: var(--deep-green);
    }
</style>

<!-- Header Section -->
<div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: var(--space-2xl);">
    <div>
        <h2 style="font-size: 1.5rem; font-weight: 700; color: var(--text-dark); margin-bottom: var(--space-xs);">Administrator Management</h2>
        <p style="color: var(--text-grey); font-size: 0.9rem;">Manage admin accounts and permissions for the AUTOHIVE platform</p>
    </div>
    <a href="{{ route('admin.admins.create') }}" class="btn btn-primary">
        <span class="btn-text">
            <i class="fas fa-user-plus"></i>
            Add New Admin
        </span>
    </a>
</div>

<!-- Stats Cards -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-lg); margin-bottom: var(--space-2xl);">
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-icon">
                <i class="fas fa-users-cog"></i>
            </div>
        </div>
        <div class="stat-number">{{ $admins->total() }}</div>
        <div class="stat-label">Total Admins</div>
    </div>
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-icon">
                <i class="fas fa-user-check"></i>
            </div>
        </div>
        <div class="stat-number">{{ $admins->where('created_at', '>=', now()->subDays(30))->count() }}</div>
        <div class="stat-label">Added This Month</div>
    </div>
    <div class="stat-card">
        <div class="stat-header">
            <div class="stat-icon">
                <i class="fas fa-clock"></i>
            </div>
        </div>
        <div class="stat-number">{{ $admins->where('updated_at', '>=', now()->subDay())->count() }}</div>
        <div class="stat-label">Active Today</div>
    </div>
</div>

<!-- Admins Table -->
<div class="content-card">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-table"></i>
            Administrator Accounts ({{ $admins->total() }})
        </h3>
    </div>
    
    @if($admins->count() > 0)
        <div style="overflow-x: auto;">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Administrator</th>
                        <th>Contact</th>
                        <th>Joined</th>
                        <th>Last Activity</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($admins as $admin)
                    <tr>
                        <td>
                            <div style="display: flex; align-items: center; gap: var(--space-md);">
                                <div class="admin-avatar" style="position: relative; overflow: hidden;">
                                    @if($admin->profile_image)
                                        <img src="{{ $admin->profile_image_url }}" alt="Profile" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">
                                    @else
                                        {{ substr($admin->first_name, 0, 1) }}{{ substr($admin->last_name, 0, 1) }}
                                    @endif
                                </div>
                                <div>
                                    <div style="font-weight: 600; color: var(--text-dark);">{{ $admin->first_name }} {{ $admin->last_name }}</div>
                                    <div style="font-size: 0.8rem; color: var(--text-grey);">Administrator</div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div style="color: var(--text-dark); font-weight: 500;">{{ $admin->phone }}</div>
                            <div style="font-size: 0.8rem; color: var(--text-grey);">Phone Number</div>
                        </td>
                        <td>
                            <div style="color: var(--text-dark);">{{ $admin->created_at->format('M d, Y') }}</div>
                            <div style="font-size: 0.8rem; color: var(--text-grey);">{{ $admin->created_at->diffForHumans() }}</div>
                        </td>
                        <td>
                            <div style="color: var(--text-dark);">{{ $admin->updated_at->format('M d, H:i') }}</div>
                            <div style="font-size: 0.8rem; color: var(--text-grey);">{{ $admin->updated_at->diffForHumans() }}</div>
                        </td>
                        <td>
                            @if($admin->id === auth()->id())
                                <span class="badge badge-success">
                                    <i class="fas fa-user"></i>
                                    You
                                </span>
                            @else
                                <span class="badge badge-primary">
                                    <i class="fas fa-shield-alt"></i>
                                    Admin
                                </span>
                            @endif
                        </td>
                        <td>
                            @if($admin->id !== auth()->id())
                                <form method="POST" action="{{ route('admin.admins.delete', $admin->id) }}" style="display: inline;" id="deleteForm{{ $admin->id }}">
                                    @csrf
                                    @method('DELETE')
                                    <button type="button" class="btn btn-danger" onclick="confirmDeleteAdmin('{{ $admin->id }}', '{{ $admin->first_name }} {{ $admin->last_name }}')">
                                        <i class="fas fa-trash-alt"></i>
                                        Remove
                                    </button>
                                </form>
                            @else
                                <span style="color: var(--text-grey); font-size: 0.8rem; font-style: italic;">Cannot delete yourself</span>
                            @endif
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        
        @if($admins->hasPages())
            <div style="padding: var(--space-lg); border-top: 1px solid var(--border-grey);">
                {{ $admins->links() }}
            </div>
        @endif
    @else
        <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
            <i class="fas fa-users" style="font-size: 3rem; margin-bottom: var(--space-lg); opacity: 0.3;"></i>
            <h3 style="margin-bottom: var(--space-sm);">No Administrators Found</h3>
            <p style="margin-bottom: var(--space-lg);">Start by creating your first admin account.</p>
            <a href="{{ route('admin.admins.create') }}" class="btn btn-primary">
                <i class="fas fa-user-plus"></i>
                Create First Admin
            </a>
        </div>
    @endif
</div>
@endsection
