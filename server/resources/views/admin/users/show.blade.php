@extends('admin.layout')

@section('title', 'User Details')
@section('icon', 'fas fa-user')

@section('content')
<div style="margin-bottom: var(--space-lg);">
    <a href="{{ route('admin.users') }}" style="color: var(--deep-green); text-decoration: none; font-weight: 500;">
        <i class="fas fa-arrow-left"></i> Back to Users
    </a>
</div>

<div class="content-card">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-user"></i>
            User Information
        </h3>
    </div>
    
    <div style="padding: var(--space-xl);">
        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: var(--space-xl); align-items: start;">
            <!-- User Avatar -->
            <div style="text-align: center;">
                @if($user->profile_image_url)
                    <img src="{{ $user->profile_image_url }}" alt="Profile" style="width: 120px; height: 120px; object-fit: cover; border-radius: 50%; border: 4px solid var(--border-grey); margin: 0 auto var(--space-md); display: block;">
                @else
                    <div style="width: 120px; height: 120px; background: linear-gradient(135deg, var(--deep-green), var(--yellow-accent)); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: var(--white); font-size: 2rem; font-weight: 600; margin: 0 auto var(--space-md);">
                        {{ substr($user->first_name, 0, 1) }}{{ substr($user->last_name, 0, 1) }}
                    </div>
                @endif
                <h2 style="margin: 0 0 var(--space-sm) 0; color: var(--text-dark);">{{ $user->first_name }} {{ $user->last_name }}</h2>
                <span style="padding: 6px 16px; border-radius: var(--radius-lg); font-size: 0.85rem; font-weight: 600; background: {{ $user->role == 'landlord' ? '#10B981' : '#3B82F6' }}20; color: {{ $user->role == 'landlord' ? '#10B981' : '#3B82F6' }};">
                    {{ ucfirst($user->role) }}
                </span>
            </div>
            
            <!-- User Details -->
            <div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-lg);">
                    <div>
                        <label style="display: block; font-weight: 600; color: var(--text-dark); margin-bottom: var(--space-xs);">User ID</label>
                        <p style="margin: 0; color: var(--text-grey); font-family: monospace;">{{ $user->display_id }}</p>
                    </div>
                    
                    <div>
                        <label style="display: block; font-weight: 600; color: var(--text-dark); margin-bottom: var(--space-xs);">Phone Number</label>
                        <p style="margin: 0; color: var(--text-grey);">{{ $user->phone }}</p>
                    </div>
                    
                    <div>
                        <label style="display: block; font-weight: 600; color: var(--text-dark); margin-bottom: var(--space-xs);">Birth Date</label>
                        <p style="margin: 0; color: var(--text-grey);">{{ $user->birth_date ? $user->birth_date->format('F d, Y') : 'Not provided' }}</p>
                    </div>
                    
                    <div>
                        <label style="display: block; font-weight: 600; color: var(--text-dark); margin-bottom: var(--space-xs);">Status</label>
                        <span style="padding: 4px 12px; border-radius: var(--radius-lg); font-size: 0.75rem; font-weight: 600; background: #10B98120; color: #10B981;">
                            {{ ucfirst($user->status) }}
                        </span>
                    </div>
                    
                    <div>
                        <label style="display: block; font-weight: 600; color: var(--text-dark); margin-bottom: var(--space-xs);">Joined Date</label>
                        <p style="margin: 0; color: var(--text-grey);">{{ $user->created_at->format('F d, Y \a\t g:i A') }}</p>
                    </div>
                    
                    <div>
                        <label style="display: block; font-weight: 600; color: var(--text-dark); margin-bottom: var(--space-xs);">Last Updated</label>
                        <p style="margin: 0; color: var(--text-grey);">{{ $user->updated_at->format('F d, Y \a\t g:i A') }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ID Image -->
@if($user->id_image_url)
<div class="content-card" style="margin-top: var(--space-lg);">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-id-card"></i>
            ID Verification
        </h3>
    </div>
    
    <div style="padding: var(--space-xl); text-align: center;">
        <img src="{{ $user->id_image_url }}" alt="ID" style="max-width: 100%; max-height: 400px; border-radius: var(--radius-md); border: 2px solid var(--border-grey); cursor: pointer;" onclick="window.open('{{ $user->id_image_url }}', '_blank')">
        <p style="margin-top: var(--space-md); color: var(--text-grey); font-size: 0.9rem;">Click image to view full size</p>
    </div>
</div>
@endif

<!-- Statistics -->
@if($user->role == 'landlord')
<div class="content-card" style="margin-top: var(--space-lg);">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-chart-bar"></i>
            Landlord Statistics
        </h3>
    </div>
    
    <div style="padding: var(--space-lg);">
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-md);">
            <div style="text-align: center; padding: var(--space-md); background: var(--light-grey); border-radius: var(--radius-md);">
                <div style="font-size: 1.5rem; font-weight: 700; color: var(--deep-green);">{{ $user->apartments->count() }}</div>
                <div style="font-size: 0.9rem; color: var(--text-grey);">Total Apartments</div>
            </div>
            
            <div style="text-align: center; padding: var(--space-md); background: var(--light-grey); border-radius: var(--radius-md);">
                <div style="font-size: 1.5rem; font-weight: 700; color: var(--deep-green);">{{ $user->apartments->sum(function($apt) { return $apt->bookings->count(); }) }}</div>
                <div style="font-size: 0.9rem; color: var(--text-grey);">Total Bookings</div>
            </div>
        </div>
    </div>
</div>
@endif

@if($user->role == 'tenant')
<div class="content-card" style="margin-top: var(--space-lg);">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-chart-bar"></i>
            Tenant Statistics
        </h3>
    </div>
    
    <div style="padding: var(--space-lg);">
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-md);">
            <div style="text-align: center; padding: var(--space-md); background: var(--light-grey); border-radius: var(--radius-md);">
                <div style="font-size: 1.5rem; font-weight: 700; color: var(--deep-green);">{{ $user->bookings->count() }}</div>
                <div style="font-size: 0.9rem; color: var(--text-grey);">Total Bookings</div>
            </div>
            
            <div style="text-align: center; padding: var(--space-md); background: var(--light-grey); border-radius: var(--radius-md);">
                <div style="font-size: 1.5rem; font-weight: 700; color: var(--deep-green);">{{ $user->reviews->count() }}</div>
                <div style="font-size: 0.9rem; color: var(--text-grey);">Reviews Given</div>
            </div>
        </div>
    </div>
</div>
@endif

<!-- Actions -->
<div style="margin-top: var(--space-lg); display: flex; gap: var(--space-md);">
    <form method="POST" action="{{ route('admin.users.destroy', $user->id) }}" onsubmit="return confirm('Are you sure you want to delete this user? This action cannot be undone.')">
        @csrf
        @method('DELETE')
        <button type="submit" style="background: #EF4444; color: white; border: none; padding: 12px 24px; border-radius: var(--radius-md); cursor: pointer; font-weight: 500;">
            <i class="fas fa-trash"></i> Delete User
        </button>
    </form>
</div>
@endsection