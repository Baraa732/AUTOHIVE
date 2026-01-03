@extends('admin.layout')

@section('title', 'User Details')
@section('icon', 'fas fa-user')

@section('content')
<link rel="stylesheet" href="{{ asset('css/user-details.css') }}">

<div class="user-details-header">
    <a href="{{ route('admin.users') }}" class="back-btn">
        <i class="fas fa-arrow-left"></i> Back to Users
    </a>
</div>

<!-- Profile Card -->
<div class="user-profile-card">
    <div class="profile-header">
        <div class="profile-avatar">
            @if($user->profile_image_url)
                <img src="{{ $user->profile_image_url }}" alt="{{ $user->first_name }}">
            @else
                <div class="profile-avatar-placeholder">
                    {{ substr($user->first_name, 0, 1) }}{{ substr($user->last_name, 0, 1) }}
                </div>
            @endif
            <div class="status-badge {{ $user->is_approved ? 'approved' : 'pending' }}"></div>
        </div>
        
        <div class="profile-info">
            <h1>{{ $user->first_name }} {{ $user->last_name }}</h1>
            <div class="profile-meta">
                <span class="meta-badge role">
                    <i class="fas fa-user-tag"></i> {{ ucfirst($user->role) }}
                </span>
                <span class="meta-badge status">
                    <i class="fas fa-{{ $user->is_approved ? 'check-circle' : 'clock' }}"></i>
                    {{ $user->is_approved ? 'Approved' : 'Pending' }}
                </span>
            </div>
        </div>
    </div>
    
    <div class="info-grid">
        <div class="info-item">
            <div class="info-label">
                <i class="fas fa-id-badge"></i> User ID
            </div>
            <div class="info-value">{{ $user->id }}</div>
        </div>
        
        <div class="info-item">
            <div class="info-label">
                <i class="fas fa-phone"></i> Phone Number
            </div>
            <div class="info-value">{{ $user->phone }}</div>
        </div>
        
        <div class="info-item">
            <div class="info-label">
                <i class="fas fa-birthday-cake"></i> Birth Date
            </div>
            <div class="info-value">{{ $user->birth_date ? $user->birth_date->format('M d, Y') : 'Not provided' }}</div>
        </div>
        
        <div class="info-item">
            <div class="info-label">
                <i class="fas fa-calendar-plus"></i> Joined Date
            </div>
            <div class="info-value">{{ $user->created_at->format('M d, Y') }}</div>
        </div>
        
        <div class="info-item">
            <div class="info-label">
                <i class="fas fa-clock"></i> Last Updated
            </div>
            <div class="info-value">{{ $user->updated_at->diffForHumans() }}</div>
        </div>
        
        @if($user->wallet)
        <div class="info-item">
            <div class="info-label">
                <i class="fas fa-wallet"></i> Wallet Balance
            </div>
            <div class="info-value" style="color: #10B981;">${{ number_format($user->wallet->balance_usd, 2) }}</div>
        </div>
        @endif
    </div>
</div>

<!-- ID Verification -->
@if($user->id_image_url)
<div class="section-card">
    <div class="section-header">
        <i class="fas fa-id-card"></i>
        <h2>ID Verification</h2>
    </div>
    <div class="id-image-container">
        <img src="{{ $user->id_image_url }}" alt="ID" onclick="window.open('{{ $user->id_image_url }}', '_blank')">
        <p style="margin-top: 16px; color: #5A6C7D; font-size: 0.9rem;">Click image to view full size</p>
    </div>
</div>
@endif

<!-- Statistics -->
<div class="section-card">
    <div class="section-header">
        <i class="fas fa-chart-bar"></i>
        <h2>Statistics</h2>
    </div>
    <div class="stats-grid">
        @if($user->role == 'landlord')
            <div class="stat-card">
                <div class="stat-value">{{ $user->apartments->count() }}</div>
                <div class="stat-label">Total Apartments</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{{ $user->apartments->sum(function($apt) { return $apt->bookings->count(); }) }}</div>
                <div class="stat-label">Total Bookings</div>
            </div>
        @else
            <div class="stat-card">
                <div class="stat-value">{{ $user->bookings->count() }}</div>
                <div class="stat-label">Total Bookings</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">{{ $user->reviews->count() }}</div>
                <div class="stat-label">Reviews Given</div>
            </div>
        @endif
        <div class="stat-card">
            <div class="stat-value">{{ $user->favorites->count() }}</div>
            <div class="stat-label">Favorites</div>
        </div>
    </div>
</div>

<!-- Actions -->
<div class="action-buttons">
    <form method="POST" action="{{ route('admin.users.destroy', $user->id) }}" onsubmit="return confirm('Are you sure you want to delete this user? This action cannot be undone.')">
        @csrf
        @method('DELETE')
        <button type="submit" class="btn-danger">
            <i class="fas fa-trash"></i> Delete User
        </button>
    </form>
</div>
@endsection
