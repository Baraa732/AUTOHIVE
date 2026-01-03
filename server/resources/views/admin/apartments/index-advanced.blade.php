@extends('admin.layout')

@section('title', 'Apartments Management')
@section('icon', 'fas fa-building')

@section('content')
<link rel="stylesheet" href="{{ asset('css/apartments-advanced.css') }}">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<div class="apartments-header">
    <h1 style="margin: 0 0 8px 0; font-size: 2rem; font-weight: 700;">Apartments Management</h1>
    <p style="margin: 0; opacity: 0.8;">{{ $stats['total'] }} total apartments • {{ $stats['pending'] }} pending review</p>
</div>

<!-- Stats Chart -->
<div style="background: white; border-radius: 16px; padding: 32px; margin-bottom: 32px; border: 1px solid #E5E7EB;">
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px; align-items: center;">
        <div style="height: 250px; position: relative;">
            <h2 style="margin: 0 0 16px 0; font-size: 1.3rem; color: #0e1330;">Status Distribution</h2>
            <canvas id="apartmentsChart"></canvas>
        </div>
        <div>
            <h2 style="margin: 0 0 16px 0; font-size: 1.3rem; color: #0e1330;">Quick Stats</h2>
            <div style="display: flex; flex-direction: column; gap: 12px;">
                <div style="padding: 16px; background: linear-gradient(135deg, #10B981 0%, #059669 100%); border-radius: 12px; color: white;">
                    <div style="font-size: 2rem; font-weight: 700;">{{ $stats['approved'] }}</div>
                    <div style="font-size: 0.9rem; opacity: 0.9;">Approved & Live</div>
                </div>
                <div style="padding: 16px; background: linear-gradient(135deg, #F59E0B 0%, #D97706 100%); border-radius: 12px; color: white;">
                    <div style="font-size: 2rem; font-weight: 700;">{{ $stats['pending'] }}</div>
                    <div style="font-size: 0.9rem; opacity: 0.9;">Awaiting Review</div>
                </div>
                <div style="padding: 16px; background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%); border-radius: 12px; color: white;">
                    <div style="font-size: 2rem; font-weight: 700;">{{ $stats['rejected'] }}</div>
                    <div style="font-size: 0.9rem; opacity: 0.9;">Rejected</div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Controls -->
<div class="apartments-controls">
    <div style="flex: 1; min-width: 300px;">
        <input type="text" id="searchInput" placeholder="Search apartments..." style="width: 100%; padding: 12px 16px; border: 2px solid #E5E7EB; border-radius: 10px; font-size: 0.9rem;" onkeyup="searchApartments()">
    </div>
    
    <div style="display: flex; gap: 8px;">
        <a href="?status=all" class="chip {{ $currentStatus == 'all' ? 'active' : '' }}">
            <i class="fas fa-list"></i> All
        </a>
        <a href="?status=approved" class="chip {{ $currentStatus == 'approved' ? 'active' : '' }}">
            <i class="fas fa-check"></i> Approved
        </a>
        <a href="?status=pending" class="chip {{ $currentStatus == 'pending' ? 'active' : '' }}">
            <i class="fas fa-clock"></i> Pending
        </a>
        <a href="?status=rejected" class="chip {{ $currentStatus == 'rejected' ? 'active' : '' }}">
            <i class="fas fa-times"></i> Rejected
        </a>
    </div>
</div>

<!-- Apartments Grid -->
<div class="apartments-grid">
    @foreach($apartments as $apartment)
    <div class="apartment-card" data-title="{{ strtolower($apartment->title) }}" data-location="{{ strtolower($apartment->city) }}">
        @if($apartment->image_urls && count($apartment->image_urls) > 0)
            <img src="{{ $apartment->image_urls[0] }}" alt="{{ $apartment->title }}" class="apartment-image">
        @else
            <div class="apartment-image" style="display: flex; align-items: center; justify-content: center; color: #5A6C7D;">
                <i class="fas fa-image" style="font-size: 3rem; opacity: 0.3;"></i>
            </div>
        @endif
        
        <div class="apartment-content">
            <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px;">
                <h3 class="apartment-title">{{ $apartment->title }}</h3>
                <span style="padding: 4px 12px; border-radius: 8px; font-size: 0.75rem; font-weight: 600; background: {{ $apartment->status == 'approved' ? 'rgba(16, 185, 129, 0.1)' : ($apartment->status == 'pending' ? 'rgba(245, 158, 11, 0.1)' : 'rgba(239, 68, 68, 0.1)') }}; color: {{ $apartment->status == 'approved' ? '#10B981' : ($apartment->status == 'pending' ? '#F59E0B' : '#EF4444') }};">
                    {{ ucfirst($apartment->status) }}
                </span>
            </div>
            
            <div class="apartment-location">
                <i class="fas fa-map-marker-alt"></i>
                <span>{{ $apartment->city }}, {{ $apartment->governorate }}</span>
            </div>
            
            <div class="apartment-features">
                <span><i class="fas fa-bed"></i> {{ $apartment->bedrooms }} Beds</span>
                <span><i class="fas fa-bath"></i> {{ $apartment->bathrooms }} Baths</span>
                <span><i class="fas fa-users"></i> {{ $apartment->max_guests }} Guests</span>
            </div>
            
            <div class="apartment-price">
                ${{ number_format($apartment->price_per_night, 2) }}<span style="font-size: 0.9rem; font-weight: 400; color: #5A6C7D;">/night</span>
            </div>
            
            <div class="apartment-actions">
                <a href="{{ route('admin.apartments.show', $apartment->id) }}" class="btn-view" style="text-decoration: none; text-align: center; flex: 1;">
                    <i class="fas fa-eye"></i> View
                </a>
            </div>
        </div>
    </div>
    @endforeach
