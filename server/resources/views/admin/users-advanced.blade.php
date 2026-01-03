@extends('admin.layout')

@section('title', 'Users Management')
@section('icon', 'fas fa-users')

@section('content')
    <link rel="stylesheet" href="{{ asset('css/users-advanced.css') }}">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

    <!-- Advanced Header -->
    <div class="users-header">
        <div class="header-content">
            <div class="header-left">
                <h1 class="page-title-advanced">User Management</h1>
                <p class="page-subtitle">Real-time user analytics • <span id="totalUsers">{{ $users->total() }}</span> total users</p>
            </div>
            <div class="header-actions">
                <button class="action-btn-advanced" onclick="exportUsers()">
                    <i class="fas fa-download"></i> Export
                </button>
                <button class="action-btn-advanced primary" onclick="refreshUsers()">
                    <i class="fas fa-sync-alt" id="refreshIcon"></i> Refresh
                </button>
            </div>
        </div>
    </div>

    <!-- Real-time Analytics Dashboard -->
    <div class="analytics-dashboard">
        <!-- KPI Cards -->
        <div class="kpi-cards-grid">
            <div class="kpi-card-advanced" data-kpi="total">
                <div class="kpi-icon-advanced total">
                    <i class="fas fa-users"></i>
                </div>
                <div class="kpi-data">
                    <div class="kpi-value-advanced" id="kpiTotal">{{ $users->total() }}</div>
                    <div class="kpi-label-advanced">Total Users</div>
                    <div class="kpi-change positive">
                        <i class="fas fa-arrow-up"></i> <span>12.5%</span>
                    </div>
                </div>
                <div class="kpi-sparkline">
                    <canvas id="sparklineTotal"></canvas>
                </div>
            </div>

            <div class="kpi-card-advanced" data-kpi="approved">
                <div class="kpi-icon-advanced approved">
                    <i class="fas fa-user-check"></i>
                </div>
                <div class="kpi-data">
                    <div class="kpi-value-advanced" id="kpiApproved">{{ $users->where('is_approved', true)->count() }}</div>
                    <div class="kpi-label-advanced">Approved</div>
                    <div class="kpi-change positive">
                        <i class="fas fa-arrow-up"></i> <span>8.3%</span>
                    </div>
                </div>
                <div class="kpi-sparkline">
                    <canvas id="sparklineApproved"></canvas>
                </div>
            </div>

            <div class="kpi-card-advanced urgent" data-kpi="pending">
                <div class="kpi-icon-advanced pending">
                    <i class="fas fa-user-clock"></i>
                </div>
                <div class="kpi-data">
                    <div class="kpi-value-advanced" id="kpiPending">{{ $users->where('is_approved', false)->count() }}</div>
                    <div class="kpi-label-advanced">Pending Approval</div>
                    <div class="kpi-change urgent-text">
                        <i class="fas fa-exclamation-circle"></i> <span>Action Required</span>
                    </div>
                </div>
                <div class="kpi-sparkline">
                    <canvas id="sparklinePending"></canvas>
                </div>
            </div>

            <div class="kpi-card-advanced" data-kpi="recent">
                <div class="kpi-icon-advanced recent">
                    <i class="fas fa-calendar-plus"></i>
                </div>
                <div class="kpi-data">
                    <div class="kpi-value-advanced" id="kpiRecent">{{ $users->where('created_at', '>=', now()->subDays(7))->count() }}</div>
                    <div class="kpi-label-advanced">This Week</div>
                    <div class="kpi-change positive">
                        <i class="fas fa-arrow-up"></i> <span>New registrations</span>
                    </div>
                </div>
                <div class="kpi-sparkline">
                    <canvas id="sparklineRecent"></canvas>
                </div>
            </div>
        </div>

        <!-- Advanced Filters & Search -->
        <div class="advanced-controls">
            <div class="search-advanced">
                <i class="fas fa-search"></i>
                <input type="text" id="searchInput" placeholder="Search by name, phone, email, or ID..." onkeyup="advancedSearch()">
                <button class="clear-search" onclick="clearSearch()" style="display: none;">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <div class="filter-chips">
                <button class="chip active" data-filter="all" onclick="quickFilter('all', this)">
                    <i class="fas fa-users"></i> All Users
                </button>
                <button class="chip" data-filter="approved" onclick="quickFilter('approved', this)">
                    <i class="fas fa-check-circle"></i> Approved
                </button>
                <button class="chip" data-filter="pending" onclick="quickFilter('pending', this)">
                    <i class="fas fa-clock"></i> Pending
                </button>
                <button class="chip" data-filter="recent" onclick="quickFilter('recent', this)">
                    <i class="fas fa-star"></i> Recent
                </button>
            </div>

            <div class="view-controls">
                <button class="view-btn active" data-view="grid" onclick="switchView('grid', this)">
                    <i class="fas fa-th-large"></i>
                </button>
                <button class="view-btn" data-view="list" onclick="switchView('list', this)">
                    <i class="fas fa-list"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- Users Grid View -->
    <div class="users-grid-view" id="gridView">
        @foreach($users as $user)
        <div class="user-card" data-status="{{ $user->is_approved ? 'approved' : 'pending' }}" data-recent="{{ $user->created_at->isAfter(now()->subDays(7)) ? 'true' : 'false' }}" data-user-id="{{ $user->id }}">
            <div class="user-card-header">
                <div class="user-avatar-advanced">
                    @if($user->profile_image_url)
                        <img src="{{ $user->profile_image_url }}" alt="{{ $user->first_name }}">
                    @else
                        <div class="avatar-placeholder">{{ substr($user->first_name, 0, 1) }}{{ substr($user->last_name, 0, 1) }}</div>
                    @endif
                    <div class="status-indicator {{ $user->is_approved ? 'approved' : 'pending' }}"></div>
                </div>
                <div class="user-badge">
                    @if($user->is_approved)
                        <span class="badge-advanced success">
                            <i class="fas fa-check"></i> Approved
                        </span>
                    @else
                        <span class="badge-advanced warning">
                            <i class="fas fa-clock"></i> Pending
                        </span>
                    @endif
                </div>
            </div>

            <div class="user-card-body">
                <h3 class="user-name">{{ $user->first_name }} {{ $user->last_name }}</h3>
                <p class="user-id">ID: {{ $user->id }}</p>

                <div class="user-info-grid">
                    <div class="info-item">
                        <i class="fas fa-phone"></i>
                        <span>{{ $user->phone }}</span>
                    </div>
                    <div class="info-item">
                        <i class="fas fa-calendar"></i>
                        <span>{{ $user->created_at->diffForHumans() }}</span>
                    </div>
                </div>

                @if($user->wallet)
                <div class="wallet-info">
                    <i class="fas fa-wallet"></i>
                    <span>${{ number_format($user->wallet->balance_usd, 2) }}</span>
                </div>
                @endif
            </div>

            <div class="user-card-actions">
                @if(!$user->is_approved)
                <form method="POST" action="{{ route('admin.users.approve', $user->id) }}" style="display: inline;" id="approveForm{{ $user->id }}">
                    @csrf
                    <button type="button" class="action-btn-card approve" onclick="quickApprove({{ $user->id }}, '{{ $user->first_name }} {{ $user->last_name }}')">
                        <i class="fas fa-check"></i> Approve
                    </button>
                </form>
                @endif

                <button class="action-btn-card view" onclick="viewUserDetails({{ $user->id }})">
                    <i class="fas fa-eye"></i> View
                </button>

                <form method="POST" action="{{ route('admin.users.reject', $user->id) }}" style="display: inline;" id="deleteForm{{ $user->id }}">
                    @csrf
                    @method('DELETE')
                    <button type="button" class="action-btn-card delete" onclick="quickDelete({{ $user->id }}, '{{ $user->first_name }} {{ $user->last_name }}', '{{ $user->is_approved ? 'delete' : 'reject' }}')">
                        <i class="fas fa-trash"></i>
                    </button>
                </form>
            </div>
        </div>
        @endforeach
    </div>

    <!-- Users List View (Hidden by default) -->
    <div class="users-list-view" id="listView" style="display: none;">
        <div class="list-table">
            <table>
                <thead>
                    <tr>
                        <th>User</th>
                        <th>Contact</th>
                        <th>Wallet</th>
                        <th>Status</th>
                        <th>Registered</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($users as $user)
                    <tr data-status="{{ $user->is_approved ? 'approved' : 'pending' }}" data-recent="{{ $user->created_at->isAfter(now()->subDays(7)) ? 'true' : 'false' }}">
                        <td>
                            <div class="user-cell">
                                <div class="user-avatar-small">
                                    @if($user->profile_image_url)
                                        <img src="{{ $user->profile_image_url }}" alt="{{ $user->first_name }}" style="width: 100%; height: 100%; border-radius: 10px; object-fit: cover;">
                                    @else
                                        {{ substr($user->first_name, 0, 1) }}{{ substr($user->last_name, 0, 1) }}
                                    @endif
                                </div>
                                <div>
                                    <div class="user-name-small">{{ $user->first_name }} {{ $user->last_name }}</div>
                                    <div class="user-id-small">ID: {{ $user->id }}</div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="contact-cell">
                                <i class="fas fa-phone"></i> {{ $user->phone }}
                            </div>
                        </td>
                        <td>
                            @if($user->wallet)
                                <div class="wallet-cell">
                                    <i class="fas fa-wallet"></i> ${{ number_format($user->wallet->balance_usd, 2) }}
                                </div>
                            @else
                                <span class="text-muted">-</span>
                            @endif
                        </td>
                        <td>
                            @if($user->is_approved)
                                <span class="badge-advanced success">
                                    <i class="fas fa-check"></i> Approved
                                </span>
                            @else
                                <span class="badge-advanced warning">
                                    <i class="fas fa-clock"></i> Pending
                                </span>
                            @endif
                        </td>
                        <td>
                            <div class="date-cell">
                                <div>{{ $user->created_at->format('M d, Y') }}</div>
                                <div class="date-relative">{{ $user->created_at->diffForHumans() }}</div>
                            </div>
                        </td>
                        <td>
                            <div class="actions-cell">
                                @if(!$user->is_approved)
                                <button class="action-btn-table approve" onclick="quickApprove({{ $user->id }}, '{{ $user->first_name }} {{ $user->last_name }}')">
                                    <i class="fas fa-check"></i>
                                </button>
                                @endif
                                <button class="action-btn-table view" onclick="viewUserDetails({{ $user->id }})">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="action-btn-table delete" onclick="quickDelete({{ $user->id }}, '{{ $user->first_name }} {{ $user->last_name }}', '{{ $user->is_approved ? 'delete' : 'reject' }}')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <!-- Pagination -->
    @if($users->hasPages())
    <div class="pagination-advanced">
        {{ $users->links() }}
    </div>
    @endif

    <!-- User Detail Modal -->
    <div id="userDetailModal" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(14, 19, 48, 0.9); z-index: 9999; align-items: center; justify-content: center; animation: fadeIn 0.3s ease;">
        <div style="background: white; border-radius: 20px; max-width: 600px; width: 90%; max-height: 90vh; overflow-y: auto; position: relative; animation: slideUp 0.4s ease;">
            <div style="position: sticky; top: 0; background: linear-gradient(135deg, #0e1330, #17173a); color: white; padding: 24px; border-radius: 20px 20px 0 0; display: flex; justify-content: space-between; align-items: center; z-index: 10;">
                <h2 style="margin: 0; font-size: 1.5rem;"><i class="fas fa-user-circle"></i> User Details</h2>
                <button onclick="closeUserModal()" style="background: rgba(255,255,255,0.2); border: none; color: white; width: 36px; height: 36px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.3s ease;" onmouseover="this.style.background='rgba(255,255,255,0.3)'" onmouseout="this.style.background='rgba(255,255,255,0.2)'">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div id="userDetailContent" style="padding: 24px;">
                <div style="text-align: center; padding: 40px; color: #5A6C7D;">
                    <div class="spinner" style="width: 40px; height: 40px; border: 4px solid #E5E7EB; border-top-color: #ff6f2d; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 20px;"></div>
                    <p>Loading user details...</p>
                </div>
            </div>
        </div>
    </div>

    <style>
        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>

    <script src="{{ asset('js/users-advanced.js') }}"></script>
@endsection
