@extends('admin.layout')

@section('title', 'Bookings Management')
@section('icon', 'fas fa-calendar-check')

@section('content')
<style>
    .bookings-container {
        animation: fadeInUp 0.6s ease;
    }
    
    .timeline-container {
        position: relative;
        margin: var(--space-2xl) 0;
    }
    
    .timeline {
        position: relative;
        padding: 0;
        list-style: none;
    }
    
    .timeline::before {
        content: '';
        position: absolute;
        top: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 4px;
        height: 100%;
        background: linear-gradient(to bottom, #0e1330, #ff6f2d);
        border-radius: 2px;
        animation: drawLine 2s ease-in-out;
    }
    
    .timeline-item {
        position: relative;
        margin-bottom: var(--space-2xl);
        animation: slideInTimeline 0.8s ease forwards;
        opacity: 0;
    }
    
    .timeline-item:nth-child(odd) { animation-delay: 0.2s; }
    .timeline-item:nth-child(even) { animation-delay: 0.4s; }
    
    .timeline-item::before {
        content: '';
        position: absolute;
        top: 20px;
        left: 50%;
        transform: translateX(-50%);
        width: 20px;
        height: 20px;
        background: var(--white);
        border: 4px solid #0e1330;
        border-radius: 50%;
        z-index: 2;
        animation: pulse 2s infinite;
    }
    
    .timeline-content {
        position: relative;
        width: 45%;
        background: var(--white);
        padding: var(--space-lg);
        border-radius: var(--radius-xl);
        box-shadow: var(--shadow-card);
        border: 1px solid var(--border-grey);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        transform-style: preserve-3d;
    }
    
    .timeline-item:nth-child(odd) .timeline-content {
        margin-left: auto;
        margin-right: 55%;
    }
    
    .timeline-item:nth-child(even) .timeline-content {
        margin-left: 55%;
    }
    
    .timeline-content:hover {
        transform: translateY(-5px) rotateX(5deg) rotateY(2deg);
        box-shadow: 0 15px 35px rgba(15, 20, 25, 0.15);
    }
    
    .timeline-content::before {
        content: '';
        position: absolute;
        top: 20px;
        width: 0;
        height: 0;
        border: 15px solid transparent;
    }
    
    .timeline-item:nth-child(odd) .timeline-content::before {
        right: -30px;
        border-left-color: var(--white);
    }
    
    .timeline-item:nth-child(even) .timeline-content::before {
        left: -30px;
        border-right-color: var(--white);
    }
    
    .booking-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: var(--space-md);
    }
    
    .booking-id {
        font-size: 0.8rem;
        color: var(--text-grey);
        font-weight: 600;
    }
    
    .booking-status {
        padding: 4px 12px;
        border-radius: var(--radius-lg);
        font-size: 0.75rem;
        font-weight: 600;
        animation: bounceIn 0.5s ease;
    }
    
    .status-pending {
        background: #F59E0B20;
        color: #F59E0B;
    }
    
    .status-confirmed {
        background: #10B98120;
        color: #10B981;
    }
    
    .status-cancelled {
        background: #EF444420;
        color: #EF4444;
    }
    
    .status-completed {
        background: #6366F120;
        color: #6366F1;
    }
    
    .booking-guest {
        display: flex;
        align-items: center;
        gap: var(--space-md);
        margin-bottom: var(--space-md);
    }
    
    .guest-avatar {
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, #0e1330, #ff6f2d);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--white);
        font-weight: 700;
        font-size: 1.1rem;
        animation: rotateIn 0.6s ease;
        cursor: pointer;
        transition: transform 0.3s ease;
    }
    
    .guest-avatar:hover {
        transform: scale(1.1);
    }
    
    .guest-info h4 {
        font-size: 1.1rem;
        font-weight: 600;
        color: #0e1330;
        margin-bottom: 2px;
        cursor: pointer;
        transition: color 0.3s ease;
        text-decoration: none;
    }
    
    .guest-info h4:hover {
        color: #ff6f2d;
        text-decoration: underline;
    }
    
    .guest-info p {
        font-size: 0.9rem;
        color: var(--text-grey);
        margin: 0;
    }
    
    .booking-details {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: var(--space-md);
        margin-bottom: var(--space-lg);
    }
    
    .detail-group {
        display: flex;
        align-items: center;
        gap: var(--space-sm);
        font-size: 0.9rem;
        color: var(--text-grey);
    }
    
    .detail-group i {
        color: #0e1330;
        width: 16px;
    }
    
    .apartment-link {
        color: #0e1330;
        font-weight: 600;
        cursor: pointer;
        transition: color 0.3s ease;
        text-decoration: none;
    }
    
    .apartment-link:hover {
        color: #ff6f2d;
        text-decoration: underline;
    }
    
    .booking-price {
        text-align: center;
        padding: var(--space-md);
        background: var(--light-grey);
        border-radius: var(--radius-md);
        margin-bottom: var(--space-lg);
    }
    
    .price-amount {
        font-size: 1.5rem;
        font-weight: 700;
        color: #0e1330;
    }
    
    .price-label {
        font-size: 0.8rem;
        color: var(--text-grey);
    }
    
    .booking-actions {
        display: flex;
        gap: var(--space-sm);
    }
    
    .action-btn {
        flex: 1;
        padding: 10px;
        border: none;
        border-radius: var(--radius-md);
        font-weight: 600;
        font-size: 0.85rem;
        cursor: pointer;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        display: flex;
        align-items: center;
        justify-content: center;
        gap: var(--space-xs);
        position: relative;
        overflow: hidden;
        transform-style: preserve-3d;
    }
    
    .action-btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s ease;
    }
    
    .action-btn:hover::before {
        left: 100%;
    }
    
    .action-btn:hover {
        transform: translateY(-2px) rotateX(10deg);
    }
    
    .btn-approve {
        background: #10B981;
        color: var(--white);
    }
    
    .btn-reject {
        background: #EF4444;
        color: var(--white);
    }
    
    .btn-view {
        background: #0e1330;
        color: var(--white);
    }
    
    .stats-dashboard {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: var(--space-lg);
        margin-bottom: var(--space-2xl);
    }
    
    .stat-card-animated {
        background: var(--white);
        border-radius: var(--radius-xl);
        padding: var(--space-xl);
        border: 1px solid var(--border-grey);
        transition: transform 0.2s ease;
        position: relative;
        overflow: hidden;
        animation: slideInLeft 0.5s ease-out;
        animation-fill-mode: both;
    }
    
    .stat-card-animated::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #0e1330, #ff6f2d);
    }
    
    .stat-card-animated:nth-child(1) { animation-delay: 0.1s; }
    .stat-card-animated:nth-child(2) { animation-delay: 0.2s; }
    .stat-card-animated:nth-child(3) { animation-delay: 0.3s; }
    .stat-card-animated:nth-child(4) { animation-delay: 0.4s; }
    
    .stat-card-animated::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(15, 20, 25, 0.05), transparent);
        transition: left 0.8s ease;
    }
    
    .stat-card-animated:hover::before {
        left: 100%;
    }
    
    .stat-card-animated:hover {
        transform: translateY(-4px);
        box-shadow: var(--shadow-lg);
    }
    
    .kpi-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: var(--space-md);
    }

    .kpi-icon-wrapper {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 1.2rem;
    }

    .kpi-body {
        text-align: left;
    }

    .kpi-value {
        font-size: 2rem;
        font-weight: 700;
        color: var(--text-dark);
        margin-bottom: var(--space-xs);
    }

    .kpi-label {
        color: var(--text-grey);
        font-size: 0.9rem;
        font-weight: 500;
    }

    .stat-icon-large {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, #0e1330, #ff6f2d);
        border-radius: var(--radius-md);
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--white);
        font-size: 1.2rem;
        margin-bottom: var(--space-md);
    }
    
    /* Modal Styles */
    .booking-modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(14, 19, 48, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
    }
    
    .booking-modal.active {
        opacity: 1;
        visibility: visible;
    }
    
    .modal-content {
        background: white;
        padding: var(--space-2xl);
        border-radius: var(--radius-xl);
        max-width: 500px;
        width: 90%;
        max-height: 80vh;
        overflow-y: auto;
        transform: translateY(-20px);
        transition: transform 0.3s ease;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    }
    
    .booking-modal.active .modal-content {
        transform: translateY(0);
    }
    
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: var(--space-xl);
    }
    
    .modal-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: #0e1330;
    }
    
    .modal-close {
        background: none;
        border: none;
        font-size: 1.5rem;
        color: var(--text-grey);
        cursor: pointer;
        transition: color 0.3s ease;
    }
    
    .modal-close:hover {
        color: #ff6f2d;
    }
    
    .modal-details {
        display: grid;
        gap: var(--space-lg);
    }
    
    .detail-row {
        display: flex;
        justify-content: space-between;
        padding-bottom: var(--space-sm);
        border-bottom: 1px solid var(--border-grey);
    }
    
    .detail-label {
        color: var(--text-grey);
        font-weight: 500;
    }
    
    .detail-value {
        color: #0e1330;
        font-weight: 600;
    }
    
    .modal-actions {
        display: flex;
        gap: var(--space-md);
        margin-top: var(--space-xl);
    }
    
    .modal-btn {
        flex: 1;
        padding: 12px;
        border: none;
        border-radius: var(--radius-md);
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
    }
    
    .btn-primary {
        background: #0e1330;
        color: white;
    }
    
    .btn-primary:hover {
        background: #ff6f2d;
        transform: translateY(-2px);
    }
    
    .btn-secondary {
        background: var(--light-grey);
        color: var(--text-dark);
    }
    
    .btn-secondary:hover {
        background: #e5e7eb;
    }
    
    @keyframes slideInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    @keyframes slideInTimeline {
        from { opacity: 0; transform: translateX(-50px); }
        to { opacity: 1; transform: translateX(0); }
    }
    
    @keyframes drawLine {
        from { height: 0; }
        to { height: 100%; }
    }
    
    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    @keyframes rotateIn {
        from { opacity: 0; transform: rotate(-180deg) scale(0); }
        to { opacity: 1; transform: rotate(0deg) scale(1); }
    }
    
    @keyframes bounceIn {
        0% { opacity: 0; transform: scale(0.3); }
        50% { opacity: 1; transform: scale(1.05); }
        70% { transform: scale(0.9); }
        100% { opacity: 1; transform: scale(1); }
    }
    
    @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
    }
    
    @media (max-width: 768px) {
        .timeline::before {
            left: 30px;
        }
        
        .timeline-item::before {
            left: 30px;
        }
        
        .timeline-content {
            width: calc(100% - 80px);
            margin-left: 80px !important;
            margin-right: 0 !important;
        }
        
        .timeline-content::before {
            left: -30px !important;
            border-right-color: var(--white) !important;
            border-left-color: transparent !important;
        }
        
        .modal-content {
            width: 95%;
            padding: var(--space-lg);
        }
    }
