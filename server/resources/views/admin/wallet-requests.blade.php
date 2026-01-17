@extends('admin.layout')

@section('title', 'Wallet Requests')
@section('icon', 'fas fa-wallet')

@section('content')
<link rel="stylesheet" href="{{ asset('css/dashboard-advanced.css') }}">
<style>
    .wallet-requests-container {
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
    .stat-box:nth-child(4) { animation-delay: 0.4s; }

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

    .filter-bar {
        display: flex;
        gap: var(--space-md);
        margin-bottom: var(--space-lg);
        padding: var(--space-lg);
        background: var(--white);
        border-radius: var(--radius-xl);
        border: 1px solid var(--border-grey);
        align-items: center;
        flex-wrap: wrap;
    }

    .filter-btn {
        padding: 10px 20px;
        border: 2px solid var(--border-grey);
        background: var(--white);
        color: var(--text-grey);
        border-radius: var(--radius-md);
        cursor: pointer;
        transition: all 0.3s ease;
        font-weight: 500;
        text-decoration: none;
        display: inline-block;
    }

    .filter-btn:hover {
        border-color: #0e1330;
        color: #0e1330;
    }

    .filter-btn.active {
        background: #0e1330;
        border-color: #0e1330;
        color: var(--white);
    }

    .requests-table {
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
    }

    .badge {
        padding: 4px 12px;
        border-radius: var(--radius-lg);
        font-size: 0.75rem;
        font-weight: 600;
    }

    .badge-deposit {
        background: #10B98120;
        color: #10B981;
    }

    .badge-withdrawal {
        background: #F59E0B20;
        color: #F59E0B;
    }

    .badge-pending {
        background: #F59E0B20;
        color: #F59E0B;
    }

    .badge-approved {
        background: #10B98120;
        color: #10B981;
    }

    .badge-rejected {
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
        margin-right: var(--space-xs);
    }

    .btn-success {
        background: #10B981;
        color: var(--white);
    }

    .btn-success:hover {
        background: #059669;
        transform: translateY(-2px);
    }

    .btn-danger {
        background: #EF4444;
        color: var(--white);
    }

    .btn-danger:hover {
        background: #DC2626;
        transform: translateY(-2px);
    }

    .btn-info {
        background: #0e1330;
        color: var(--white);
    }

    .btn-info:hover {
        background: #ff6f2d;
        transform: translateY(-2px);
    }

    .modal-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.6);
        z-index: 10000;
        align-items: center;
        justify-content: center;
    }

    .modal-overlay.active {
        display: flex;
    }

    .modal-content {
        background: var(--white);
        border-radius: var(--radius-xl);
        padding: var(--space-2xl);
        max-width: 500px;
        width: 90%;
        box-shadow: var(--shadow-lg);
        animation: slideUp 0.3s ease;
    }

    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: var(--space-lg);
    }

    .modal-title {
        font-size: 1.2rem;
        font-weight: 700;
        color: var(--text-dark);
    }

    .modal-close {
        background: none;
        border: none;
        font-size: 1.5rem;
        color: var(--text-grey);
        cursor: pointer;
    }

    .form-group {
        margin-bottom: var(--space-md);
    }

    .form-label {
        display: block;
        margin-bottom: var(--space-sm);
        font-weight: 600;
        color: var(--text-dark);
    }

    .form-control {
        width: 100%;
        padding: 12px;
        border: 1px solid var(--border-grey);
        border-radius: var(--radius-md);
        font-size: 0.9rem;
    }

    .form-control:focus {
        outline: none;
        border-color: #0e1330;
    }

    .modal-actions {
        display: flex;
        gap: var(--space-md);
        margin-top: var(--space-lg);
    }

    .btn-secondary {
        background: var(--light-grey);
        color: var(--text-dark);
        flex: 1;
    }

    .btn-primary {
        background: #EF4444;
        color: var(--white);
        flex: 1;
    }

    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @keyframes slideInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @keyframes slideUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>

