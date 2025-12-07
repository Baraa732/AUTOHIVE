@extends('admin.layout')

@section('title', 'Apartments Management')
@section('icon', 'fas fa-building')

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
            --off-white: #fff5e6;
            --light-grey: #f6b67a;
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
        }

        /* Status badges */
        .status-badge {
            position: absolute;
            top: 15px;
            left: 15px;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            z-index: 10;
            backdrop-filter: blur(10px);
        }

        .status-pending {
            background: rgba(245, 158, 11, 0.9);
            color: white;
        }

        .status-approved {
            background: rgba(16, 185, 129, 0.9);
            color: white;
        }

        .status-rejected {
            background: rgba(239, 68, 68, 0.9);
            color: white;
        }

        /* Action buttons */
        .approval-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }

        .btn-approve {
            background: #10b981;
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all 0.3s;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-weight: 600;
        }

        .btn-approve:hover {
            background: #059669;
            transform: translateY(-2px);
        }

        .btn-reject {
            background: #ef4444;
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all 0.3s;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-weight: 600;
        }

        .btn-reject:hover {
            background: #dc2626;
            transform: translateY(-2px);
        }

        /* NEW: View Details Button (Admin Style) */
        .btn-view-details {
            display: flex;
            align-items: center;
            gap: var(--space-sm);
            padding: 12px 20px;
            background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px),
                        linear-gradient(180deg, #0e1330 0%, #17173a 100%);
            border-radius: var(--radius-md);
            border: 1px solid var(--border-grey);
            position: relative;
            overflow: hidden;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            color: white;
            font-weight: 600;
            font-size: 0.9rem;
            flex: 1;
            justify-content: center;
            min-width: 140px;
        }

        .btn-view-details::before,
        .btn-view-details::after {
            content: '';
            position: absolute;
            inset: 0;
            pointer-events: none;
            mix-blend-mode: normal;
            opacity: 1;
        }

        .btn-view-details::before {
            width: 180%;
            height: 120%;
            left: -40%;
            top: -10%;
            transform: rotate(-18deg);
            background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%);
            clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%);
            filter: drop-shadow(0 8px 20px rgba(0, 0, 0, 0.35));
        }

        .btn-view-details::after {
            width: 140%;
            height: 90%;
            right: -30%;
            bottom: -20%;
            transform: rotate(12deg);
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.03) 0%, rgba(255, 255, 255, 0.0) 40%);
            clip-path: polygon(0 0, 80% 0, 95% 100%, 0% 100%);
            mix-blend-mode: overlay;
        }

        .btn-view-details:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(14, 19, 48, 0.3);
        }

        .btn-view-details .accent-circle {
            position: absolute;
            width: 50px;
            height: 50px;
            right: -10px;
            top: 50%;
            border-radius: 50%;
            transform: translateY(-50%) rotate(-10deg);
            background: radial-gradient(circle at 30% 30%, #ff6f2d 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%);
            filter: blur(0.3px);
            mix-blend-mode: screen;
            opacity: 0.8;
            pointer-events: none;
            z-index: 1;
        }

        .btn-view-details .small-rect {
            position: absolute;
            left: 15%;
            top: 15%;
            width: 10px;
            height: 10px;
            border-radius: 2px;
            background: linear-gradient(180deg, #ff6f2d 0%, #ff9b57 100%);
            box-shadow: 0 3px 8px rgba(255, 110, 55, 0.12), inset 0 -1px 3px rgba(0, 0, 0, 0.15);
            transform: rotate(-12deg);
            pointer-events: none;
            z-index: 1;
        }

        .btn-view-details .dots {
            position: absolute;
            right: 10px;
            top: 20%;
            display: grid;
            grid-template-columns: repeat(2, 2px);
            gap: 2px;
            transform: rotate(-8deg);
            opacity: 0.7;
            pointer-events: none;
            z-index: 1;
        }

        .btn-view-details .dots span {
            width: 2px;
            height: 2px;
            border-radius: 1px;
            background: linear-gradient(180deg, #fff5e6, rgba(255, 255, 255, 0.7));
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.25);
            display: block;
        }

        .btn-view-details i {
            position: relative;
            z-index: 2;
            font-size: 0.9rem;
        }

        .btn-view-details span {
            position: relative;
            z-index: 2;
        }

        /* Delete Button */
        .btn-delete {
            background: #EF4444;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all 0.3s;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-weight: 600;
            min-width: 140px;
        }

        .btn-delete:hover {
            background: #dc2626;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }

        /* Modal */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: white;
            padding: 30px;
            border-radius: 10px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .modal-content textarea {
            width: 100%;
            min-height: 120px;
            margin: 15px 0;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-family: inherit;
            resize: vertical;
        }

        /* Apartments Container */
        .apartments-container {
            animation: fadeInUp 0.6s ease;
        }

        .apartments-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: var(--space-lg);
            margin-bottom: var(--space-2xl);
        }

        .apartment-card {
            background: var(--white);
            border-radius: var(--radius-xl);
            overflow: hidden;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--border-grey);
            transition: var(--transition);
            animation: slideInUp 0.5s ease forwards;
            opacity: 0;
            position: relative;
        }

        .apartment-card:nth-child(1) { animation-delay: 0.1s; }
        .apartment-card:nth-child(2) { animation-delay: 0.2s; }
        .apartment-card:nth-child(3) { animation-delay: 0.3s; }
        .apartment-card:nth-child(4) { animation-delay: 0.4s; }

        .apartment-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0, 63, 63, 0.15);
        }

        .apartment-image {
            height: 200px;
            background-size: cover;
            background-position: center;
            position: relative;
            overflow: hidden;
        }

        .apartment-image::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(to bottom, transparent 50%, rgba(0, 0, 0, 0.1));
        }

        .apartment-image i {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 3rem;
            color: var(--white);
            opacity: 0.8;
        }

        .availability-status {
            position: absolute;
            top: var(--space-md);
            right: var(--space-md);
            padding: 4px 12px;
            border-radius: var(--radius-lg);
            font-size: 0.75rem;
            font-weight: 600;
            backdrop-filter: blur(10px);
        }

        .status-available {
            background: rgba(16, 185, 129, 0.9);
            color: var(--white);
        }

        .status-occupied {
            background: rgba(239, 68, 68, 0.9);
            color: var(--white);
        }

        .apartment-content {
            padding: var(--space-lg);
        }

        .apartment-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: var(--space-sm);
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .apartment-location {
            color: var(--text-grey);
            font-size: 0.9rem;
            margin-bottom: var(--space-md);
            display: flex;
            align-items: center;
            gap: var(--space-xs);
        }

        .apartment-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--space-md);
            margin-bottom: var(--space-lg);
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: var(--space-xs);
            font-size: 0.85rem;
            color: var(--text-grey);
        }

        .detail-item i {
            color: var(--terracotta);
            width: 16px;
        }

        .apartment-price {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--terracotta);
            margin-bottom: var(--space-md);
        }

        .apartment-actions {
            display: flex;
            gap: var(--space-sm);
            align-items: center;
        }

        /* Stats */
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--space-lg);
            margin-bottom: var(--space-2xl);
        }

        .stat-card-3d {
            background: var(--white);
            padding: var(--space-lg);
            border-radius: var(--radius-xl);
            border: 1px solid var(--border-grey);
            position: relative;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            animation: slideInUp 0.5s ease forwards;
            opacity: 0;
        }

        .stat-card-3d:nth-child(1) { animation-delay: 0.1s; }
        .stat-card-3d:nth-child(2) { animation-delay: 0.2s; }
        .stat-card-3d:nth-child(3) { animation-delay: 0.3s; }
        .stat-card-3d:nth-child(4) { animation-delay: 0.4s; }

        .stat-card-3d:hover {
            transform: translateY(-5px);
        }

        /* Status tabs */
        .status-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-grey);
            overflow-x: auto;
        }

        .status-tab {
            padding: 8px 20px;
            border-radius: 20px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            white-space: nowrap;
            transition: all 0.3s;
        }

        .status-tab.active {
            transform: translateY(-2px);
        }

        .status-tab-all {
            background: #f3f4f6;
            color: #374151;
        }

        .status-tab-all.active {
            background: var(--forest-green);
            color: white;
        }

        .status-tab-pending {
            background: #fef3c7;
            color: #92400e;
        }

        .status-tab-pending.active {
            background: #f59e0b;
            color: white;
        }

        .status-tab-approved {
            background: #d1fae5;
            color: #065f46;
        }

        .status-tab-approved.active {
            background: #10b981;
            color: white;
        }

        .status-tab-rejected {
            background: #fee2e2;
            color: #991b1b;
        }

        .status-tab-rejected.active {
            background: #ef4444;
            color: white;
        }

        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
        }
    </style>

    <div class="apartments-container">
        <!-- Status Filter Tabs -->
        <div class="status-tabs">
            <a href="?status=all" class="status-tab status-tab-all {{ request('status', 'all') == 'all' ? 'active' : '' }}">
                All ({{ $stats['total'] ?? 0 }})
            </a>
            <a href="?status=pending" class="status-tab status-tab-pending {{ request('status') == 'pending' ? 'active' : '' }}">
                Pending ({{ $stats['pending'] ?? 0 }})
            </a>
            <a href="?status=approved" class="status-tab status-tab-approved {{ request('status') == 'approved' ? 'active' : '' }}">
                Approved ({{ $stats['approved'] ?? 0 }})
            </a>
            <a href="?status=rejected" class="status-tab status-tab-rejected {{ request('status') == 'rejected' ? 'active' : '' }}">
                Rejected ({{ $stats['rejected'] ?? 0 }})
            </a>
        </div>

        <!-- Stats Overview -->
        <div class="stats-overview">
            <div class="stat-card-3d">
                <div class="stat-icon">
                    <i class="fas fa-building"></i>
                </div>
                <div class="stat-number">{{ $stats['total'] ?? 0 }}</div>
                <div class="stat-label">Total Apartments</div>
            </div>
            <div class="stat-card-3d">
                <div class="stat-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-number">{{ $apartments->where('is_available', true)->count() }}</div>
                <div class="stat-label">Available</div>
            </div>
            <div class="stat-card-3d">
                <div class="stat-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="stat-number">{{ $stats['pending'] ?? 0 }}</div>
                <div class="stat-label">Pending Review</div>
            </div>
            <div class="stat-card-3d">
                <div class="stat-icon">
                    <i class="fas fa-dollar-sign"></i>
                </div>
                <div class="stat-number">${{ number_format($apartments->avg('price_per_night'), 0) }}</div>
                <div class="stat-label">Avg. Price</div>
            </div>
        </div>

        <!-- Apartments Grid -->
        @if($apartments->count() > 0)
            <div class="apartments-grid">
                @foreach($apartments as $apartment)
                    <div class="apartment-card">
                        <!-- Approval Status Badge -->
                        <div class="status-badge status-{{ $apartment->status }}">
                            {{ ucfirst($apartment->status) }}
                        </div>

                        <!-- Apartment Image -->
                        <div class="apartment-image" 
                            @if($apartment->images && !empty($apartment->images[0]))
                                style="background-image: url('{{ asset("storage/{$apartment->images[0]}") }}');"
                            @else
                                style="background: linear-gradient(135deg, var(--forest-green), var(--sage-green));"
                            @endif>
                            @if(!$apartment->images || empty($apartment->images[0]))
                                <i class="fas fa-home"></i>
                            @endif
                            <div class="availability-status {{ $apartment->is_available ? 'status-available' : 'status-occupied' }}">
                                {{ $apartment->is_available ? 'Available' : 'Occupied' }}
                            </div>
                        </div>

                        <div class="apartment-content">
                            <h3 class="apartment-title">{{ $apartment->title }}</h3>

                            <div class="apartment-location">
                                <i class="fas fa-map-marker-alt"></i>
                                {{ $apartment->city }}, {{ $apartment->governorate }}
                            </div>

                            <div class="apartment-details">
                                <div class="detail-item">
                                    <i class="fas fa-bed"></i>
                                    {{ $apartment->bedrooms }} Bedrooms
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-bath"></i>
                                    {{ $apartment->bathrooms }} Bathrooms
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-expand-arrows-alt"></i>
                                    {{ $apartment->area }} m²
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-users"></i>
                                    {{ $apartment->max_guests }} Guests
                                </div>
                            </div>

                            <div class="apartment-price">
                                ${{ number_format($apartment->price_per_night, 2) }}/night
                            </div>

                            <!-- Approval Actions for Pending Apartments -->
                            @if($apartment->status === 'pending')
                                <div class="approval-actions">
                                    <form method="POST" action="{{ route('admin.apartments.approve', $apartment->id) }}" style="flex: 1;">
                                        @csrf
                                        <button type="submit" class="btn-approve" onclick="return confirm('Approve this apartment?')">
                                            <i class="fas fa-check"></i> Approve
                                        </button>
                                    </form>

                                    <button type="button" class="btn-reject" onclick="showRejectModal({{ $apartment->id }}, '{{ addslashes($apartment->title) }}')">
                                        <i class="fas fa-times"></i> Reject
                                    </button>
                                </div>
                            @else
                                <div class="apartment-actions">
                                    <!-- NEW: Styled View Details Button -->
                                    <button type="button" class="btn-view-details" onclick="viewApartment({{ $apartment->id }})">
                                        <div class="accent-circle"></div>
                                        <div class="small-rect"></div>
                                        <div class="dots">
                                            <span></span>
                                            <span></span>
                                            <span></span>
                                            <span></span>
                                        </div>
                                        <i class="fas fa-eye"></i>
                                        <span>View Details</span>
                                    </button>

                                    <!-- Delete Button -->
                                    <form method="POST" action="{{ route('admin.apartments.delete', $apartment->id) }}" style="flex: 1;" id="deleteApartmentForm{{ $apartment->id }}">
                                        @csrf
                                        @method('DELETE')
                                        <button type="button" class="btn-delete" onclick="confirmDelete(document.getElementById('deleteApartmentForm{{ $apartment->id }}'), 'Apartment {{ $apartment->title }}')">
                                            <i class="fas fa-trash"></i>
                                            Delete
                                        </button>
                                    </form>
                                </div>
                            @endif
                        </div>
                    </div>
                @endforeach
            </div>

            @if($apartments->hasPages())
                <div style="display: flex; justify-content: center; margin-top: var(--space-2xl);">
                    {{ $apartments->links() }}
                </div>
            @endif
        @else
            <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey); animation: fadeInUp 0.6s ease;">
                <i class="fas fa-building" style="font-size: 4rem; margin-bottom: var(--space-lg); opacity: 0.3;"></i>
                <h3 style="margin-bottom: var(--space-sm); font-size: 1.5rem;">No Apartments Found</h3>
                <p style="font-size: 1rem;">No apartments match your filter criteria.</p>
            </div>
        @endif
    </div>

    <!-- Reject Modal -->
    <div class="modal-overlay" id="rejectModal">
        <div class="modal-content">
            <h3 style="margin-bottom: 15px;">Reject Apartment</h3>
            <p>Please provide a reason for rejecting <strong id="apartmentTitle"></strong>:</p>
            <textarea id="rejectReason" placeholder="Enter reason for rejection..."></textarea>
            <div style="display: flex; gap: 10px; justify-content: flex-end;">
                <button onclick="hideRejectModal()" style="padding: 10px 20px; background: #6b7280; color: white; border: none; border-radius: 6px; cursor: pointer;">
                    Cancel
                </button>
                <button onclick="submitRejection()" style="padding: 10px 20px; background: #ef4444; color: white; border: none; border-radius: 6px; cursor: pointer;">
                    Submit Rejection
                </button>
            </div>
        </div>
    </div>

    <script>
        let currentApartmentId = null;
        let currentApartmentTitle = '';

        function showRejectModal(id, title) {
            currentApartmentId = id;
            currentApartmentTitle = title;
            document.getElementById('apartmentTitle').textContent = title;
            document.getElementById('rejectModal').style.display = 'flex';
            document.getElementById('rejectReason').value = '';
        }

        function hideRejectModal() {
            document.getElementById('rejectModal').style.display = 'none';
            currentApartmentId = null;
            currentApartmentTitle = '';
        }

        function submitRejection() {
            const reason = document.getElementById('rejectReason').value.trim();
            if (!reason) {
                alert('Please enter a reason for rejection.');
                return;
            }

            const form = document.createElement('form');
            form.method = 'POST';
            form.action = `/admin/apartments/${currentApartmentId}/reject`;

            const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
            const csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = '_token';
            csrfInput.value = csrfToken;

            const reasonInput = document.createElement('input');
            reasonInput.type = 'hidden';
            reasonInput.name = 'reason';
            reasonInput.value = reason;

            form.appendChild(csrfInput);
            form.appendChild(reasonInput);
            document.body.appendChild(form);
            form.submit();
        }

        function viewApartment(id) {
            // Redirect to apartment details page
            window.location.href = `/admin/apartments/${id}`;
        }

        function confirmDelete(form, name) {
            if (confirm(`Are you sure you want to delete "${name}"? This action cannot be undone.`)) {
                form.submit();
            }
        }

        // Close modal on outside click
        document.getElementById('rejectModal').addEventListener('click', function (e) {
            if (e.target === this) {
                hideRejectModal();
            }
        });

        // Close modal on Escape key
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                hideRejectModal();
            }
        });

        // Add scroll animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.animation = 'slideInUp 0.6s ease forwards';
                }
            });
        }, observerOptions);

        document.addEventListener('DOMContentLoaded', () => {
            const cards = document.querySelectorAll('.apartment-card');
            cards.forEach(card => observer.observe(card));
        });
    </script>
@endsection