</style>

<div class="bookings-container">
    <link rel="stylesheet" href="{{ asset('css/dashboard-advanced.css') }}">

    <!-- Stats Dashboard -->
    <div class="kpi-grid fade-in-up-03">
        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper" style="background: linear-gradient(135deg, #0e1330, #17173a);">
                    <i class="fas fa-calendar-alt"></i>
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $bookings->total() }}</div>
                <div class="kpi-label">Total Bookings</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper" style="background: linear-gradient(135deg, #F59E0B, #D97706);">
                    <i class="fas fa-clock"></i>
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $bookings->where('status', 'pending')->count() }}</div>
                <div class="kpi-label">Pending</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper" style="background: linear-gradient(135deg, #10B981, #059669);">
                    <i class="fas fa-check-double"></i>
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $bookings->where('status', 'confirmed')->count() }}</div>
                <div class="kpi-label">Confirmed</div>
            </div>
        </div>
        <div class="kpi-card highlight">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper">
                    <i class="fas fa-coins"></i>
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">${{ number_format($bookings->where('status', 'completed')->sum('total_price'), 0) }}</div>
                <div class="kpi-label">Revenue</div>
            </div>
        </div>
    </div>

    <!-- Bookings Timeline -->
    @if($bookings->count() > 0)
        <div class="timeline-container">
            <ul class="timeline">
                @foreach($bookings as $booking)
                    <li class="timeline-item">
                        <div class="timeline-content">
                            <div class="booking-header">
                                <div class="booking-id">Booking #{{ $booking->id }}</div>
                                <div class="booking-status status-{{ $booking->status }}">
                                    {{ ucfirst($booking->status) }}
                                </div>
                            </div>
                            
                            <div class="booking-guest">
                                @if($booking->user && $booking->user->id)
                                    <a href="{{ route('admin.users.show', $booking->user->id) }}" style="text-decoration: none; display: flex; align-items: center; gap: var(--space-md);">
                                        @if($booking->user->profile_image)
                                            <img src="{{ asset('storage/' . $booking->user->profile_image) }}" alt="{{ $booking->user->first_name }}" class="guest-avatar" style="object-fit: cover;">
                                        @else
                                            <div class="guest-avatar">
                                                {{ substr($booking->user->first_name ?? 'U', 0, 1) }}{{ substr($booking->user->last_name ?? 'N', 0, 1) }}
                                            </div>
                                        @endif
                                        <div class="guest-info">
                                            <h4>{{ $booking->user->first_name ?? 'Unknown' }} {{ $booking->user->last_name ?? 'User' }}</h4>
                                            <p>{{ $booking->user->phone ?? 'N/A' }}</p>
                                        </div>
                                    </a>
                                @else
                                    <div style="display: flex; align-items: center; gap: var(--space-md);">
                                        <div class="guest-avatar">
                                            UU
                                        </div>
                                        <div class="guest-info">
                                            <h4>Unknown User</h4>
                                            <p>N/A</p>
                                        </div>
                                    </div>
                                @endif
                            </div>
                            
                            <div class="booking-details">
                                <div class="detail-group">
                                    <i class="fas fa-home"></i>
                                    @if($booking->apartment && $booking->apartment->id)
                                        <a href="{{ route('admin.apartments.show', $booking->apartment->id) }}" class="apartment-link">
                                            {{ Str::limit($booking->apartment->title ?? 'Unknown', 20) }}
                                        </a>
                                    @else
                                        <span>Unknown Apartment</span>
                                    @endif
                                </div>
                                <div class="detail-group">
                                    <i class="fas fa-calendar-alt"></i>
                                    <span>{{ $booking->check_in->format('M d, Y') }} - {{ $booking->check_out->format('M d, Y') }}</span>
                                </div>
                                <div class="detail-group">
                                    <i class="fas fa-moon"></i>
                                    <span>{{ $booking->check_in->diffInDays($booking->check_out) }} nights</span>
                                </div>
                                <div class="detail-group">
                                    <i class="fas fa-clock"></i>
                                    <span>{{ $booking->created_at->diffForHumans() }}</span>
                                </div>
                            </div>
                            
                            <div class="booking-price">
                                <div class="price-amount">${{ number_format($booking->total_price, 2) }}</div>
                                <div class="price-label">Total Amount</div>
</div>
                            
                            <div class="booking-actions">
                                @if($booking->status === 'pending')
                                    <form method="POST" action="{{ route('admin.bookings.approve', $booking->id) }}" style="flex: 1;" id="approveBookingForm{{ $booking->id }}">
                                        @csrf
                                        <button type="button" class="action-btn btn-approve" onclick="confirmAction(document.getElementById('approveBookingForm{{ $booking->id }}'), 'Approve Booking', 'Approve booking for {{ $booking->user->first_name ?? "Unknown" }} {{ $booking->user->last_name ?? "User" }}?')">
                                            <i class="fas fa-check"></i>
                                            Approve
                                        </button>
                                    </form>
                                    <form method="POST" action="{{ route('admin.bookings.reject', $booking->id) }}" style="flex: 1;" id="rejectBookingForm{{ $booking->id }}">
                                        @csrf
                                        <button type="button" class="action-btn btn-reject" onclick="confirmAction(document.getElementById('rejectBookingForm{{ $booking->id }}'), 'Reject Booking', 'Reject booking for {{ $booking->user->first_name ?? "Unknown" }} {{ $booking->user->last_name ?? "User" }}?')">
                                            <i class="fas fa-times"></i>
                                            Reject
                                        </button>
                                    </form>
                                @else
                                    <button class="action-btn btn-view" onclick="viewBookingDetails({{ $booking->id }})">
                                        <i class="fas fa-eye"></i>
                                        View Details
                                    </button>
                                @endif
                            </div>
                        </div>
                    </li>
                @endforeach
            </ul>
        </div>
        
        @if($bookings->hasPages())
            <div style="display: flex; justify-content: center; margin-top: var(--space-2xl);">
                {{ $bookings->links() }}
            </div>
        @endif
    @else
        <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey); animation: fadeInUp 0.6s ease;">
            <i class="fas fa-calendar-times" style="font-size: 4rem; margin-bottom: var(--space-lg); opacity: 0.3;"></i>
            <h3 style="margin-bottom: var(--space-sm); font-size: 1.5rem;">No Bookings Found</h3>
            <p style="font-size: 1rem;">No bookings have been made yet.</p>
        </div>
    @endif
</div>

<!-- Booking Details Modal -->
<div class="booking-modal" id="bookingModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title">Booking Details</h2>
            <button class="modal-close" onclick="closeBookingModal()">&times;</button>
        </div>
        <div class="modal-details" id="modalDetails">
            <!-- Dynamic content will be loaded here -->
        </div>
        <div class="modal-actions">
            <button class="modal-btn btn-primary" onclick="closeBookingModal()">Close</button>
            <button class="modal-btn btn-secondary" id="viewFullDetailsBtn" style="display: none;">View Full Details</button>
        </div>
    </div>
</div>

<script>
    // View booking details in modal
    async function viewBookingDetails(bookingId) {
        try {
            const response = await fetch(`/admin/bookings/${bookingId}/details`);
            const booking = await response.json();
            
            if (booking.error) {
                showNotification('error', 'Error', booking.error);
                return;
            }
            
            // Format dates
            const checkIn = new Date(booking.check_in).toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            
            const checkOut = new Date(booking.check_out).toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            
            const created = new Date(booking.created_at).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
            
            // Calculate nights
            const nights = Math.ceil((new Date(booking.check_out) - new Date(booking.check_in)) / (1000 * 60 * 60 * 24));
            
            // Status badge color
            const statusColors = {
                'pending': '#F59E0B',
                'confirmed': '#10B981',
                'cancelled': '#EF4444',
                'completed': '#6366F1'
            };
            
            // Create modal content
            const modalDetails = document.getElementById('modalDetails');
            modalDetails.innerHTML = `
                <div class="detail-row">
                    <span class="detail-label">Booking ID:</span>
                    <span class="detail-value">#${booking.id}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Guest:</span>
                    <span class="detail-value">${booking.tenant?.first_name || booking.user?.first_name || 'Unknown'} ${booking.tenant?.last_name || booking.user?.last_name || 'User'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Phone:</span>
                    <span class="detail-value">${booking.tenant?.phone || booking.user?.phone || 'N/A'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Apartment:</span>
                    <span class="detail-value">${booking.apartment?.title || 'N/A'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Check-in:</span>
                    <span class="detail-value">${checkIn}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Check-out:</span>
                    <span class="detail-value">${checkOut}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Duration:</span>
                    <span class="detail-value">${nights} nights</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total Price:</span>
                    <span class="detail-value" style="color: #ff6f2d; font-weight: 700;">$${parseFloat(booking.total_price).toFixed(2)}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span class="detail-value" style="color: ${statusColors[booking.status] || '#6B7280'}; font-weight: 600;">
                        ${booking.status.charAt(0).toUpperCase() + booking.status.slice(1)}
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Created:</span>
                    <span class="detail-value">${created}</span>
                </div>
                ${booking.payment_details ? `
                <div class="detail-row">
                    <span class="detail-label">Payment Method:</span>
                    <span class="detail-value">${booking.payment_details.method || 'N/A'}</span>
                </div>
                ` : ''}
            `;
            
            // Set up view full details button
            const viewFullBtn = document.getElementById('viewFullDetailsBtn');
            viewFullBtn.style.display = 'inline-block';
            viewFullBtn.onclick = function() {
                window.location.href = `/admin/bookings`;
            };
            
            // Show modal
            document.getElementById('bookingModal').classList.add('active');
            document.body.style.overflow = 'hidden';
            
        } catch (error) {
            console.error('Error fetching booking details:', error);
            showNotification('error', 'Error', 'Failed to load booking details');
        }
    }
    
    function closeBookingModal() {
        document.getElementById('bookingModal').classList.remove('active');
        document.body.style.overflow = 'auto';
    }
    
    // Close modal when clicking outside
    document.getElementById('bookingModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeBookingModal();
        }
    });
    
    // Close modal with ESC key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeBookingModal();
        }
    });
    
    function confirmAction(form, title, message) {
        if (confirm(`${title}\n\n${message}`)) {
            form.submit();
        }
    }
    
    // Animate timeline items on scroll
    const observerOptions = {
        threshold: 0.2,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.animation = 'slideInTimeline 0.8s ease forwards';
            }
        });
    }, observerOptions);
    
    document.addEventListener('DOMContentLoaded', () => {
        const timelineItems = document.querySelectorAll('.timeline-item');
        timelineItems.forEach(item => observer.observe(item));
        
        // Add hover effects for apartment links
        const apartmentLinks = document.querySelectorAll('.apartment-link');
        apartmentLinks.forEach(link => {
            link.addEventListener('mouseenter', function() {
                this.style.textDecoration = 'underline';
            });
            link.addEventListener('mouseleave', function() {
                this.style.textDecoration = 'none';
            });
        });
        
        // Add hover effects for guest names
        const guestNames = document.querySelectorAll('.guest-info h4');
        guestNames.forEach(name => {
            name.addEventListener('mouseenter', function() {
                this.style.textDecoration = 'underline';
            });
            name.addEventListener('mouseleave', function() {
                this.style.textDecoration = 'none';
            });
        });
    });
    
    // Helper functions for notifications and modals
    function showNotification(type, title, message) {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <strong>${title}</strong>
            <p>${message}</p>
        `;
        
        document.body.appendChild(notification);
        
        // Auto remove after 5 seconds
        setTimeout(() => {
            notification.remove();
        }, 5000);
    }
</script>

<!-- Add notification styles -->
<style>
    .notification {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 8px;
        color: white;
        z-index: 1001;
        animation: slideInRight 0.3s ease;
        max-width: 300px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    
    .notification-success {
        background: #10B981;
        border-left: 4px solid #059669;
    }
    
    .notification-error {
        background: #EF4444;
        border-left: 4px solid #DC2626;
    }
    
    .notification-info {
        background: #3B82F6;
        border-left: 4px solid #1D4ED8;
    }
    
    .notification-warning {
        background: #F59E0B;
        border-left: 4px solid #D97706;
    }
    
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
</style>
@endsection