<div class="wallet-requests-container">
    <!-- Stats Row -->
    <div class="kpi-grid fade-in-up-03">
        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper" style="background: linear-gradient(135deg, #ff6f2d, #ff9b57);">
                    <i class="fas fa-wallet"></i>
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $requests->total() }}</div>
                <div class="kpi-label">Total Requests</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper" style="background: linear-gradient(135deg, #F59E0B, #D97706);">
                    <i class="fas fa-clock"></i>
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $requests->where('status', 'pending')->count() }}</div>
                <div class="kpi-label">Pending</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper" style="background: linear-gradient(135deg, #10B981, #059669);">
                    <i class="fas fa-check-circle"></i>
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $requests->where('status', 'approved')->count() }}</div>
                <div class="kpi-label">Approved</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-header">
                <div class="kpi-icon-wrapper" style="background: linear-gradient(135deg, #EF4444, #DC2626);">
                    <i class="fas fa-times-circle"></i>
                </div>
            </div>
            <div class="kpi-body">
                <div class="kpi-value">{{ $requests->where('status', 'rejected')->count() }}</div>
                <div class="kpi-label">Rejected</div>
            </div>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="filter-bar">
        <a href="{{ route('admin.wallet.requests') }}" class="filter-btn {{ request('status') == null ? 'active' : '' }}">
            All Requests
        </a>
        <a href="{{ route('admin.wallet.requests', ['status' => 'pending']) }}" class="filter-btn {{ request('status') == 'pending' ? 'active' : '' }}">
            Pending
        </a>
        <a href="{{ route('admin.wallet.requests', ['status' => 'approved']) }}" class="filter-btn {{ request('status') == 'approved' ? 'active' : '' }}">
            Approved
        </a>
        <a href="{{ route('admin.wallet.requests', ['status' => 'rejected']) }}" class="filter-btn {{ request('status') == 'rejected' ? 'active' : '' }}">
            Rejected
        </a>
    </div>

    <!-- Requests Table -->
    <div class="requests-table">
        <div class="table-header">
            <h3 class="card-title">
                <i class="fas fa-table"></i>
                Wallet Requests ({{ $requests->total() }})
            </h3>
        </div>

        @if($requests->count() > 0)
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>User</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($requests as $request)
                        <tr>
                            <td><strong>#{{ $request->id }}</strong></td>
                            <td>
                                <div class="user-info">
                                    @if($request->user->profile_image)
                                        <img src="{{ asset('storage/' . $request->user->profile_image) }}" alt="{{ $request->user->first_name }}" class="user-avatar" style="object-fit: cover;">
                                    @else
                                        <div class="user-avatar">
                                            {{ substr($request->user->first_name, 0, 1) }}{{ substr($request->user->last_name, 0, 1) }}
                                        </div>
                                    @endif
                                    <div>
                                        <div style="font-weight: 600; color: var(--text-dark);">
                                            {{ $request->user->first_name }} {{ $request->user->last_name }}
                                        </div>
                                        <div style="font-size: 0.8rem; color: var(--text-grey);">
                                            {{ $request->user->phone }}
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="badge badge-{{ $request->type }}">
                                    <i class="fas fa-{{ $request->type === 'deposit' ? 'arrow-down' : 'arrow-up' }}"></i>
                                    {{ ucfirst($request->type) }}
                                </span>
                            </td>
                            <td>
                                <div style="font-weight: 600; color: var(--text-dark);">
                                    ${{ number_format($request->amount_usd, 2) }}
                                </div>
                                <div style="font-size: 0.8rem; color: var(--text-grey);">
                                    {{ number_format($request->amount_spy) }} SPY
                                </div>
                            </td>
                            <td>
                                <span class="badge badge-{{ $request->status }}">
                                    {{ ucfirst($request->status) }}
                                </span>
                            </td>
                            <td>
                                <div style="color: var(--text-dark);">{{ $request->created_at->format('M d, Y') }}</div>
                                <div style="font-size: 0.8rem; color: var(--text-grey);">
                                    {{ $request->created_at->diffForHumans() }}
                                </div>
                            </td>
                            <td>
                                @if($request->status === 'pending')
                                    <button class="btn btn-success" onclick="approveRequest({{ $request->id }})">
                                        <i class="fas fa-check"></i> Approve
                                    </button>
                                    <button class="btn btn-danger" onclick="showRejectModal({{ $request->id }})">
                                        <i class="fas fa-times"></i> Reject
                                    </button>
                                @else
                                    <span style="color: var(--text-grey); font-size: 0.85rem;">No actions</span>
                                @endif
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>

            @if($requests->hasPages())
                <div style="padding: var(--space-lg); border-top: 1px solid var(--border-grey);">
                    {{ $requests->links() }}
                </div>
            @endif
        @else
            <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
                <i class="fas fa-wallet" style="font-size: 3rem; margin-bottom: var(--space-lg); opacity: 0.3;"></i>
                <h3 style="margin-bottom: var(--space-sm);">No Requests Found</h3>
                <p>No wallet requests match your current filter.</p>
            </div>
        @endif
    </div>
</div>

<!-- Reject Modal -->
<div class="modal-overlay" id="rejectModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title">Reject Request</h3>
            <button class="modal-close" onclick="closeRejectModal()">&times;</button>
        </div>
        <form id="rejectForm" method="POST">
            @csrf
            <div class="form-group">
                <label class="form-label">Rejection Reason</label>
                <textarea name="reason" class="form-control" rows="4" placeholder="Enter reason for rejection..." required></textarea>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeRejectModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Reject Request</button>
            </div>
        </form>
    </div>
</div>

<script>
function approveRequest(id) {
    if (confirm('Are you sure you want to approve this request?')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = `/admin/wallet-requests/${id}/approve`;
        
        const csrf = document.createElement('input');
        csrf.type = 'hidden';
        csrf.name = '_token';
        csrf.value = '{{ csrf_token() }}';
        form.appendChild(csrf);
        
        document.body.appendChild(form);
        form.submit();
    }
}

function showRejectModal(id) {
    const modal = document.getElementById('rejectModal');
    const form = document.getElementById('rejectForm');
    form.action = `/admin/wallet-requests/${id}/reject`;
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';
}

function closeRejectModal() {
    const modal = document.getElementById('rejectModal');
    modal.classList.remove('active');
    document.body.style.overflow = 'auto';
}

// Close modal when clicking outside
document.getElementById('rejectModal').addEventListener('click', function(e) {
    if (e.target === this) {
        closeRejectModal();
    }
});

// Close modal with ESC key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeRejectModal();
    }
});
</script>
@endsection
