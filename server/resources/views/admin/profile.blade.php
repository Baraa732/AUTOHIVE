@extends('admin.layout')

@section('title', 'Profile')
@section('icon', 'fas fa-user-circle')

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
}

.profile-card {
    background: var(--white);
    border-radius: 20px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    border: 1px solid var(--border-grey);
}

.profile-header {
    background: 
        repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px),
        linear-gradient(135deg, var(--forest-green) 0%, var(--sage-green) 100%);
    color: var(--white);
    padding: 32px;
    text-align: center;
    position: relative;
    overflow: hidden;
}

.profile-header::before,
.profile-header::after {
    content: '';
    position: absolute;
    inset: 0;
    pointer-events: none;
    mix-blend-mode: normal;
    opacity: 1;
}

.profile-header::before {
    width: 180%;
    height: 120%;
    left: -40%;
    top: -10%;
    transform: rotate(-18deg);
    background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%);
    clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%);
    filter: drop-shadow(0 8px 20px rgba(0, 0, 0, 0.35));
}

.profile-header::after {
    width: 140%;
    height: 90%;
    right: -30%;
    bottom: -20%;
    transform: rotate(12deg);
    background: linear-gradient(180deg, rgba(255, 255, 255, 0.03) 0%, rgba(255, 255, 255, 0.0) 40%);
    clip-path: polygon(0 0, 80% 0, 95% 100%, 0% 100%);
    mix-blend-mode: overlay;
}

.profile-header-accent-circle {
    position: absolute;
    width: 120px;
    height: 120px;
    right: -30px;
    top: 40%;
    border-radius: 50%;
    transform: translateY(-50%) rotate(-10deg);
    background: radial-gradient(circle at 30% 30%, #ff6f2d 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%);
    filter: blur(0.6px);
    mix-blend-mode: screen;
    opacity: 0.98;
    pointer-events: none;
    z-index: 1;
}

.profile-header-small-rect {
    position: absolute;
    left: 15%;
    top: 15%;
    width: 20px;
    height: 20px;
    border-radius: 4px;
    background: linear-gradient(180deg, #ff6f2d 0%, #ff9b57 100%);
    box-shadow: 0 4px 12px rgba(255, 110, 55, 0.12), inset 0 -2px 4px rgba(0, 0, 0, 0.15);
    transform: rotate(-12deg);
    pointer-events: none;
    z-index: 1;
}

.profile-header-dots {
    position: absolute;
    right: 15px;
    top: 20%;
    display: grid;
    grid-template-columns: repeat(3, 4px);
    gap: 6px;
    transform: rotate(-8deg);
    opacity: 0.95;
    pointer-events: none;
    z-index: 1;
}

.profile-header-dots span {
    width: 4px;
    height: 4px;
    border-radius: 1px;
    background: linear-gradient(180deg, #fff5e6, rgba(255, 255, 255, 0.7));
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.25);
    display: block;
}

.profile-avatar {
    width: 100px;
    height: 100px;
    background: linear-gradient(135deg, var(--terracotta), #ff9b57);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 16px;
    font-size: 2.5rem;
    color: var(--white);
    font-weight: 700;
    box-shadow: 0 8px 20px rgba(255, 111, 45, 0.3);
    position: relative;
    z-index: 1;
}

.profile-name {
    font-size: 1.5rem;
    font-weight: 700;
    margin-bottom: 8px;
    color: white;
    position: relative;
    z-index: 2;
}

.profile-role {
    opacity: 0.9;
    font-size: 1rem;
    color: rgba(255, 255, 255, 0.9);
    position: relative;
    z-index: 2;
}

.profile-content {
    padding: 40px;
}

.section-title {
    color: var(--forest-green);
    font-size: 1.2rem;
    font-weight: 700;
    margin-bottom: 24px;
    display: flex;
    align-items: center;
    gap: 12px;
    padding-bottom: 12px;
    border-bottom: 2px solid var(--cream-light);
}

.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    margin-bottom: 32px;
}

.form-group {
    margin-bottom: 24px;
}

.form-label {
    display: block;
    font-weight: 600;
    color: var(--text-dark);
    margin-bottom: 8px;
    font-size: 0.9rem;
}

.form-input {
    width: 100%;
    padding: 14px 16px;
    border: 2px solid var(--border-grey);
    border-radius: 12px;
    font-size: 0.95rem;
    transition: all 0.3s ease;
    background: var(--white);
}

.form-input:focus {
    outline: none;
    border-color: var(--forest-green);
    box-shadow: 0 0 0 3px rgba(14, 19, 48, 0.1);
}

.birth-date-display {
    background: var(--cream-light);
    padding: 14px 16px;
    border-radius: 12px;
    border: 2px solid var(--border-grey);
    color: var(--text-dark);
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 8px;
}

.section-divider {
    border-top: 1px solid var(--border-grey);
    margin: 32px 0;
    padding-top: 32px;
}

.update-btn {
    background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px), linear-gradient(135deg, var(--forest-green) 0%, var(--sage-green) 100%);
    color: white !important;
    border: none;
    padding: 14px 28px;
    border-radius: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.95rem;
    box-shadow: 0 4px 12px rgba(14, 19, 48, 0.3);
    position: relative;
    overflow: hidden;
}

.update-btn::before {
    content: '';
    position: absolute;
    width: 180%;
    height: 120%;
    left: -40%;
    top: -10%;
    transform: rotate(-18deg);
    background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%);
    clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%);
    pointer-events: none;
    z-index: 1;
}

.update-btn::after {
    content: '';
    position: absolute;
    width: 25px;
    height: 25px;
    right: 10px;
    top: 30%;
    border-radius: 50%;
    background: radial-gradient(circle at 30% 30%, #ff6f2d 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%);
    opacity: 0.7;
    pointer-events: none;
}

.update-btn i,
.update-btn span {
    position: relative;
    z-index: 2;
    color: white !important;
}

.update-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(14, 19, 48, 0.4);
}

.error-message {
    color: #EF4444;
    font-size: 0.8rem;
    margin-top: 6px;
    display: flex;
    align-items: center;
    gap: 4px;
}

.success-message {
    background: #F0FDF4;
    color: #059669;
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 8px;
    border: 1px solid #BBF7D0;
}

@media (max-width: 768px) {
    .form-grid {
        grid-template-columns: 1fr;
    }
    .profile-content {
        padding: 24px;
    }
}
</style>

@if(session('success'))
    <div class="success-message">
        <i class="fas fa-check-circle"></i>
        {{ session('success') }}
    </div>
@endif

<div class="profile-card">
    <div class="profile-header">
        <div class="profile-avatar" style="position: relative; overflow: hidden;">
            @if($admin->profile_image)
                <img src="{{ $admin->profile_image_url }}" alt="Profile" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">
            @else
                {{ substr($admin->first_name, 0, 1) }}{{ substr($admin->last_name, 0, 1) }}
            @endif
        </div>
        <h2 class="profile-name">{{ $admin->first_name }} {{ $admin->last_name }}</h2>
        <p class="profile-role">System Administrator</p>
        
        <!-- Geometric elements -->
        <div class="profile-header-accent-circle" aria-hidden="true"></div>
        <div class="profile-header-small-rect" aria-hidden="true"></div>
        <div class="profile-header-dots" aria-hidden="true">
            <span></span><span></span><span></span>
            <span></span><span></span><span></span>
            <span></span><span></span><span></span>
        </div>
    </div>
    
    <div class="profile-content">
        <form method="POST" action="{{ route('admin.profile.update') }}" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            
            <!-- Profile Image Section -->
            <h3 class="section-title">
                <i class="fas fa-camera"></i>
                Profile Image
            </h3>
            
            <div class="form-group" style="margin-bottom: 32px;">
                <div style="display: flex; align-items: center; gap: 24px;">
                    <div class="current-avatar" style="width: 80px; height: 80px; border-radius: 50%; overflow: hidden; border: 3px solid var(--border-grey); position: relative;">
                        @if($admin->profile_image)
                            <img src="{{ $admin->profile_image_url }}" alt="Current Profile" style="width: 100%; height: 100%; object-fit: cover;">
                        @else
                            <div style="width: 100%; height: 100%; background: linear-gradient(135deg, var(--terracotta), #ff9b57); display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 1.5rem;">
                                {{ substr($admin->first_name, 0, 1) }}{{ substr($admin->last_name, 0, 1) }}
                            </div>
                        @endif
                    </div>
                    
                    <div style="flex: 1;">
                        <label class="form-label">Upload New Image</label>
                        <div class="custom-file-upload" style="position: relative; display: inline-block; width: 100%;">
                            <input type="file" name="profile_image" accept="image/*" id="profileImageInput" onchange="previewImage(this)" style="position: absolute; opacity: 0; width: 100%; height: 100%; cursor: pointer; z-index: 2;">
                            <div style="background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px), linear-gradient(135deg, var(--forest-green) 0%, var(--sage-green) 100%); color: white; padding: 14px 20px; border-radius: 12px; cursor: pointer; transition: all 0.3s ease; display: flex; align-items: center; gap: 12px; font-weight: 500; border: 2px solid transparent; position: relative; overflow: hidden;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 20px rgba(14, 19, 48, 0.3)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(14, 19, 48, 0.2)'">
                                <!-- Geometric elements -->
                                <div style="position: absolute; width: 180%; height: 120%; left: -40%; top: -10%; transform: rotate(-18deg); background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%); clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%); pointer-events: none;"></div>
                                <div style="position: absolute; width: 30px; height: 30px; right: -5px; top: 20%; border-radius: 50%; background: radial-gradient(circle at 30% 30%, #ff6f2d 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%); opacity: 0.8; pointer-events: none;"></div>
                                <div style="position: absolute; left: 10%; top: 10%; width: 8px; height: 8px; border-radius: 2px; background: linear-gradient(180deg, #ff6f2d 0%, #ff9b57 100%); transform: rotate(-12deg); pointer-events: none;"></div>
                                <i class="fas fa-camera" style="font-size: 1.1rem; position: relative; z-index: 2;"></i>
                                <span id="fileLabel" style="position: relative; z-index: 2;">Choose Image File</span>
                                <i class="fas fa-upload" style="margin-left: auto; opacity: 0.8; position: relative; z-index: 2;"></i>
                            </div>
                        </div>
                        <p style="color: var(--text-grey); font-size: 0.8rem; margin-top: 4px;">
                            <i class="fas fa-info-circle"></i>
                            Supported formats: JPEG, PNG, JPG, GIF. Max size: 2MB
                        </p>
                        @if($admin->profile_image)
                            <button type="button" onclick="deleteProfileImage()" style="background: #EF4444; color: white; border: none; padding: 8px 16px; border-radius: 8px; font-size: 0.8rem; margin-top: 8px; cursor: pointer; transition: all 0.3s ease;" onmouseover="this.style.background='#DC2626'" onmouseout="this.style.background='#EF4444'">
                                <i class="fas fa-trash"></i> Remove Current Image
                            </button>
                        @endif
                        @error('profile_image')
                            <div class="error-message">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </div>
                        @enderror
                    </div>
                </div>
            </div>
            
            <!-- Personal Information -->
            <h3 class="section-title">
                <i class="fas fa-user"></i>
                Personal Information
            </h3>
            
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">First Name</label>
                    <input type="text" name="first_name" value="{{ old('first_name', $admin->first_name) }}" class="form-input">
                    @error('first_name')
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>
                
                <div class="form-group">
                    <label class="form-label">Last Name</label>
                    <input type="text" name="last_name" value="{{ old('last_name', $admin->last_name) }}" class="form-input">
                    @error('last_name')
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>
            </div>
            
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <input type="text" name="phone" value="{{ old('phone', $admin->phone) }}" class="form-input">
                    @error('phone')
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>
                
                <div class="form-group">
                    <label class="form-label">Birth Date</label>
                    <div style="display: grid; grid-template-columns: 1fr 2fr 1fr; gap: 12px;">
                        @php
                            $birthDate = $admin->birth_date ? \Carbon\Carbon::parse($admin->birth_date) : null;
                            $currentDay = old('birth_day', $birthDate ? $birthDate->day : '');
                            $currentMonth = old('birth_month', $birthDate ? $birthDate->month : '');
                            $currentYear = old('birth_year', $birthDate ? $birthDate->year : '');
                        @endphp
                        
                        <!-- Day -->
                        <div style="position: relative;">
                            <select name="birth_day" class="birth-select" style="width: 100%; padding: 14px 12px; border: 2px solid var(--border-grey); border-radius: 12px; font-size: 0.95rem; transition: all 0.3s ease; background: var(--white); color: var(--text-dark); appearance: none; cursor: pointer;">
                                <option value="">Day</option>
                                @for($i = 1; $i <= 31; $i++)
                                    <option value="{{ $i }}" {{ $currentDay == $i ? 'selected' : '' }}>{{ $i }}</option>
                                @endfor
                            </select>
                            <i class="fas fa-chevron-down" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--text-grey); pointer-events: none; font-size: 0.8rem;"></i>
                        </div>
                        
                        <!-- Month -->
                        <div style="position: relative;">
                            <select name="birth_month" class="birth-select" style="width: 100%; padding: 14px 12px; border: 2px solid var(--border-grey); border-radius: 12px; font-size: 0.95rem; transition: all 0.3s ease; background: var(--white); color: var(--text-dark); appearance: none; cursor: pointer;">
                                <option value="">Month</option>
                                <option value="1" {{ $currentMonth == 1 ? 'selected' : '' }}>January</option>
                                <option value="2" {{ $currentMonth == 2 ? 'selected' : '' }}>February</option>
                                <option value="3" {{ $currentMonth == 3 ? 'selected' : '' }}>March</option>
                                <option value="4" {{ $currentMonth == 4 ? 'selected' : '' }}>April</option>
                                <option value="5" {{ $currentMonth == 5 ? 'selected' : '' }}>May</option>
                                <option value="6" {{ $currentMonth == 6 ? 'selected' : '' }}>June</option>
                                <option value="7" {{ $currentMonth == 7 ? 'selected' : '' }}>July</option>
                                <option value="8" {{ $currentMonth == 8 ? 'selected' : '' }}>August</option>
                                <option value="9" {{ $currentMonth == 9 ? 'selected' : '' }}>September</option>
                                <option value="10" {{ $currentMonth == 10 ? 'selected' : '' }}>October</option>
                                <option value="11" {{ $currentMonth == 11 ? 'selected' : '' }}>November</option>
                                <option value="12" {{ $currentMonth == 12 ? 'selected' : '' }}>December</option>
                            </select>
                            <i class="fas fa-chevron-down" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--text-grey); pointer-events: none; font-size: 0.8rem;"></i>
                        </div>
                        
                        <!-- Year -->
                        <div style="position: relative;">
                            <select name="birth_year" class="birth-select" style="width: 100%; padding: 14px 12px; border: 2px solid var(--border-grey); border-radius: 12px; font-size: 0.95rem; transition: all 0.3s ease; background: var(--white); color: var(--text-dark); appearance: none; cursor: pointer;">
                                <option value="">Year</option>
                                @for($i = date('Y') - 18; $i >= date('Y') - 80; $i--)
                                    <option value="{{ $i }}" {{ $currentYear == $i ? 'selected' : '' }}>{{ $i }}</option>
                                @endfor
                            </select>
                            <i class="fas fa-chevron-down" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--text-grey); pointer-events: none; font-size: 0.8rem;"></i>
                        </div>
                    </div>
                    
                    @if($admin->birth_date)
                        <div style="margin-top: 8px; padding: 8px 12px; background: var(--cream-light); border-radius: 8px; font-size: 0.85rem; color: var(--forest-green); display: flex; align-items: center; gap: 8px;">
                            <i class="fas fa-birthday-cake"></i>
                            <span>{{ \Carbon\Carbon::parse($admin->birth_date)->format('F j, Y') }} ({{ \Carbon\Carbon::parse($admin->birth_date)->age }} years old)</span>
                        </div>
                    @endif
                    
                    @error('birth_date')
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>
            </div>
            
            <!-- Password Section -->
            <div class="section-divider">
                <h3 class="section-title">
                    <i class="fas fa-lock"></i>
                    Security Settings
                </h3>
                
                <div class="form-group">
                    <label class="form-label">Current Password</label>
                    <input type="password" name="current_password" class="form-input" placeholder="Enter current password to change">
                    @error('current_password')
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <input type="password" name="new_password" class="form-input" placeholder="Enter new password">
                        @error('new_password')
                            <div class="error-message">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </div>
                        @enderror
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" name="new_password_confirmation" class="form-input" placeholder="Confirm new password">
                    </div>
                </div>
                
                <p style="color: var(--text-grey); font-size: 0.85rem; margin-top: 8px;">
                    <i class="fas fa-info-circle"></i>
                    Only fill password fields if you want to change your password. Other fields can be updated independently.
                </p>
            </div>
            
            <!-- Submit Button -->
            <div style="display: flex; justify-content: flex-end;">
                <button type="submit" class="update-btn">
                    <i class="fas fa-save"></i>
                    <span>Update Profile</span>
                </button>
            </div>
        </form>
    </div>
</div>
<style>
.birth-select:focus {
    border-color: var(--forest-green) !important;
    box-shadow: 0 0 0 3px rgba(14, 19, 48, 0.1) !important;
    outline: none;
}

.birth-select:hover {
    border-color: var(--forest-green);
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const daySelect = document.querySelector('select[name="birth_day"]');
    const monthSelect = document.querySelector('select[name="birth_month"]');
    const yearSelect = document.querySelector('select[name="birth_year"]');
    
    // Update days based on selected month and year
    function updateDays() {
        const month = parseInt(monthSelect.value);
        const year = parseInt(yearSelect.value);
        const currentDay = daySelect.value;
        
        if (month && year) {
            const daysInMonth = new Date(year, month, 0).getDate();
            
            // Clear existing options except first
            daySelect.innerHTML = '<option value="">Day</option>';
            
            // Add days for the selected month
            for (let i = 1; i <= daysInMonth; i++) {
                const option = document.createElement('option');
                option.value = i;
                option.textContent = i;
                if (currentDay == i && i <= daysInMonth) {
                    option.selected = true;
                }
                daySelect.appendChild(option);
            }
        }
    }
    
    monthSelect.addEventListener('change', updateDays);
    yearSelect.addEventListener('change', updateDays);
});

// Image preview function
function previewImage(input) {
    const fileLabel = document.getElementById('fileLabel');
    
    if (input.files && input.files[0]) {
        const file = input.files[0];
        
        // Update label with file name
        fileLabel.innerHTML = `<i class="fas fa-check-circle" style="color: #10B981; margin-right: 8px;"></i>${file.name}`;
        
        // Preview image
        const reader = new FileReader();
        reader.onload = function(e) {
            const currentAvatar = document.querySelector('.current-avatar');
            currentAvatar.innerHTML = `<img src="${e.target.result}" alt="Preview" style="width: 100%; height: 100%; object-fit: cover;">`;
        };
        reader.readAsDataURL(file);
    } else {
        fileLabel.textContent = 'Choose Image File';
    }
}

// Delete profile image function
function deleteProfileImage() {
    if (confirm('Are you sure you want to delete your profile image?')) {
        fetch('{{ route('admin.profile.image.delete') }}', {
            method: 'DELETE',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Update current avatar to show initials
                const currentAvatar = document.querySelector('.current-avatar');
                currentAvatar.innerHTML = `<div style="width: 100%; height: 100%; background: linear-gradient(135deg, var(--terracotta), #ff9b57); display: flex; align-items: center; justify-content: center; color: white; font-weight: 700; font-size: 1.5rem;">{{ substr($admin->first_name, 0, 1) }}{{ substr($admin->last_name, 0, 1) }}</div>`;
                
                // Remove delete button
                const deleteBtn = document.querySelector('button[onclick="deleteProfileImage()"]');
                if (deleteBtn) deleteBtn.remove();
                
                // Show success message
                showNotification('success', 'Success', 'Profile image deleted successfully');
                
                // Reload page to update header
                setTimeout(() => location.reload(), 1000);
            } else {
                showNotification('error', 'Error', data.message || 'Failed to delete image');
            }
        })
        .catch(error => {
            showNotification('error', 'Error', 'Failed to delete image');
        });
    }
}
</script>
@endsection
