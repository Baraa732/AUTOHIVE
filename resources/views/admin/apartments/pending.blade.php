@extends('admin.layout')

@section('title', 'Pending Apartments')
@section('icon', 'fas fa-clock')

@section('content')
<div class="content-card">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-clock"></i>
            Pending Apartment Approvals
        </h3>
    </div>
    
    <div id="pending-apartments">
        <div style="padding: var(--space-lg); text-align: center;">
            <i class="fas fa-spinner fa-spin" style="font-size: 2rem; color: var(--deep-green);"></i>
            <p style="margin-top: var(--space-md);">Loading pending apartments...</p>
        </div>
    </div>
</div>

<script>
let pendingApartments = [];

async function loadPendingApartments() {
    try {
        const response = await fetch('/api/admin/pending-apartments', {
            headers: {
                'Authorization': 'Bearer ' + localStorage.getItem('admin_token'),
                'Accept': 'application/json'
            }
        });
        
        const data = await response.json();
        
        if (data.success) {
            pendingApartments = data.data.data;
            renderPendingApartments();
        }
    } catch (error) {
        console.error('Error loading apartments:', error);
    }
}

function renderPendingApartments() {
    const container = document.getElementById('pending-apartments');
    
    if (pendingApartments.length === 0) {
        container.innerHTML = `
            <div style="padding: var(--space-2xl); text-align: center;">
                <i class="fas fa-check-circle" style="font-size: 3rem; color: var(--deep-green); margin-bottom: var(--space-md);"></i>
                <h3 style="margin-bottom: var(--space-sm);">All Caught Up!</h3>
                <p style="color: var(--text-grey);">No pending apartment approvals at the moment.</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = pendingApartments.map(apartment => `
        <div class="apartment-card" style="border-bottom: 1px solid var(--border-grey); padding: var(--space-lg);">
            <div style="display: flex; gap: var(--space-lg); align-items: start;">
                <div style="flex: 1;">
                    <h4 style="margin: 0 0 var(--space-sm) 0; color: var(--text-dark);">${apartment.title}</h4>
                    <p style="margin: 0 0 var(--space-sm) 0; color: var(--text-grey);">${apartment.description}</p>
                    <div style="display: flex; gap: var(--space-md); margin-bottom: var(--space-sm);">
                        <span style="color: var(--text-grey);"><i class="fas fa-map-marker-alt"></i> ${apartment.city}, ${apartment.governorate}</span>
                        <span style="color: var(--deep-green); font-weight: 600;">$${apartment.price_per_night}/night</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: var(--space-sm);">
                        <div style="width: 30px; height: 30px; background: var(--deep-green); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 0.8rem; font-weight: 600;">
                            ${apartment.landlord.first_name.charAt(0)}${apartment.landlord.last_name.charAt(0)}
                        </div>
                        <span style="color: var(--text-grey);">${apartment.landlord.first_name} ${apartment.landlord.last_name}</span>
                        <span style="color: var(--text-grey);">• ${apartment.landlord.phone}</span>
                    </div>
                </div>
                <div style="display: flex; gap: var(--space-sm);">
                    <button onclick="viewApartmentDetails(${apartment.id})" style="background: var(--deep-green); color: white; border: none; padding: 8px 16px; border-radius: var(--radius-sm); cursor: pointer;">
                        <i class="fas fa-eye"></i> View
                    </button>
                    <button onclick="approveApartment(${apartment.id})" style="background: #10B981; color: white; border: none; padding: 8px 16px; border-radius: var(--radius-sm); cursor: pointer;">
                        <i class="fas fa-check"></i> Approve
                    </button>
                    <button onclick="showRejectModal(${apartment.id}, '${apartment.title}')" style="background: #EF4444; color: white; border: none; padding: 8px 16px; border-radius: var(--radius-sm); cursor: pointer;">
                        <i class="fas fa-times"></i> Reject
                    </button>
                </div>
            </div>
        </div>
    `).join('');
}

async function approveApartment(apartmentId) {
    if (!confirm('Are you sure you want to approve this apartment?')) return;
    
    try {
        const response = await fetch(`/api/admin/approve-apartment/${apartmentId}`, {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + localStorage.getItem('admin_token'),
                'Accept': 'application/json'
            }
        });
        
        const data = await response.json();
        
        if (data.success) {
            showMessage('Apartment approved successfully!', 'success');
            loadPendingApartments();
        }
    } catch (error) {
        showMessage('Failed to approve apartment', 'error');
    }
}

function showRejectModal(apartmentId, title) {
    const reason = prompt(`Why are you rejecting "${title}"?`);
    if (reason) {
        rejectApartment(apartmentId, reason);
    }
}

async function rejectApartment(apartmentId, reason) {
    try {
        const response = await fetch(`/api/admin/reject-apartment/${apartmentId}`, {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + localStorage.getItem('admin_token'),
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({ reason })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showMessage('Apartment rejected successfully!', 'success');
            loadPendingApartments();
        }
    } catch (error) {
        showMessage('Failed to reject apartment', 'error');
    }
}

function showMessage(message, type) {
    const msg = document.createElement('div');
    msg.style.cssText = `position: fixed; top: 20px; right: 20px; padding: 15px 20px; border-radius: 8px; color: white; z-index: 1001; font-weight: 500; background: ${type === 'success' ? '#10B981' : '#EF4444'};`;
    msg.textContent = message;
    document.body.appendChild(msg);
    setTimeout(() => msg.remove(), 3000);
}

// Load apartments on page load
loadPendingApartments();
</script>
@endsection