@extends('admin.layout')

@section('title', 'User Wallets')
@section('icon', 'fas fa-users')

@section('content')
<style>
    .wallet-users-container {
        animation: fadeInUp 0.6s ease;
    }

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

    .stat-box:nth-child(1) { animation-delay: 0.1s; }
    .stat-box:nth-child(2) { animation-delay: 0.2s; }
    .stat-box:nth-child(3) { animation-delay: 0.3s; }

    .stat-box:hover {
        transform: translateY(-5px);
        box-shadow: var(--shadow-lg);
    }

    .stat-icon {
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, #0e1330, #ff6f2d);
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

    .search-bar {
        margin-bottom: var(--space-lg);
        padding: var(--space-lg);
        background: var(--white);
        border-radius: var(--radius-xl);
        border: 1px solid var(--border-grey);
    }

    .search-wrapper {
        position: relative;
        max-width: 500px;
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
        box-shadow: 0 0 0 3px rgba(14, 19, 48, 0.2);
    }

    .search-icon {
        position: absolute;
        left: 18px;
        top: 50%;
        transform: translateY(-50%);
        color: #0e1330;
        font-size: 1rem;
        pointer-events: none;
        z-index: 2;
    }

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

    .table tr:hover {
        background: var(--off-white);
    }

    .user-info {
        display: flex;
        align-items: center;
        gap: var(--space-md);
    }

    .user-avatar {
        width: 40px;
        height: 40px;
        background: linear-gradient(135deg, #0e1330, #ff6f2d);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 600;
        font-size: 0.85rem;
        overflow: hidden;
    }

    .user-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
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

    .badge-warning {
        background: #F59E0B20;
        color: #F59E0B;
    }

    .badge-danger {
        background: #EF444420;
        color: #EF4444;
    }

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
        text-decoration: none;
    }

    .btn-info {
        background: #0e1330;
        color: var(--white);
    }

    .btn-info:hover {
        background: #ff6f2d;
        transform: translateY(-2px);
    }

    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @keyframes slideInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>

<div class="wallet-users-container">
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
                <i class="fas fa-dollar-sign"></i>
            </div>
            <div class="stat-number">${{ number_format(\App\Models\Wallet::sum('balance_spy') / 110, 2) }}</div>
            <div class="stat-label">Total Balance (USD)</div>
        </div>
        <div class="stat-box">
            <div class="stat-icon">
                <i class="fas fa-coins"></i>
            </div>
            <div class="stat-number">{{ number_format(\App\Models\Wallet::sum('balance_spy')) }}</div>
            <div class="stat-label">Total Balance (SPY)</div>
        </div>
    </div>

    <!-- Search Bar -->
    <div class="search-bar">
        <form method="GET" action="{{ route('admin.wallet.users') }}">
            <div class="search-wrapper">
                <div class="search-container">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" name="search" class="search-input" 
                           placeholder="Search users by name, phone, or ID..." 
                           value="{{ request('search') }}">
                </div>
            </div>
        </form>
    </div>

    <!-- Users Table -->
    <div class="users-table">
        <div class="table-header">
            <h3 class="card-title">
                <i class="fas fa-table"></i>
                User Wallets ({{ $users->total() }})
            </h3>
        </div>

        @if($users->count() > 0)
            <table class="table">
                <thead>
                    <tr>
                        <th>User</th>
                        <th>Phone</th>
                        <th>Wallet Balance</th>
                        <th>Status</th>
                        <th>Registered</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($users as $user)
                        <tr>
                            <td>
                                <div class="user-info">
                                    <div class="user-avatar">
                                        @if($user->profile_image_url)
                                            <img src="{{ $user->profile_image_url }}" alt="{{ $user->first_name }}">
                                        @else
                                            {{ substr($user->first_name, 0, 1) }}{{ substr($user->last_name, 0, 1) }}
                                        @endif
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
                            </td>
                            <td>
                                @if($user->wallet)
                                    <div style="font-weight: 600; color: #10B981;">
                                        ${{ number_format($user->wallet->balance_usd, 2) }}
                                    </div>
                                    <div style="font-size: 0.8rem; color: var(--text-grey);">
                                        {{ number_format($user->wallet->balance_spy) }} SPY
                                    </div>
                                @else
                                    <span style="color: #EF4444; font-weight: 500;">No wallet</span>
                                @endif
                            </td>
                            <td>
                                @if($user->status === 'approved')
                                    <span class="badge badge-success">
                                        <i class="fas fa-check"></i> Active
                                    </span>
                                @elseif($user->status === 'pending')
                                    <span class="badge badge-warning">
                                        <i class="fas fa-clock"></i> Pending
                                    </span>
                                @else
                                    <span class="badge badge-danger">
                                        <i class="fas fa-times"></i> {{ ucfirst($user->status) }}
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
                                <a href="{{ route('admin.users.show', $user->id) }}" class="btn btn-info">
                                    <i class="fas fa-eye"></i> View
                                </a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>

            @if($users->hasPages())
                <div style="padding: var(--space-lg); border-top: 1px solid var(--border-grey);">
                    {{ $users->links() }}
                </div>
            @endif
        @else
            <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
                <i class="fas fa-users" style="font-size: 3rem; margin-bottom: var(--space-lg); opacity: 0.3;"></i>
                <h3 style="margin-bottom: var(--space-sm);">No Users Found</h3>
                <p>No users match your search criteria.</p>
            </div>
        @endif
    </div>
</div>
@endsection
