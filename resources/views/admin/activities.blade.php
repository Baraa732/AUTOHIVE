@extends('admin.layout')

@section('title', 'Admin Activities')
@section('icon', 'fas fa-history')

@section('content')
    <style>
        .activities-container {
            animation: fadeInUp 0.6s ease;
        }

        .activity-feed {
            background: var(--white);
            border-radius: var(--radius-xl);
            overflow: hidden;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--border-grey);
            animation: slideInUp 0.6s ease 0.2s both;
        }

        .feed-header {
            background: linear-gradient(135deg, var(--deep-green) 0%, #005555 100%);
            padding: var(--space-xl);
            color: var(--white);
            position: relative;
            overflow: hidden;
        }

        .feed-header::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(244, 192, 56, 0.1) 0%, transparent 70%);
            animation: rotate 20s linear infinite;
        }

        .feed-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: var(--space-sm);
            position: relative;
            z-index: 1;
        }

        .feed-subtitle {
            opacity: 0.9;
            font-size: 1rem;
            position: relative;
            z-index: 1;
        }

        .activity-list {
            max-height: 600px;
            overflow-y: auto;
            position: relative;
        }

        .activity-item {
            display: flex;
            align-items: flex-start;
            gap: var(--space-lg);
            padding: var(--space-lg);
            border-bottom: 1px solid var(--border-grey);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            animation: slideInLeft 0.5s ease forwards;
            opacity: 0;
            transform-style: preserve-3d;
        }

        .activity-item:nth-child(1) {
            animation-delay: 0.1s;
        }

        .activity-item:nth-child(2) {
            animation-delay: 0.2s;
        }

        .activity-item:nth-child(3) {
            animation-delay: 0.3s;
        }

        .activity-item:nth-child(4) {
            animation-delay: 0.4s;
        }

        .activity-item:nth-child(5) {
            animation-delay: 0.5s;
        }

        .activity-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 4px;
            height: 0;
            background: linear-gradient(to bottom, var(--deep-green), var(--yellow-accent));
            transition: height 0.3s ease;
        }

        .activity-item:hover::before {
            height: 100%;
        }

        .activity-item:hover {
            background: var(--off-white);
            transform: translateX(8px) rotateY(2deg);
            box-shadow: 0 8px 25px rgba(0, 63, 63, 0.1);
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-icon-wrapper {
            position: relative;
            flex-shrink: 0;
        }

        .activity-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 1.2rem;
            position: relative;
            animation: pulse 2s infinite;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        .activity-icon::before {
            content: '';
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            border-radius: 50%;
            background: linear-gradient(45deg, var(--deep-green), var(--yellow-accent));
            z-index: -1;
            animation: rotate 3s linear infinite;
        }

        .icon-login {
            background: linear-gradient(135deg, #10B981, #059669);
        }

        .icon-create {
            background: linear-gradient(135deg, #3B82F6, #1D4ED8);
        }

        .icon-delete {
            background: linear-gradient(135deg, #EF4444, #DC2626);
        }

        .icon-approve {
            background: linear-gradient(135deg, #8B5CF6, #7C3AED);
        }

        .icon-reject {
            background: linear-gradient(135deg, #F59E0B, #D97706);
        }

        .activity-content {
            flex: 1;
            min-width: 0;
        }

        .activity-description {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: var(--space-xs);
            line-height: 1.4;
        }

        .activity-meta {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            font-size: 0.85rem;
            color: var(--text-grey);
            margin-bottom: var(--space-sm);
        }

        .activity-admin {
            display: flex;
            align-items: center;
            gap: var(--space-xs);
            font-weight: 500;
        }

        .admin-avatar-small {
            width: 24px;
            height: 24px;
            background: linear-gradient(135deg, var(--deep-green), var(--yellow-accent));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 0.7rem;
            font-weight: 600;
        }

        .activity-time {
            display: flex;
            align-items: center;
            gap: var(--space-xs);
        }

        .activity-details {
            background: var(--light-grey);
            padding: var(--space-sm) var(--space-md);
            border-radius: var(--radius-md);
            font-size: 0.8rem;
            color: var(--text-grey);
            margin-top: var(--space-sm);
            border-left: 3px solid var(--deep-green);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--space-lg);
            margin-bottom: var(--space-2xl);
        }

        .stat-card-glow {
            background: var(--white);
            padding: var(--space-xl);
            border-radius: var(--radius-xl);
            border: 1px solid var(--border-grey);
            position: relative;
            overflow: hidden;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            animation: slideInUp 0.5s ease forwards;
            opacity: 0;
            transform-style: preserve-3d;
        }

        .stat-card-glow:nth-child(1) {
            animation-delay: 0.1s;
        }

        .stat-card-glow:nth-child(2) {
            animation-delay: 0.2s;
        }

        .stat-card-glow:nth-child(3) {
            animation-delay: 0.3s;
        }

        .stat-card-glow:nth-child(4) {
            animation-delay: 0.4s;
        }

        .stat-card-glow::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(0, 63, 63, 0.1), transparent);
            transition: left 0.8s ease;
        }

        .stat-card-glow:hover::before {
            left: 100%;
        }

        .stat-card-glow:hover {
            transform: translateY(-8px) rotateX(10deg) rotateY(5deg);
            box-shadow: 0 20px 40px rgba(0, 63, 63, 0.15);
        }

        .filter-tabs {
            display: flex;
            gap: var(--space-sm);
            margin-bottom: var(--space-lg);
            padding: var(--space-md);
            background: var(--white);
            border-radius: var(--radius-xl);
            border: 1px solid var(--border-grey);
            animation: slideInDown 0.5s ease;
        }

        .filter-tab {
            padding: 12px 20px;
            border: 2px solid transparent;
            background: transparent;
            color: var(--text-grey);
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            font-weight: 500;
            position: relative;
            overflow: hidden;
        }

        .filter-tab::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(0, 63, 63, 0.1), transparent);
            transition: left 0.5s ease;
        }

        .filter-tab:hover::before {
            left: 100%;
        }

        .filter-tab.active {
            border-color: var(--deep-green);
            background: var(--deep-green);
            color: var(--white);
            transform: scale(1.05) rotateX(5deg);
            box-shadow: 0 5px 15px rgba(0, 63, 63, 0.3);
        }

        @keyframes slideInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideInDown {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideInLeft {
            from {
                opacity: 0;
                transform: translateX(-30px);
            }

            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

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

        @keyframes pulse {

            0%,
            100% {
                transform: scale(1);
            }

            50% {
                transform: scale(1.1);
            }
        }

        @keyframes rotate {
            from {
                transform: rotate(0deg);
            }

            to {
                transform: rotate(360deg);
            }
        }
    </style>

    <div class="activities-container">
        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card-glow">
                <div class="stat-icon">
                    <i class="fas fa-history"></i>
                </div>
                <div class="stat-number">{{ $activities->total() }}</div>
                <div class="stat-label">Total Activities</div>
            </div>
            <div class="stat-card-glow">
                <div class="stat-icon">
                    <i class="fas fa-calendar-day"></i>
                </div>
                <div class="stat-number">{{ $activities->where('created_at', '>=', now()->startOfDay())->count() }}</div>
                <div class="stat-label">Today</div>
            </div>
            <div class="stat-card-glow">
                <div class="stat-icon">
                    <i class="fas fa-calendar-week"></i>
                </div>
                <div class="stat-number">{{ $activities->where('created_at', '>=', now()->startOfWeek())->count() }}</div>
                <div class="stat-label">This Week</div>
            </div>
            <div class="stat-card-glow">
                <div class="stat-icon">
                    <i class="fas fa-user-shield"></i>
                </div>
                <div class="stat-number">{{ $activities->groupBy('admin_id')->count() }}</div>
                <div class="stat-label">Active Admins</div>
            </div>
        </div>

        <!-- Filter Tabs -->
        <div class="filter-tabs">
            <button class="filter-tab active" onclick="filterActivities('all')">All Activities</button>
            <button class="filter-tab" onclick="filterActivities('login')">Logins</button>
            <button class="filter-tab" onclick="filterActivities('admin_created')">Admin Created</button>
            <button class="filter-tab" onclick="filterActivities('user_approved')">User Actions</button>
            <button class="filter-tab" onclick="filterActivities('today')">Today</button>
        </div>

        <!-- Activity Feed -->
        <div class="activity-feed">
            <div class="feed-header">
                <h2 class="feed-title">
                    <i class="fas fa-stream"></i>
                    Activity Stream
                </h2>
                <p class="feed-subtitle">Real-time admin activities and system events</p>
            </div>

            @if($activities->count() > 0)
                <div class="activity-list">
                    @foreach($activities as $activity)
                        <div class="activity-item" data-action="{{ $activity->action }}"
                            data-date="{{ $activity->created_at->format('Y-m-d') }}">
                            <div class="activity-icon-wrapper">
                                <div class="activity-icon 
                                                            @if($activity->action === 'login') icon-login
                                                            @elseif(str_contains($activity->action, 'created')) icon-create
                                                            @elseif(str_contains($activity->action, 'deleted')) icon-delete
                                                            @elseif(str_contains($activity->action, 'approved')) icon-approve
                                                            @elseif(str_contains($activity->action, 'rejected')) icon-reject
                                                            @else icon-create @endif">
                                    <i class="fas fa-
                                                                @if($activity->action === 'login') sign-in-alt
                                                                @elseif(str_contains($activity->action, 'created')) plus
                                                                @elseif(str_contains($activity->action, 'deleted')) trash
                                                                @elseif(str_contains($activity->action, 'approved')) check
                                                                @elseif(str_contains($activity->action, 'rejected')) times
                                                                @else cog @endif"></i>
                                </div>
                            </div>

                            <div class="activity-content">
                                <div class="activity-description">
                                    {{ $activity->description }}
                                </div>

                                <div class="activity-meta">
                                    <div class="activity-admin">
                                        <div class="admin-avatar-small">
                                            {{ substr($activity->admin->first_name, 0, 1) }}{{ substr($activity->admin->last_name, 0, 1) }}
                                        </div>
                                        <span>{{ $activity->admin->first_name }} {{ $activity->admin->last_name }}</span>
                                    </div>

                                    <div class="activity-time">
                                        <i class="fas fa-clock"></i>
                                        <span>{{ $activity->created_at->diffForHumans() }}</span>
                                    </div>
                                </div>

                                @if($activity->metadata)
                                    <div class="activity-details">
                                        <i class="fas fa-info-circle"></i>
                                        IP: {{ $activity->ip_address ?? 'Unknown' }} |
                                        Action: {{ ucfirst(str_replace('_', ' ', $activity->action)) }}
                                    </div>
                                @endif
                            </div>
                        </div>
                    @endforeach
                </div>

                @if($activities->hasPages())
                    <div style="padding: var(--space-lg); border-top: 1px solid var(--border-grey); background: var(--light-grey);">
                        {{ $activities->links() }}
                    </div>
                @endif
            @else
                <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
                    <i class="fas fa-history" style="font-size: 3rem; margin-bottom: var(--space-lg); opacity: 0.3;"></i>
                    <h3 style="margin-bottom: var(--space-sm);">No Activities Found</h3>
                    <p>No admin activities recorded yet.</p>
                </div>
            @endif
        </div>
    </div>

    <script>
        function filterActivities(type) {
            const items = document.querySelectorAll('.activity-item');
            const tabs = document.querySelectorAll('.filter-tab');

            // Update active tab
            tabs.forEach(tab => tab.classList.remove('active'));
            event.target.classList.add('active');

            // Filter items
            items.forEach(item => {
                let show = false;

                switch (type) {
                    case 'all':
                        show = true;
                        break;
                    case 'today':
                        show = item.dataset.date === new Date().toISOString().split('T')[0];
                        break;
                    default:
                        show = item.dataset.action === type || item.dataset.action.includes(type);
                }

                if (show) {
                    item.style.display = 'flex';
                    item.style.animation = 'slideInLeft 0.5s ease';
                } else {
                    item.style.display = 'none';
                }
            });
        }

        // Auto-refresh activities every 30 seconds
        setInterval(() => {
            // In a real application, you would fetch new activities via AJAX
            console.log('Checking for new activities...');
        }, 30000);

        // Animate items on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.animation = 'slideInLeft 0.5s ease forwards';
                }
            });
        }, observerOptions);

        document.addEventListener('DOMContentLoaded', () => {
            const activityItems = document.querySelectorAll('.activity-item');
            activityItems.forEach(item => observer.observe(item));
        });
    </script>
@endsection
