@extends('admin.layout')

@section('title', 'Dashboard')
@section('icon', 'fas fa-chart-line')

@section('content')
    <link rel="stylesheet" href="{{ asset('css/dashboard.css') }}">
    <link rel="stylesheet" href="{{ asset('css/dashboard-advanced.css') }}">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0/dist/chartjs-plugin-datalabels.min.js"></script>

    <!-- Advanced Analytics Dashboard -->
    <div class="analytics-header fade-in-up-02">
        <div class="header-left">
            <h1 class="dashboard-title">Analytics Overview</h1>
            <p class="dashboard-subtitle">Real-time business intelligence • Last updated: <span id="lastUpdate">just now</span></p>
        </div>
        <div class="header-actions">
            <button class="action-btn-small" onclick="refreshDashboard()">
                <i class="fas fa-sync-alt"></i> Refresh
            </button>
            <button class="action-btn-small primary">
                <i class="fas fa-download"></i> Export Report
            </button>
        </div>
    </div>

    <!-- KPI Cards with Progress -->
    <div class="kpi-grid fade-in-up-03">
        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper users">
                    <i class="fas fa-users"></i>
                </div>
                <div class="kpi-trend up">
                    <i class="fas fa-arrow-up"></i> 12.5%
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $stats['total_users'] }}</div>
                <div class="kpi-label">Total Users</div>
                <div class="kpi-progress">
                    <div class="progress-bar" style="width: 75%"></div>
                </div>
                <div class="kpi-meta">Target: 1000 users</div>
            </div>
        </div>

        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper properties">
                    <i class="fas fa-building"></i>
                </div>
                <div class="kpi-trend up">
                    <i class="fas fa-arrow-up"></i> 8.3%
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $stats['total_apartments'] }}</div>
                <div class="kpi-label">Properties Listed</div>
                <div class="kpi-progress">
                    <div class="progress-bar" style="width: 60%"></div>
                </div>
                <div class="kpi-meta">+5 this week</div>
            </div>
        </div>

        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper bookings">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <div class="kpi-trend up">
                    <i class="fas fa-arrow-up"></i> 15.2%
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $stats['total_bookings'] }}</div>
                <div class="kpi-label">Total Bookings</div>
                <div class="kpi-progress">
                    <div class="progress-bar" style="width: 85%"></div>
                </div>
                <div class="kpi-meta">{{ $stats['pending_bookings'] }} pending review</div>
            </div>
        </div>

        <div class="kpi-card highlight">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper revenue">
                    <i class="fas fa-dollar-sign"></i>
                </div>
                <div class="kpi-trend up">
                    <i class="fas fa-arrow-up"></i> 23.1%
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">${{ number_format($stats['total_revenue'], 0) }}</div>
                <div class="kpi-label">Total Revenue</div>
                <div class="kpi-progress">
                    <div class="progress-bar" style="width: 92%"></div>
                </div>
                <div class="kpi-meta">Monthly target: $50,000</div>
            </div>
        </div>
    </div>

    <!-- Advanced Charts Section -->
    <div class="advanced-charts-grid fade-in-up-04">
        <!-- Main Revenue Chart -->
        <div class="chart-card-advanced primary-chart">
            <div class="chart-header-advanced">
                <div>
                    <h3 class="chart-title-advanced">
                        <i class="fas fa-chart-area"></i>
                        Revenue Analytics
                    </h3>
                    <p class="chart-subtitle">Performance over time with predictive trends</p>
                </div>
                <div class="chart-controls">
                    <div class="time-selector">
                        <button class="time-btn" onclick="updateChart('7d')">7D</button>
                        <button class="time-btn active" onclick="updateChart('1m')">1M</button>
                        <button class="time-btn" onclick="updateChart('3m')">3M</button>
                        <button class="time-btn" onclick="updateChart('1y')">1Y</button>
                    </div>
                </div>
            </div>
            <div class="chart-body-advanced">
                <canvas id="revenueChart"></canvas>
            </div>
            <div class="chart-footer">
                <div class="chart-stat">
                    <span class="stat-label">Avg. Daily</span>
                    <span class="stat-value">$1,847</span>
                </div>
                <div class="chart-stat">
                    <span class="stat-label">Peak Day</span>
                    <span class="stat-value">$2,400</span>
                </div>
                <div class="chart-stat">
                    <span class="stat-label">Growth Rate</span>
                    <span class="stat-value">+23.1%</span>
                </div>
            </div>
        </div>

        <!-- Bookings Distribution -->
        <div class="chart-card-advanced">
            <div class="chart-header-advanced">
                <h3 class="chart-title-advanced">
                    <i class="fas fa-chart-pie"></i>
                    Bookings Distribution
                </h3>
            </div>
            <div class="chart-body-advanced compact">
                <canvas id="bookingsChart"></canvas>
            </div>
            <div class="distribution-legend">
                <div class="legend-item">
                    <span class="legend-dot confirmed"></span>
                    <span class="legend-label">Confirmed</span>
                    <span class="legend-value">{{ $stats['total_bookings'] - $stats['pending_bookings'] }}</span>
                </div>
                <div class="legend-item">
                    <span class="legend-dot pending"></span>
                    <span class="legend-label">Pending</span>
                    <span class="legend-value">{{ $stats['pending_bookings'] }}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Secondary Analytics -->
    <div class="secondary-analytics fade-in-up-05">
        <!-- User Growth Trend -->
        <div class="chart-card-advanced">
            <div class="chart-header-advanced">
                <h3 class="chart-title-advanced">
                    <i class="fas fa-users"></i>
                    User Acquisition
                </h3>
            </div>
            <div class="chart-body-advanced">
                <canvas id="userGrowthChart"></canvas>
            </div>
        </div>

        <!-- Activity Feed -->
        <div class="activity-feed-card">
            <div class="feed-header">
                <h3 class="feed-title">
                    <i class="fas fa-bolt"></i>
                    Live Activity
                </h3>
                <span class="live-indicator">
                    <span class="pulse-dot"></span> Live
                </span>
            </div>
            <div class="feed-body">
                @forelse($recentActivities->take(6) as $activity)
                    <div class="feed-item">
                        <div class="feed-icon">
                            <i class="fas fa-{{ $activity->action === 'login' ? 'sign-in-alt' : ($activity->action === 'user_approved' ? 'check' : 'times') }}"></i>
                        </div>
                        <div class="feed-content">
                            <div class="feed-text">{{ $activity->description }}</div>
                            <div class="feed-time">{{ $activity->created_at->diffForHumans() }}</div>
                        </div>
                    </div>
                @empty
                    <div class="feed-empty">
                        <i class="fas fa-inbox"></i>
                        <p>No recent activity</p>
                    </div>
                @endforelse
            </div>
        </div>
    </div>

    <!-- Action Required Section -->
    @if($stats['pending_approvals'] > 0 || $stats['pending_bookings'] > 0)
    <div class="action-required-section fade-in-up-06">
        <div class="section-header">
            <h3><i class="fas fa-exclamation-circle"></i> Action Required</h3>
            <span class="badge-count">{{ $stats['pending_approvals'] + $stats['pending_bookings'] }}</span>
        </div>
        <div class="action-cards">
            @if($stats['pending_approvals'] > 0)
            <div class="action-card urgent">
                <div class="action-card-icon">
                    <i class="fas fa-user-clock"></i>
                </div>
                <div class="action-card-content">
                    <div class="action-card-title">{{ $stats['pending_approvals'] }} User Approvals Pending</div>
                    <div class="action-card-desc">New user registrations awaiting review</div>
                    <div class="action-card-meta">
                        <span><i class="fas fa-clock"></i> Avg. wait: 2.5 hours</span>
                    </div>
                </div>
                <a href="{{ route('admin.users') }}" class="action-card-btn">
                    Review <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            @endif

            @if($stats['pending_bookings'] > 0)
            <div class="action-card important">
                <div class="action-card-icon">
                    <i class="fas fa-calendar-alt"></i>
                </div>
                <div class="action-card-content">
                    <div class="action-card-title">{{ $stats['pending_bookings'] }} Booking Requests</div>
                    <div class="action-card-desc">Pending booking confirmations</div>
                    <div class="action-card-meta">
                        <span><i class="fas fa-clock"></i> Avg. wait: 1.2 hours</span>
                    </div>
                </div>
                <a href="{{ route('admin.bookings') }}" class="action-card-btn">
                    Review <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            @endif
        </div>
    </div>
    @endif

    <script>
        // Advanced Chart Configuration
        Chart.defaults.font.family = "'Inter', sans-serif";
        Chart.defaults.color = '#5A6C7D';

        // Revenue Chart with Gradient
        const revenueCtx = document.getElementById('revenueChart').getContext('2d');
        const gradient = revenueCtx.createLinearGradient(0, 0, 0, 400);
        gradient.addColorStop(0, 'rgba(255, 111, 45, 0.3)');
        gradient.addColorStop(1, 'rgba(255, 111, 45, 0.01)');

        new Chart(revenueCtx, {
            type: 'line',
            data: {
                labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                datasets: [{
                    label: 'Revenue',
                    data: [8500, 12000, 10500, 15200],
                    borderColor: '#ff6f2d',
                    backgroundColor: gradient,
                    tension: 0.4,
                    fill: true,
                    pointBackgroundColor: '#ff6f2d',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 3,
                    pointRadius: 6,
                    pointHoverRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    intersect: false,
                    mode: 'index'
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#0e1330',
                        padding: 12,
                        titleColor: '#fff',
                        bodyColor: '#fff',
                        borderColor: '#ff6f2d',
                        borderWidth: 1,
                        displayColors: false,
                        callbacks: {
                            label: function(context) {
                                return '$' + context.parsed.y.toLocaleString();
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0, 0, 0, 0.05)', drawBorder: false },
                        ticks: {
                            callback: function(value) {
                                return '$' + (value / 1000) + 'k';
                            }
                        }
                    },
                    x: {
                        grid: { display: false, drawBorder: false }
                    }
                }
            }
        });

        // Bookings Doughnut Chart
        const bookingsCtx = document.getElementById('bookingsChart').getContext('2d');
        new Chart(bookingsCtx, {
            type: 'doughnut',
            data: {
                labels: ['Confirmed', 'Pending'],
                datasets: [{
                    data: [{{ $stats['total_bookings'] - $stats['pending_bookings'] }}, {{ $stats['pending_bookings'] }}],
                    backgroundColor: ['#10B981', '#F59E0B'],
                    borderWidth: 0,
                    cutout: '75%'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#0e1330',
                        padding: 12,
                        borderColor: '#ff6f2d',
                        borderWidth: 1
                    }
                }
            }
        });

        // User Growth Bar Chart
        const userGrowthCtx = document.getElementById('userGrowthChart').getContext('2d');
        new Chart(userGrowthCtx, {
            type: 'bar',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'New Users',
                    data: [12, 19, 15, 25, 22, 30],
                    backgroundColor: 'rgba(14, 19, 48, 0.9)',
                    borderRadius: 8,
                    barThickness: 24
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#0e1330',
                        padding: 12,
                        borderColor: '#ff6f2d',
                        borderWidth: 1
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0, 0, 0, 0.05)', drawBorder: false }
                    },
                    x: {
                        grid: { display: false, drawBorder: false }
                    }
                }
            }
        });

        // Real-time updates
        function refreshDashboard() {
            document.getElementById('lastUpdate').textContent = 'just now';
            // Add your refresh logic here
        }

        function updateChart(period) {
            document.querySelectorAll('.time-btn').forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            // Add your chart update logic here
        }

        // Update timestamp
        setInterval(() => {
            const now = new Date();
            document.getElementById('lastUpdate').textContent = now.toLocaleTimeString();
        }, 60000);
    </script>
@endsection