</div>

<!-- Pagination -->
@if($apartments->hasPages())
<div style="margin-top: 32px;">
    {{ $apartments->links() }}
</div>
@endif

<!-- Reject Modal -->
<div id="rejectModal" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(14, 19, 48, 0.9); z-index: 9999; align-items: center; justify-content: center;">
    <div style="background: white; border-radius: 16px; max-width: 500px; width: 90%; padding: 32px;">
        <h2 style="margin: 0 0 16px 0; color: #0e1330;">Reject Apartment</h2>
        <p style="margin: 0 0 24px 0; color: #5A6C7D;">Please provide a reason for rejection:</p>
        
        <form id="rejectForm" method="POST">
            @csrf
            <textarea name="reason" required style="width: 100%; min-height: 120px; padding: 12px; border: 2px solid #E5E7EB; border-radius: 10px; font-family: inherit; resize: vertical;" placeholder="Enter rejection reason..."></textarea>
            
            <div style="display: flex; gap: 12px; margin-top: 24px;">
                <button type="button" onclick="closeRejectModal()" style="flex: 1; padding: 12px; background: #E5E7EB; color: #0e1330; border: none; border-radius: 10px; font-weight: 600; cursor: pointer;">
                    Cancel
                </button>
                <button type="submit" style="flex: 1; padding: 12px; background: #EF4444; color: white; border: none; border-radius: 10px; font-weight: 600; cursor: pointer;">
                    Reject
                </button>
            </div>
        </form>
    </div>
</div>

<style>
.chip {
    padding: 10px 16px;
    border: 2px solid #E5E7EB;
    background: white;
    color: #5A6C7D;
    border-radius: 10px;
    font-size: 0.85rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}

.chip:hover {
    border-color: #0e1330;
    color: #0e1330;
}

.chip.active {
    background: #0e1330;
    border-color: #0e1330;
    color: white;
}
</style>

<script>
function searchApartments() {
    const input = document.getElementById('searchInput').value.toLowerCase();
    const cards = document.querySelectorAll('.apartment-card');
    
    cards.forEach(card => {
        const title = card.dataset.title;
        const location = card.dataset.location;
        const match = title.includes(input) || location.includes(input);
        card.style.display = match ? 'block' : 'none';
    });
}

function showRejectModal(id, title) {
    document.getElementById('rejectModal').style.display = 'flex';
    document.getElementById('rejectForm').action = `/admin/apartments/${id}/reject`;
}

function closeRejectModal() {
    document.getElementById('rejectModal').style.display = 'none';
}

document.getElementById('rejectModal').addEventListener('click', function(e) {
    if (e.target === this) closeRejectModal();
});

// Chart
const ctx = document.getElementById('apartmentsChart').getContext('2d');
const gradient1 = ctx.createLinearGradient(0, 0, 0, 400);
gradient1.addColorStop(0, 'rgba(16, 185, 129, 0.8)');
gradient1.addColorStop(1, 'rgba(16, 185, 129, 0.2)');

const gradient2 = ctx.createLinearGradient(0, 0, 0, 400);
gradient2.addColorStop(0, 'rgba(245, 158, 11, 0.8)');
gradient2.addColorStop(1, 'rgba(245, 158, 11, 0.2)');

const gradient3 = ctx.createLinearGradient(0, 0, 0, 400);
gradient3.addColorStop(0, 'rgba(239, 68, 68, 0.8)');
gradient3.addColorStop(1, 'rgba(239, 68, 68, 0.2)');

new Chart(ctx, {
    type: 'doughnut',
    data: {
        labels: ['Approved', 'Pending', 'Rejected'],
        datasets: [{
            data: [{{ $stats['approved'] }}, {{ $stats['pending'] }}, {{ $stats['rejected'] }}],
            backgroundColor: ['#10B981', '#F59E0B', '#EF4444'],
            borderWidth: 0,
            hoverOffset: 10
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: true,
        cutout: '70%',
        plugins: {
            legend: {
                position: 'bottom',
                labels: {
                    padding: 15,
                    font: { size: 12, weight: '600' },
                    usePointStyle: true,
                    pointStyle: 'circle'
                }
            },
            tooltip: {
                backgroundColor: '#0e1330',
                padding: 16,
                cornerRadius: 10,
                titleFont: { size: 14, weight: 'bold' },
                bodyFont: { size: 13 },
                callbacks: {
                    label: function(context) {
                        const total = {{ $stats['total'] }};
                        const value = context.parsed;
                        const percentage = ((value / total) * 100).toFixed(1);
                        return context.label + ': ' + value + ' (' + percentage + '%)';
                    }
                }
            }
        }
    }
});
</script>
@endsection
