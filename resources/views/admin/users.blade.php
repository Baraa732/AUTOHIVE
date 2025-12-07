@extends('admin.layout')

@section('title', 'Users Management')
@section('icon', 'fas fa-users')

@section('content')
    <style>
        /* CSS Variables */
        :root {
            --deep-green: #0e7c7b;
            --yellow-accent: #ffd166;
            --white: #ffffff;
            --off-white: #f8f9fa;
            --light-grey: #f1f3f4;
            --border-grey: #e0e0e0;
            --text-dark: #333333;
            --text-grey: #666666;
            --space-xs: 0.25rem;
            --space-sm: 0.5rem;
            --space-md: 1rem;
            --space-lg: 1.5rem;
            --space-xl: 2rem;
            --space-2xl: 3rem;
            --radius-md: 0.375rem;
            --radius-lg: 0.5rem;
            --radius-xl: 0.75rem;
            --transition: all 0.3s ease;
            --shadow-soft: 0 4px 6px rgba(0, 0, 0, 0.05);
            --shadow-lg: 0 10px 25px rgba(0, 0, 0, 0.1);
        }

        /* Main Container */
        .users-container {
            animation: fadeInUp 0.6s ease;
        }

        /* Stats Row */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--space-lg);
            margin-bottom: var(--space-2xl);
        }

        .stat-box {
            background: linear-gradient(135deg, var(--white) 0%, var(--off-white) 100%);
            padding: var(--space-lg);
            border-radius: var(--radius-xl);
            border: 1px solid var(--border-grey);
            position: relative;
            overflow: hidden;
            transition: var(--transition);
            animation: slideInUp 0.5s ease forwards;
            opacity: 0;
        }

        .stat-box:nth-child(1) {
            animation-delay: 0.1s;
        }

        .stat-box:nth-child(2) {
            animation-delay: 0.2s;
        }

        .stat-box:nth-child(3) {
            animation-delay: 0.3s;
        }

        .stat-box:nth-child(4) {
            animation-delay: 0.4s;
        }

        .stat-box::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(0, 63, 63, 0.05), transparent);
            transition: left 0.8s ease;
        }

        .stat-box:hover::before {
            left: 100%;
        }

        .stat-box:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
        }

        /* Stat Icons - FIXED */
        .stat-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--deep-green), var(--yellow-accent));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 1.2rem;
            margin-bottom: var(--space-md);
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: var(--space-xs);
        }

        .stat-label {
            color: var(--text-grey);
            font-size: 0.9rem;
            font-weight: 500;
        }

        /* Users Table */
        .users-table {
            background: var(--white);
            border-radius: var(--radius-xl);
            overflow: hidden;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--border-grey);
        }

        .table-header {
            background: linear-gradient(135deg, var(--light-grey) 0%, var(--off-white) 100%);
            padding: var(--space-lg);
            border-bottom: 1px solid var(--border-grey);
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table th {
            padding: var(--space-md) var(--space-lg);
            text-align: left;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.85rem;
            background: var(--light-grey);
            border-bottom: 2px solid var(--border-grey);
        }

        .table td {
            padding: var(--space-md) var(--space-lg);
            border-bottom: 1px solid var(--border-grey);
            font-size: 0.9rem;
            transition: var(--transition);
        }

        .table tr {
            transition: var(--transition);
        }

        .table tr:hover {
            background: var(--off-white);
        }

        /* User Avatar - FIXED */
        .user-avatar {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #0e7c7b, #ffd166);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 0.85rem;
        }

        /* Badges */
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

        .badge-warning {
            background: #F59E0B20;
            color: #F59E0B;
        }

        /* Buttons */
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 0.8rem;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: var(--space-xs);
            margin-right: var(--space-xs);
        }

        .btn-success {
            background: #10B981;
            color: var(--white);
        }

        .btn-success:hover {
            background: #059669;
            transform: translateY(-2px);
        }

        .btn-danger {
            background: #EF4444;
            color: var(--white);
        }

        .btn-danger:hover {
            background: #DC2626;
            transform: translateY(-2px);
        }

        /* Filter Bar */
        .filter-bar {
            display: flex;
            gap: var(--space-md);
            margin-bottom: var(--space-lg);
            padding: var(--space-lg);
            background: var(--white);
            border-radius: var(--radius-xl);
            border: 1px solid var(--border-grey);
            align-items: center;
            flex-wrap: wrap;
        }

        .search-wrapper {
            position: relative;
            flex: 1;
            min-width: 300px;
            margin-right: var(--space-md);
        }

        .search-container {
            position: relative;
            background: #f8f9fa;
            border-radius: 10px;
            padding: 2px;
            overflow: hidden;
            border: 1px solid var(--border-grey);
        }

        .search-input {
            width: 100%;
            padding: 12px 20px 12px 50px;
            border: none;
            border-radius: 8px;
            font-size: 0.9rem;
            background: white;
            color: var(--text-dark);
        }

        .search-input:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(14, 124, 123, 0.2);
        }

        .search-icon {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--deep-green);
            font-size: 1rem;
            pointer-events: none;
            z-index: 2;
        }

        .filter-btn {
            padding: 10px 20px;
            border: 2px solid var(--border-grey);
            background: var(--white);
            color: var(--text-grey);
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
        }

        .filter-btn:hover {
            border-color: var(--deep-green);
            color: var(--deep-green);
        }

        .filter-btn.active {
            background: var(--deep-green);
            border-color: var(--deep-green);
            color: var(--white);
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes fadeInLeft {
            from {
                opacity: 0;
                transform: translateX(-10px);
            }

            to {
                opacity: 1;
                transform: translateX(0);
            }
        }
    </style>

    <!-- Add Font Awesome CDN if not already in layout -->
    @unless(isset($fontAwesomeLoaded))
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        @php $fontAwesomeLoaded = true @endphp
    @endunless

    <div class="users-container">
        <!-- Stats Row -->
        <div class="stats-row">
            <div class="stat-box">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-number">{{ $users->total() }}</div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-box">
                <div class="stat-icon">
                    <i class="fas fa-user-check"></i>
                </div>
                <div class="stat-number">{{ $users->where('is_approved', true)->count() }}</div>
                <div class="stat-label">Approved</div>
            </div>
            <div class="stat-box">
                <div class="stat-icon">
                    <i class="fas fa-user-clock"></i>
                </div>
                <div class="stat-number">{{ $users->where('is_approved', false)->count() }}</div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-box">
                <div class="stat-icon">
                    <i class="fas fa-calendar-plus"></i>
                </div>
                <div class="stat-number">{{ $users->where('created_at', '>=', now()->subDays(7))->count() }}</div>
                <div class="stat-label">This Week</div>
            </div>
        </div>

        <!-- Filter Bar -->
        <div class="filter-bar">
            <div class="search-wrapper">
                <div class="search-container">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" class="search-input" placeholder="Search users by name, phone, or ID..."
                        onkeyup="searchUsers(this.value)">
                </div>
            </div>
            <button class="filter-btn active" onclick="filterUsers('all', this)">All Users</button>
            <button class="filter-btn" onclick="filterUsers('approved', this)">Approved</button>
            <button class="filter-btn" onclick="filterUsers('pending', this)">Pending</button>
            <button class="filter-btn" onclick="filterUsers('recent', this)">Recent</button>
        </div>

        <!-- Users Table -->
        <div class="users-table">
            <div class="table-header">
                <h3 class="card-title">
                    <i class="fas fa-table"></i>
                    User Management ({{ $users->total() }})
                </h3>
            </div>

            @if($users->count() > 0)
                <table class="table">
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Contact</th>
                            <th>Status</th>
                            <th>Registered</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($users as $user)
                            <tr data-status="{{ $user->is_approved ? 'approved' : 'pending' }}"
                                data-recent="{{ $user->created_at->isAfter(now()->subDays(7)) ? 'true' : 'false' }}"
                                class="fade-in-row">
                                <td>
                                    <div style="display: flex; align-items: center; gap: var(--space-md);">
                                        <div class="user-avatar">
                                            {{ substr($user->first_name, 0, 1) }}{{ substr($user->last_name, 0, 1) }}
                                        </div>
                                        <div>
                                            <div style="font-weight: 600; color: var(--text-dark);">
                                                {{ $user->first_name }} {{ $user->last_name }}
                                            </div>
                                            <div style="font-size: 0.8rem; color: var(--text-grey);">
                                                ID: {{ $user->id }}
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div style="color: var(--text-dark); font-weight: 500;">{{ $user->phone }}</div>
                                    <div style="font-size: 0.8rem; color: var(--text-grey);">Phone Number</div>
                                </td>
                                <td>
                                    @if($user->is_approved)
                                        <span class="badge badge-success">
                                            <i class="fas fa-check"></i> Approved
                                        </span>
                                    @else
                                        <span class="badge badge-warning">
                                            <i class="fas fa-clock"></i> Pending
                                        </span>
                                    @endif
                                </td>
                                <td>
                                    <div style="color: var(--text-dark);">{{ $user->created_at->format('M d, Y') }}</div>
                                    <div style="font-size: 0.8rem; color: var(--text-grey);">
                                        {{ $user->created_at->diffForHumans() }}
                                    </div>
                                </td>
                                <td>
                                    @if(!$user->is_approved)
                                        <form method="POST" action="{{ route('admin.users.approve', $user->id) }}"
                                            style="display: inline;" id="approveForm{{ $user->id }}">
                                            @csrf
                                            <button type="button" class="btn btn-success"
                                                onclick="confirmAction('approveForm{{ $user->id }}', 'Approve User', 'Are you sure you want to approve {{ $user->first_name }} {{ $user->last_name }}?')">
                                                <i class="fas fa-check"></i> Approve
                                            </button>
                                        </form>
                                    @endif

                                    <form method="POST" action="{{ route('admin.users.reject', $user->id) }}"
                                        style="display: inline;" id="deleteForm{{ $user->id }}">
                                        @csrf
                                        @method('DELETE')
                                        <button type="button" class="btn btn-danger"
                                            onclick="confirmDelete('deleteForm{{ $user->id }}', '{{ $user->first_name }} {{ $user->last_name }}', '{{ $user->is_approved ? 'delete' : 'reject' }}')">
                                            <i class="fas fa-trash"></i>
                                            {{ $user->is_approved ? 'Delete' : 'Reject' }}
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>

                @if($users->hasPages())
                    <div style="padding: var(--space-lg); border-top: 1px solid var(--border-grey);">
                        {{ $users->links('vendor.pagination.default') }}
                    </div>
                @endif
            @else
                <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
                    <i class="fas fa-users" style="font-size: 3rem; margin-bottom: var(--space-lg); opacity: 0.3;"></i>
                    <h3 style="margin-bottom: var(--space-sm);">No Users Found</h3>
                    <p>No users have registered yet.</p>
                </div>
            @endif
        </div>
    </div>

    <script>
        // Confirm action modal
        function showConfirmModal(title, message, callback) {
            if (confirm(message)) {
                callback();
            }
        }

        // Confirm action for approving users
        function confirmAction(formId, title, message) {
            const form = document.getElementById(formId);
            showConfirmModal(title, message, function () {
                form.submit();
            });
        }

        // Confirm delete/reject action
        function confirmDelete(formId, userName, actionType) {
            const actionText = actionType === 'delete' ? 'delete' : 'reject';
            const message = `Are you sure you want to ${actionText} ${userName}? This action cannot be undone.`;
            const form = document.getElementById(formId);

            showConfirmModal(`Confirm ${actionType.charAt(0).toUpperCase() + actionType.slice(1)}`, message, function () {
                form.submit();
            });
        }

        // Filter users
        function filterUsers(type, button) {
            const rows = document.querySelectorAll('tbody tr');
            const buttons = document.querySelectorAll('.filter-btn');

            // Update active button
            buttons.forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');

            // Filter rows
            rows.forEach(row => {
                let show = false;

                switch (type) {
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

                if (show) {
                    row.style.display = 'table-row';
                    row.style.animation = 'fadeInLeft 0.3s ease';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        // Search users
        function searchUsers(query) {
            const rows = document.querySelectorAll('tbody tr');
            const searchTerm = query.toLowerCase().trim();

            rows.forEach(row => {
                const userName = row.querySelector('td:first-child').textContent.toLowerCase();
                const userPhone = row.querySelector('td:nth-child(2)').textContent.toLowerCase();
                const userId = row.querySelector('td:first-child div:nth-child(2)').textContent.toLowerCase();

                const matches = userName.includes(searchTerm) ||
                    userPhone.includes(searchTerm) ||
                    userId.includes(searchTerm);

                if (matches || searchTerm === '') {
                    row.style.display = 'table-row';
                    row.style.animation = 'fadeInLeft 0.3s ease';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        // Initialize row animations
        document.addEventListener('DOMContentLoaded', function () {
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach((row, index) => {
                row.style.animationDelay = (index * 0.1) + 's';
                row.style.animation = 'fadeInLeft 0.5s ease forwards';
            });
        });
    </script>
@endsection
