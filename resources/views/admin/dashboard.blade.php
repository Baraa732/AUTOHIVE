@extends('admin.layout')

@section('title', 'Dashboard')
@section('icon', 'fas fa-chart-line')

@section('content')
    <link rel="stylesheet" href="{{ asset('css/dashboard.css') }}">

    <!-- Welcome Section -->
    <div class="welcome-section">
        <!-- Geometric background elements -->
        <div class="welcome-bg-1"></div>
        <div class="welcome-bg-2"></div>
        <div class="welcome-orb"></div>
        <div class="welcome-square"></div>
        <div class="welcome-dots">
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
        </div>
        <div class="welcome-content">
            <h2 class="welcome-title">Welcome back, {{ auth()->user()->first_name }}!</h2>
            <p class="welcome-subtitle">Here's what's happening with AUTOHIVE today.</p>
        </div>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid fade-in-up-03">
        <div class="stat-card slide-in-up"
            onmouseover="this.style.transform='translateY(-8px)'; this.style.boxShadow='0 12px 24px rgba(0, 0, 0, 0.1)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
            </div>
            <div class="stat-number">{{ $stats['total_users'] }}</div>
            <div class="stat-label">Total Users</div>
            <div class="stat-trend trend-up">
                <i class="fas fa-arrow-up"></i>+12% from last month
            </div>
        </div>

        <div class="stat-card slide-in-up-01"
            onmouseover="this.style.transform='translateY(-8px)'; this.style.boxShadow='0 12px 24px rgba(0, 0, 0, 0.1)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-clock"></i>
                </div>
            </div>
            <div class="stat-number">{{ $stats['pending_approvals'] }}</div>
            <div class="stat-label">Pending Approvals</div>
            <div class="stat-trend trend-danger">
                <i class="fas fa-exclamation-triangle pulse-animation"></i>Requires attention
            </div>
        </div>

        <div class="stat-card slide-in-up-02"
            onmouseover="this.style.transform='translateY(-8px)'; this.style.boxShadow='0 12px 24px rgba(0, 0, 0, 0.1)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-building"></i>
                </div>
            </div>
            <div class="stat-number">{{ $stats['total_apartments'] }}</div>
            <div class="stat-label">Total Apartments</div>
            <div class="stat-trend trend-secondary">
                <i class="fas fa-arrow-up"></i>+5 this week
            </div>
        </div>

        <div class="stat-card slide-in-up-03"
            onmouseover="this.style.transform='translateY(-8px)'; this.style.boxShadow='0 12px 24px rgba(0, 0, 0, 0.1)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-calendar-check"></i>
                </div>
            </div>
            <div class="stat-number">{{ $stats['total_bookings'] }}</div>
            <div class="stat-label">Total Bookings</div>
            <div class="stat-trend trend-purple">
                <i class="fas fa-arrow-up"></i>+8% from last week
            </div>
        </div>

        <div class="stat-card slide-in-up-04"
            onmouseover="this.style.transform='translateY(-8px)'; this.style.boxShadow='0 12px 24px rgba(0, 0, 0, 0.1)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-hourglass-half"></i>
                </div>
            </div>
            <div class="stat-number">{{ $stats['pending_bookings'] }}</div>
            <div class="stat-label">Pending Bookings</div>
            <div class="stat-trend trend-warning">
                <i class="fas fa-clock pulse-animation"></i>Review needed
            </div>
        </div>

        <div class="stat-card slide-in-up-05"
            onmouseover="this.style.transform='translateY(-8px)'; this.style.boxShadow='0 12px 24px rgba(0, 0, 0, 0.1)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-dollar-sign"></i>
                </div>
            </div>
            <div class="stat-number">${{ number_format($stats['total_revenue'], 2) }}</div>
            <div class="stat-label">Total Revenue</div>
            <div class="stat-trend trend-dark">
                <i class="fas fa-arrow-up"></i>+15% from last month
            </div>
        </div>
    </div>

    <!-- Main Content Grid -->
    <div class="main-content-grid fade-in-up-06">
        <!-- Recent Activities -->
        <div class="content-card hover-lift"
            onmouseover="this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 20px rgba(0, 0, 0, 0.1)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fas fa-history"></i>
                    Recent Activities
                </h3>
                <a href="#" class="view-all-link">View All</a>
            </div>
            <div class="card-body">
                @forelse($recentActivities as $activity)
                    <div class="activity-item">
                        <div class="activity-icon">
                            <i
                                class="fas fa-{{ $activity->action === 'login' ? 'sign-in-alt' : ($activity->action === 'user_approved' ? 'check' : ($activity->action === 'user_rejected' ? 'times' : 'trash')) }}"></i>
                        </div>
                        <div class="activity-content">
                            <div class="activity-title">{{ $activity->description }}</div>
                            <div class="activity-time">
                                by
                                {{ $activity->admin ? $activity->admin->first_name . ' ' . $activity->admin->last_name : 'System' }}
                                • {{ $activity->created_at->diffForHumans() }}
                            </div>
                        </div>
                    </div>
                @empty
                    <div class="empty-state">
                        <i class="fas fa-history"></i>
                        <p>No recent activities</p>
                    </div>
                @endforelse
            </div>
        </div>

        <!-- Quick Stats -->
        <div class="content-card hover-lift"
            onmouseover="this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 20px rgba(0, 0, 0, 0.1)'"
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
            <div class="card-header">
                <h3 class="card-title">
                    <i class="fas fa-tachometer-alt"></i>
                    Quick Stats
                </h3>
            </div>
            <div class="card-body">
                <div class="stats-section">
                    <div class="stat-row">
                        <span class="stat-label-text">Admin Team</span>
                        <span class="stat-value">{{ $adminStats['total_admins'] }}</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label-text">Active Today</span>
                        <span class="stat-value accent">{{ $adminStats['active_today'] }}</span>
                    </div>
                </div>

                <div class="status-card">
                    <div class="status-label">System Status</div>
                    <div class="status-indicator">
                        <div class="status-dot"></div>
                        <span class="status-text">All Systems Operational</span>
                    </div>
                </div>

                <div class="action-grid">
                    <a href="{{ route('admin.users') }}" class="action-btn gradient-dark-btn">
                        <div class="action-bg-1"></div>
                        <div class="action-orb"></div>
                        <div class="action-square"></div>
                        <i class="fas fa-users"></i>
                        <span>Manage Users</span>
                    </a>
                    <a href="{{ route('admin.apartments') }}" class="action-btn gradient-orange-btn">
                        <i class="fas fa-building"></i>
                        <span>View Properties</span>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Bookings Section -->
    <div class="content-card hover-lift fade-in-up-08"
        onmouseover="this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 20px rgba(0, 0, 0, 0.1)'"
        onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(0, 0, 0, 0.05)'">
        <div class="card-header">
            <h3 class="card-title">
                <i class="fas fa-calendar-alt"></i>
                Recent Bookings
            </h3>
            <a href="{{ route('admin.bookings') }}" class="view-all-link">View All Bookings</a>
        </div>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Guest</th>
                        <th>Property</th>
                        <th>Check-in</th>
                        <th>Status</th>
                        <th>Amount</th>
                    </tr>
                </thead>
                <tbody>
                    @php
                        // Better approach: This should come from controller, but keeping fallback for now
                        $recentBookings = $recentBookings ?? \App\Models\Booking::with(['user', 'apartment'])->latest()->take(5)->get();
                    @endphp

                    @forelse($recentBookings as $booking)
                        <tr>
                            <td>
                                <div class="guest-info">
                                    <div class="guest-avatar">
                                        {{ substr($booking->user->first_name ?? 'U', 0, 1) }}{{ substr($booking->user->last_name ?? 'N', 0, 1) }}
                                    </div>
                                    <div>
                                        <div class="guest-name">{{ $booking->user->first_name ?? 'Unknown' }}
                                            {{ $booking->user->last_name ?? 'User' }}</div>
                                        <div class="guest-phone">{{ $booking->user->phone ?? 'N/A' }}</div>
                                    </div>
                                </div>
                            </td>
                            <td class="property-info">
                                <div class="property-name">{{ $booking->apartment->name ?? 'N/A' }}</div>
                                <div class="property-location">{{ $booking->apartment->location ?? '' }}</div>
                            </td>
                            <td class="checkin-date">{{ $booking->check_in ? $booking->check_in->format('Y-m-d') : 'N/A' }}</td>
                            <td>
                                @php
                                    $statusColors = [
                                        'pending' => '#F59E0B',
                                        'confirmed' => '#10B981',
                                        'cancelled' => '#EF4444',
                                        'completed' => '#003F3F'
                                    ];
                                    $status = $booking->status ?? 'pending';
                                @endphp
                                <span class="status-badge"
                                    style="background: {{ $statusColors[$status] ?? '#6B7280' }}20; color: {{ $statusColors[$status] ?? '#6B7280' }};">
                                    {{ ucfirst($status) }}
                                </span>
                            </td>
                            <td class="booking-amount">${{ number_format($booking->total_price ?? 0, 2) }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5">
                                <div class="empty-state">
                                    <i class="fas fa-calendar-times"></i>
                                    No recent bookings
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection
