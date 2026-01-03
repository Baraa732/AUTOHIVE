@extends('admin.layout')

@section('title', 'Apartment Details')
@section('icon', 'fas fa-home')

@section('content')
<style>
    :root {
        --forest-green: #0e1330;
        --sage-green: #17173a;
        --cream-light: #fff5e6;
        --terracotta: #ff6f2d;
        --text-dark: #0e1330;
        --text-grey: #636E72;
        --white: #FFFFFF;
        --border-grey: rgba(255, 111, 45, 0.2);
        --space-sm: 0.5rem;
        --space-md: 1rem;
        --space-lg: 1.5rem;
        --space-xl: 2rem;
        --space-2xl: 3rem;
        --radius-md: 8px;
        --radius-lg: 12px;
        --radius-xl: 16px;
        --transition: all 0.3s ease;
        --shadow-soft: 0 4px 12px rgba(0, 0, 0, 0.08);
        --shadow-medium: 0 8px 25px rgba(0, 0, 0, 0.12);
    }

    .apartment-details-container {
        animation: fadeInUp 0.6s ease;
    }

    /* Back Button */
    .back-button {
        margin-bottom: var(--space-xl);
    }

    .btn-back {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        padding: 12px 24px;
        background: linear-gradient(135deg, var(--forest-green), var(--sage-green));
        color: white;
        border: none;
        border-radius: var(--radius-lg);
        font-weight: 600;
        cursor: pointer;
        transition: var(--transition);
        text-decoration: none;
    }

    .btn-back:hover {
        transform: translateX(-5px);
        box-shadow: 0 4px 15px rgba(14, 19, 48, 0.3);
    }

    /* Status Badge */
    .status-badge-large {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 10px 20px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 0.9rem;
        margin-bottom: var(--space-lg);
    }

    .status-pending {
        background: #fef3c7;
        color: #92400e;
        border: 1px solid #fbbf24;
    }

    .status-approved {
        background: #d1fae5;
        color: #065f46;
        border: 1px solid #10b981;
    }

    .status-rejected {
        background: #fee2e2;
        color: #991b1b;
        border: 1px solid #ef4444;
    }

    /* Main Layout */
    .apartment-header {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: var(--space-xl);
        margin-bottom: var(--space-2xl);
    }

    @media (max-width: 1024px) {
        .apartment-header {
            grid-template-columns: 1fr;
        }
    }

    /* Image Gallery */
    .image-gallery {
        position: relative;
    }

    .main-image {
        width: 100%;
        height: 400px;
        border-radius: var(--radius-xl);
        overflow: hidden;
        box-shadow: var(--shadow-medium);
        margin-bottom: var(--space-md);
    }

    .main-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.5s ease;
    }

    .main-image:hover img {
        transform: scale(1.05);
    }

    .image-thumbnails {
        display: flex;
        gap: 12px;
        overflow-x: auto;
        padding: var(--space-sm) 0;
    }

    .thumbnail {
        width: 80px;
        height: 80px;
        border-radius: var(--radius-md);
        overflow: hidden;
        cursor: pointer;
        border: 2px solid transparent;
        transition: var(--transition);
        flex-shrink: 0;
    }

    .thumbnail img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .thumbnail.active {
        border-color: var(--terracotta);
        transform: scale(1.05);
    }

    .thumbnail:hover {
        border-color: var(--terracotta);
    }

    /* Quick Info */
    .quick-info {
        background: white;
        padding: var(--space-xl);
        border-radius: var(--radius-xl);
        box-shadow: var(--shadow-soft);
        border: 1px solid var(--border-grey);
    }

    .apartment-title {
        font-size: 2rem;
        font-weight: 700;
        color: var(--text-dark);
        margin-bottom: var(--space-sm);
        line-height: 1.3;
    }

    .apartment-location {
        display: flex;
        align-items: center;
        gap: 10px;
        color: var(--text-grey);
        margin-bottom: var(--space-lg);
        font-size: 1.1rem;
    }

    .apartment-location i {
        color: var(--terracotta);
    }

    .price-section {
        background: linear-gradient(135deg, rgba(255, 111, 45, 0.1), rgba(14, 19, 48, 0.05));
        padding: var(--space-lg);
        border-radius: var(--radius-lg);
        margin-bottom: var(--space-xl);
    }

    .price-amount {
        font-size: 2.5rem;
        font-weight: 700;
        color: var(--terracotta);
        margin-bottom: 4px;
    }

    .price-label {
        color: var(--text-grey);
        font-size: 0.9rem;
    }

    /* Action Buttons */
    .action-buttons {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .btn-action {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        padding: 14px;
        border-radius: var(--radius-lg);
        font-weight: 600;
        border: none;
        cursor: pointer;
        transition: var(--transition);
        font-size: 0.95rem;
    }

    .btn-edit {
        background: linear-gradient(135deg, var(--forest-green), var(--sage-green));
        color: white;
    }

    .btn-edit:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(14, 19, 48, 0.3);
    }

    .btn-delete {
        background: linear-gradient(135deg, #ef4444, #dc2626);
        color: white;
    }

    .btn-delete:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
    }

    /* Details Sections */
    .details-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: var(--space-xl);
        margin-bottom: var(--space-2xl);
    }

    .details-card {
        background: white;
        padding: var(--space-xl);
        border-radius: var(--radius-xl);
        box-shadow: var(--shadow-soft);
        border: 1px solid var(--border-grey);
    }

    .section-title {
        font-size: 1.3rem;
        font-weight: 700;
        color: var(--text-dark);
        margin-bottom: var(--space-lg);
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .section-title i {
        color: var(--terracotta);
    }

    /* Property Details */
    .property-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: var(--space-lg);
    }

    @media (max-width: 640px) {
        .property-grid {
            grid-template-columns: 1fr;
        }
    }

    .property-item {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .property-icon {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, var(--forest-green), var(--sage-green));
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 1.2rem;
    }

    .property-text {
        flex: 1;
    }

    .property-label {
        display: block;
        font-size: 0.85rem;
        color: var(--text-grey);
        margin-bottom: 4px;
    }

    .property-value {
        display: block;
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--text-dark);
    }

    /* Features */
    .features-list {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
    }

    .feature-tag {
        background: rgba(255, 111, 45, 0.1);
        color: var(--terracotta);
        padding: 8px 16px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 500;
        border: 1px solid rgba(255, 111, 45, 0.2);
    }

    /* Landlord Info */
    .landlord-info {
        display: flex;
        align-items: center;
        gap: var(--space-lg);
        padding: var(--space-lg);
        background: linear-gradient(135deg, rgba(14, 19, 48, 0.05), rgba(23, 23, 58, 0.05));
        border-radius: var(--radius-lg);
    }

    .landlord-avatar {
        width: 80px;
        height: 80px;
        background: linear-gradient(135deg, var(--forest-green), var(--sage-green));
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 1.5rem;
        font-weight: 600;
    }

    .landlord-details {
        flex: 1;
    }

    .landlord-name {
        font-size: 1.3rem;
        font-weight: 700;
        color: var(--text-dark);
        margin-bottom: 4px;
    }

    .landlord-contact {
        color: var(--text-grey);
        font-size: 0.95rem;
        margin-bottom: 8px;
    }

    .landlord-status {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 0.8rem;
        font-weight: 500;
    }

    .status-active {
        background: #d1fae5;
        color: #065f46;
    }

    .status-inactive {
        background: #fee2e2;
        color: #991b1b;
    }

    /* Description */
    .description-content {
        line-height: 1.8;
        color: var(--text-dark);
        font-size: 1.05rem;
    }

    /* Stats */
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: var(--space-lg);
        margin-top: var(--space-2xl);
    }

    .stat-item {
        background: white;
        padding: var(--space-lg);
        border-radius: var(--radius-lg);
        text-align: center;
        box-shadow: var(--shadow-soft);
        border: 1px solid var(--border-grey);
        transition: var(--transition);
    }

    .stat-item:hover {
        transform: translateY(-5px);
        box-shadow: var(--shadow-medium);
    }

    .stat-value {
        font-size: 2rem;
        font-weight: 700;
        color: var(--terracotta);
        margin-bottom: 8px;
    }

    .stat-label {
        color: var(--text-grey);
        font-size: 0.9rem;
    }

    /* Loading State */
    .loading {
        text-align: center;
        padding: var(--space-2xl);
        color: var(--text-grey);
    }

    .loading i {
        font-size: 3rem;
        margin-bottom: var(--space-md);
        opacity: 0.5;
    }

    /* Error State */
    .error-state {
        text-align: center;
        padding: var(--space-2xl);
        color: var(--text-grey);
    }

    .error-state i {
        font-size: 4rem;
        color: #ef4444;
        margin-bottom: var(--space-lg);
        opacity: 0.7;
    }

    /* Booking History Styles */
    .booking-history-section {
        grid-column: 1 / -1;
        margin-top: var(--space-2xl);
    }

    .booking-table-container {
        overflow-x: auto;
        border-radius: var(--radius-lg);
        border: 1px solid var(--border-grey);
        box-shadow: var(--shadow-soft);
    }

    .booking-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
    }

    .booking-table th {
        background: linear-gradient(135deg, var(--forest-green), var(--sage-green));
        color: white;
        padding: var(--space-md);
        text-align: left;
        font-weight: 600;
        font-size: 0.9rem;
    }

    .booking-table td {
        padding: var(--space-md);
        border-bottom: 1px solid var(--border-grey);
        font-size: 0.9rem;
    }

    .booking-table tr {
        transition: var(--transition);
    }

    .booking-table tr:hover {
        background: rgba(255, 111, 45, 0.05);
    }

    .guest-link {
        display: flex;
        align-items: center;
        gap: var(--space-sm);
        text-decoration: none;
        color: inherit;
        transition: var(--transition);
    }

    .guest-link:hover {
        color: var(--terracotta);
    }

    .small-avatar {
        width: 36px;
        height: 36px;
        background: linear-gradient(135deg, var(--forest-green), var(--sage-green));
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 600;
        font-size: 0.85rem;
    }

    .status-badge {
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 0.75rem;
        font-weight: 600;
        display: inline-block;
    }

    .booking-stats {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: var(--space-md);
        margin-top: var(--space-xl);
        padding: var(--space-lg);
        background: linear-gradient(135deg, rgba(14, 19, 48, 0.05), rgba(23, 23, 58, 0.05));
        border-radius: var(--radius-lg);
    }

    .booking-stat-item {
        text-align: center;
    }

    .booking-stat-value {
        font-size: 1.8rem;
        font-weight: 700;
        color: var(--terracotta);
        margin-bottom: 4px;
    }

    .booking-stat-label {
        color: var(--text-grey);
        font-size: 0.85rem;
    }

    .view-booking-btn {
        background: var(--forest-green);
        color: white;
        padding: 6px 12px;
        border-radius: var(--radius-md);
        border: none;
        cursor: pointer;
        font-size: 0.85rem;
        transition: var(--transition);
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .view-booking-btn:hover {
        background: var(--terracotta);
        transform: translateY(-2px);
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
</style>

<div class="apartment-details-container">
    <!-- Back Button -->
    <div class="back-button">
        <a href="{{ url()->previous() }}" class="btn-back">
            <i class="fas fa-arrow-left"></i>
            <span>Back to Apartments</span>
        </a>
    </div>

    @if(isset($apartment) && $apartment)
        <!-- Status Badge -->
        <div class="status-badge-large status-{{ $apartment->status }}">
            <i class="fas fa-{{ $apartment->status === 'approved' ? 'check-circle' : ($apartment->status === 'pending' ? 'clock' : 'times-circle') }}"></i>
            <span>Status: {{ ucfirst($apartment->status) }}</span>
        </div>

        <!-- Main Header -->
        <div class="apartment-header">
            <!-- Image Gallery -->
            <div class="image-gallery">
                <div class="main-image" id="mainImage">
                    @if($apartment->images && !empty($apartment->images[0]))
                        <img src="{{ asset('storage/' . $apartment->images[0]) }}" 
                             alt="{{ $apartment->title }}" 
                             id="currentImage">
                    @else
                        <div style="width: 100%; height: 100%; background: linear-gradient(135deg, var(--forest-green), var(--sage-green)); display: flex; align-items: center; justify-content: center; color: white;">
                            <i class="fas fa-home" style="font-size: 4rem; opacity: 0.5;"></i>
                        </div>
                    @endif
                </div>

                @if($apartment->images && count($apartment->images) > 1)
                    <div class="image-thumbnails" id="thumbnailContainer">
                        @foreach($apartment->images as $index => $image)
                            <div class="thumbnail {{ $index === 0 ? 'active' : '' }}" 
                                 onclick="changeImage('{{ asset('storage/' . $image) }}', this)">
                                <img src="{{ asset('storage/' . $image) }}" 
                                     alt="Apartment image {{ $index + 1 }}">
                            </div>
                        @endforeach
                    </div>
                @endif
            </div>

            <!-- Quick Info & Actions -->
            <div class="quick-info">
                <h1 class="apartment-title">{{ $apartment->title }}</h1>
                
                <div class="apartment-location">
                    <i class="fas fa-map-marker-alt"></i>
                    <span>{{ $apartment->address }}, {{ $apartment->city }}, {{ $apartment->governorate }}</span>
                </div>

                <div class="price-section">
                    <div class="price-amount">${{ number_format($apartment->price_per_night, 2) }}</div>
                    <div class="price-label">Per night</div>
                </div>

                <div class="action-buttons">
                    <button class="btn-action btn-edit" onclick="editApartment({{ $apartment->id }})">
                        <i class="fas fa-edit"></i>
                        Edit Apartment
                    </button>
                    
                    <form method="POST" action="{{ route('admin.apartments.delete', $apartment->id) }}" id="deleteForm">
                        @csrf
                        @method('DELETE')
                        <button type="button" class="btn-action btn-delete" onclick="confirmDelete()">
                            <i class="fas fa-trash"></i>
                            Delete Apartment
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Details Grid -->
        <div class="details-grid">
            <!-- Property Details -->
            <div class="details-card">
                <h2 class="section-title">
                    <i class="fas fa-info-circle"></i>
                    Property Details
                </h2>
                
                <div class="property-grid">
                    <div class="property-item">
                        <div class="property-icon">
                            <i class="fas fa-bed"></i>
                        </div>
                        <div class="property-text">
                            <span class="property-label">Bedrooms</span>
                            <span class="property-value">{{ $apartment->bedrooms }}</span>
                        </div>
                    </div>
                    
                    <div class="property-item">
                        <div class="property-icon">
                            <i class="fas fa-bath"></i>
                        </div>
                        <div class="property-text">
                            <span class="property-label">Bathrooms</span>
                            <span class="property-value">{{ $apartment->bathrooms }}</span>
                        </div>
                    </div>
                    
                    <div class="property-item">
                        <div class="property-icon">
                            <i class="fas fa-expand-arrows-alt"></i>
                        </div>
                        <div class="property-text">
                            <span class="property-label">Area</span>
                            <span class="property-value">{{ $apartment->area }} m²</span>
                        </div>
                    </div>
                    
                    <div class="property-item">
                        <div class="property-icon">
                            <i class="fas fa-users"></i>
                        </div>
                        <div class="property-text">
                            <span class="property-label">Max Guests</span>
                            <span class="property-value">{{ $apartment->max_guests }}</span>
                        </div>
                    </div>
                    
                    <div class="property-item">
                        <div class="property-icon">
                            <i class="fas fa-door-open"></i>
                        </div>
                        <div class="property-text">
                            <span class="property-label">Total Rooms</span>
                            <span class="property-value">{{ $apartment->rooms }}</span>
                        </div>
                    </div>
                    
                    <div class="property-item">
                        <div class="property-icon">
                            <i class="fas fa-calendar-check"></i>
                        </div>
                        <div class="property-text">
                            <span class="property-label">Availability</span>
                            <span class="property-value">{{ $apartment->is_available ? 'Available' : 'Occupied' }}</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Features -->
            <div class="details-card">
                <h2 class="section-title">
                    <i class="fas fa-star"></i>
                    Features & Amenities
                </h2>
                
                @if($apartment->features && !empty($apartment->features))
                    <div class="features-list">
                        @foreach($apartment->features as $feature)
                            <span class="feature-tag">{{ $feature }}</span>
                        @endforeach
                    </div>
                @else
                    <p style="color: var(--text-grey); font-style: italic;">No features listed</p>
                @endif
            </div>

            <!-- Landlord Info -->
            <div class="details-card">
                <h2 class="section-title">
                    <i class="fas fa-user-tie"></i>
                    Landlord Information
                </h2>
                
                @if($apartment->landlord && $apartment->landlord->first_name)
                    <div class="landlord-info">
                        <div class="landlord-avatar">
                            {{ substr($apartment->landlord->first_name, 0, 1) }}{{ substr($apartment->landlord->last_name ?? '', 0, 1) }}
                        </div>
                        <div class="landlord-details">
                            <div class="landlord-name">
                                {{ $apartment->landlord->first_name }} {{ $apartment->landlord->last_name ?? '' }}
                            </div>
                            <div class="landlord-contact">
                                <i class="fas fa-phone"></i> {{ $apartment->landlord->phone ?? 'N/A' }}
                            </div>
                            <div class="landlord-status {{ $apartment->landlord->is_approved ? 'status-active' : 'status-inactive' }}">
                                <i class="fas fa-{{ $apartment->landlord->is_approved ? 'check-circle' : 'clock' }}"></i>
                                {{ $apartment->landlord->is_approved ? 'Verified' : 'Pending Approval' }}
                            </div>
                        </div>
                    </div>
                @else
                    <p style="color: var(--text-grey); font-style: italic;">Landlord information not available</p>
                @endif
            </div>

            <!-- Description -->
            <div class="details-card">
                <h2 class="section-title">
                    <i class="fas fa-align-left"></i>
                    Description
                </h2>
                
                <div class="description-content">
                    {{ $apartment->description ?: 'No description provided.' }}
                </div>
            </div>
        </div>

        <!-- Stats -->
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-value">{{ $apartment->reviews_count ?? 0 }}</div>
                <div class="stat-label">Total Reviews</div>
            </div>
            
            <div class="stat-item">
                <div class="stat-value">{{ $apartment->bookings_count ?? 0 }}</div>
                <div class="stat-label">Total Bookings</div>
            </div>
            
            <div class="stat-item">
                <div class="stat-value">
                    @if($apartment->reviews_count && $apartment->reviews_count > 0)
                        {{ number_format($apartment->reviews->avg('rating'), 1) }}/5
                    @else
                        N/A
                    @endif
                </div>
                <div class="stat-label">Average Rating</div>
            </div>
            
            <div class="stat-item">
                <div class="stat-value">
                    @if($apartment->created_at)
                        {{ $apartment->created_at->diffForHumans() }}
                    @else
                        N/A
                    @endif
                </div>
                <div class="stat-label">Listed</div>
            </div>
        </div>

        <!-- Booking History Section -->
        <div class="details-card booking-history-section">
            <h2 class="section-title">
                <i class="fas fa-calendar-alt"></i>
                Booking History
            </h2>
            
            @if($apartment->bookings && $apartment->bookings->count() > 0)
                <div class="booking-table-container">
                    <table class="booking-table">
                        <thead>
                            <tr>
                                <th>Guest</th>
                                <th>Check-in</th>
                                <th>Check-out</th>
                                <th>Status</th>
                                <th>Amount</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($apartment->bookings as $booking)
                                <tr>
                                    <td>
                                        @if($booking->tenant && $booking->tenant->first_name)
                                            <div class="guest-link">
                                                <div class="small-avatar">
                                                    {{ substr($booking->tenant->first_name, 0, 1) }}{{ substr($booking->tenant->last_name ?? '', 0, 1) }}
                                                </div>
                                                <div>
                                                    <div style="font-weight: 600;">{{ $booking->tenant->first_name }} {{ $booking->tenant->last_name ?? '' }}</div>
                                                    <div style="font-size: 0.8rem; color: var(--text-grey);">{{ $booking->tenant->phone ?? 'N/A' }}</div>
                                                </div>
                                            </div>
                                        @else
                                            <span style="color: var(--text-grey); font-style: italic;">Guest N/A</span>
                                        @endif
                                    </td>
                                    <td>
                                        <div style="font-weight: 500;">{{ $booking->check_in->format('Y-m-d') }}</div>
                                        <div style="font-size: 0.8rem; color: var(--text-grey);">
                                            {{ $booking->check_in->diffForHumans() }}
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 500;">{{ $booking->check_out->format('Y-m-d') }}</div>
                                        <div style="font-size: 0.8rem; color: var(--text-grey);">
                                            {{ $booking->check_out->isPast() ? 'Ended' : 'Ends ' . $booking->check_out->diffForHumans() }}
                                        </div>
                                    </td>
                                    <td>
                                        @php
                                            $statusColors = [
                                                'pending' => ['bg' => '#F59E0B20', 'color' => '#F59E0B'],
                                                'confirmed' => ['bg' => '#10B98120', 'color' => '#10B981'],
                                                'completed' => ['bg' => '#6366F120', 'color' => '#6366F1'],
                                                'cancelled' => ['bg' => '#EF444420', 'color' => '#EF4444']
                                            ];
                                            $status = $booking->status;
                                        @endphp
                                        <span class="status-badge" style="background: {{ $statusColors[$status]['bg'] ?? '#6B728020' }}; 
                                              color: {{ $statusColors[$status]['color'] ?? '#6B7280' }};">
                                            {{ ucfirst($status) }}
                                        </span>
                                    </td>
                                    <td style="font-weight: 600; color: var(--terracotta);">
                                        ${{ number_format($booking->total_price, 2) }}
                                    </td>
                                    <td>
                                        <button class="view-booking-btn" onclick="viewBookingDetails({{ $booking->id }})">
                                            <i class="fas fa-eye"></i>
                                            View
                                        </button>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
                
                <!-- Booking Stats Summary -->
                <div class="booking-stats">
                    <div class="booking-stat-item">
                        <div class="booking-stat-value">{{ $bookingStats['total'] ?? 0 }}</div>
                        <div class="booking-stat-label">Total Bookings</div>
                    </div>
                    <div class="booking-stat-item">
                        <div class="booking-stat-value">{{ $bookingStats['confirmed'] ?? 0 }}</div>
                        <div class="booking-stat-label">Active</div>
                    </div>
                    <div class="booking-stat-item">
                        <div class="booking-stat-value">{{ $bookingStats['completed'] ?? 0 }}</div>
                        <div class="booking-stat-label">Completed</div>
                    </div>
                    <div class="booking-stat-item">
                        <div class="booking-stat-value">${{ number_format($bookingStats['revenue'] ?? 0, 2) }}</div>
                        <div class="booking-stat-label">Total Revenue</div>
                    </div>
                </div>
            @else
                <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
                    <i class="fas fa-calendar-times" style="font-size: 3rem; margin-bottom: var(--space-md); opacity: 0.3;"></i>
                    <h3 style="margin-bottom: var(--space-sm);">No Booking History</h3>
                    <p>This apartment hasn't been booked yet.</p>
                </div>
            @endif
        </div>

    @else
        <!-- Error State -->
        <div class="error-state">
            <i class="fas fa-exclamation-triangle"></i>
            <h2>Apartment Not Found</h2>
            <p>The apartment you're looking for doesn't exist or has been removed.</p>
            <a href="{{ route('admin.apartments') }}" class="btn-back" style="margin-top: 20px;">
                <i class="fas fa-building"></i>
                <span>View All Apartments</span>
            </a>
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
        <div class="modal-actions" style="display: flex; gap: var(--space-md); margin-top: var(--space-xl);">
            <button class="btn-action btn-primary" onclick="closeBookingModal()" style="flex: 1; background: var(--forest-green); color: white; padding: 12px; border-radius: var(--radius-md); border: none; cursor: pointer;">Close</button>
        </div>
    </div>
</div>

<script>
    // Image Gallery Functionality
    function changeImage(imageUrl, thumbnail) {
        // Update main image
        document.getElementById('currentImage').src = imageUrl;
        
        // Update active thumbnail
        document.querySelectorAll('.thumbnail').forEach(thumb => {
            thumb.classList.remove('active');
        });
        thumbnail.classList.add('active');
    }

    // Delete Confirmation
    function confirmDelete() {
        if (confirm('Are you sure you want to delete this apartment? This action cannot be undone.')) {
            document.getElementById('deleteForm').submit();
        }
    }

    // Edit Apartment
    function editApartment(id) {
        // Redirect to edit page or show edit modal
        window.location.href = `/admin/apartments/${id}/edit`;
        // If you don't have edit page, you can show a modal
        // showEditModal(id);
    }

    // View booking details in modal
    async function viewBookingDetails(bookingId) {
        try {
            const response = await fetch(`/admin/bookings/${bookingId}/details`);
            const booking = await response.json();
            
            if (booking.error) {
                alert('Error: ' + booking.error);
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
                    <span class="detail-value">${booking.tenant?.first_name || booking.user?.first_name} ${booking.tenant?.last_name || booking.user?.last_name}</span>
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
                    <span class="detail-value" style="color: var(--terracotta); font-weight: 700;">$${parseFloat(booking.total_price).toFixed(2)}</span>
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
            
            // Show modal
            document.getElementById('bookingModal').classList.add('active');
            document.body.style.overflow = 'hidden';
            
        } catch (error) {
            console.error('Error fetching booking details:', error);
            alert('Failed to load booking details');
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

    // Initialize image gallery if there are images
    document.addEventListener('DOMContentLoaded', function() {
        const thumbnails = document.querySelectorAll('.thumbnail');
        if (thumbnails.length > 0) {
            // Add click event to all thumbnails
            thumbnails.forEach(thumb => {
                thumb.addEventListener('click', function() {
                    const imageUrl = this.querySelector('img').src;
                    changeImage(imageUrl, this);
                });
            });
        }
    });

    // Loading state when navigating
    document.addEventListener('click', function(e) {
        if (e.target.closest('.btn-view-details') || e.target.closest('.btn-back')) {
            const container = document.querySelector('.apartment-details-container');
            if (container) {
                container.style.opacity = '0.7';
                container.style.pointerEvents = 'none';
            }
        }
    });
</script>
@endsection
