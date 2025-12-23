@extends('admin.layout')

@section('title', 'Create Admin')
@section('icon', 'fas fa-user-plus')

@section('content')
    <style>
        .form-group {
            margin-bottom: var(--space-lg);
        }

        .form-label {
            display: block;
            margin-bottom: var(--space-sm);
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.9rem;
        }

        .form-input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--border-grey);
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            transition: var(--transition);
            background: var(--white);
        }

        .form-input:focus {
            outline: none;
            border-color: var(--deep-green);
            box-shadow: 0 0 0 3px rgba(0, 63, 63, 0.1);
        }

        .form-error {
            color: #EF4444;
            font-size: 0.8rem;
            margin-top: var(--space-xs);
            display: flex;
            align-items: center;
            gap: var(--space-xs);
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: var(--space-sm);
            text-decoration: none;
        }

        .btn-primary {
            background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px), linear-gradient(135deg, var(--deep-green) 0%, var(--dark-secondary) 100%);
            color: var(--white);
            border: none;
            border-radius: var(--radius-md);
            font-family: var(--font-primary);
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
            display: inline-flex;
            align-items: center;
            gap: var(--space-sm);
            text-decoration: none;
            box-shadow: 0 4px 12px rgba(14, 19, 48, 0.3);
        }

        .btn-primary::before {
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
        }

        .btn-primary::after {
            content: '';
            position: absolute;
            width: 35px;
            height: 35px;
            right: 15px;
            top: 30%;
            border-radius: 50%;
            background: radial-gradient(circle at 30% 30%, var(--yellow-accent) 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%);
            opacity: 0.8;
            pointer-events: none;
        }

        .btn-primary::before {
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
        }

        .btn-primary::after {
            content: '';
            position: absolute;
            width: 35px;
            height: 35px;
            right: 15px;
            top: 30%;
            border-radius: 50%;
            background: radial-gradient(circle at 30% 30%, var(--yellow-accent) 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%);
            opacity: 0.8;
            pointer-events: none;
        }

        .btn-primary *,
        .btn-primary .btn-text,
        .btn-primary .btn-loader,
        .btn-primary i,
        .btn-primary span {
            position: relative;
            z-index: 10;
            color: #ffffff !important;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }

        .btn-secondary {
            background: var(--light-grey);
            color: var(--text-dark);
            border: 1px solid var(--border-grey);
        }

        .btn-secondary:hover {
            background: var(--border-grey);
        }

        .birth-select:focus {
            border-color: var(--deep-green) !important;
            box-shadow: 0 0 0 3px rgba(0, 63, 63, 0.1) !important;
            outline: none;
        }

        .birth-select:hover {
            border-color: var(--deep-green);
        }
    </style>

    <div class="content-card" style="max-width: 700px; margin: 0 auto;">
        <div class="card-header">
            <h3 class="card-title">
                <i class="fas fa-user-plus"></i>
                Create New Administrator
            </h3>
            <p style="margin: var(--space-sm) 0 0; color: var(--text-grey); font-size: 0.9rem;">Add a new admin to manage
                the AUTOHIVE platform</p>
        </div>

        <div style="padding: var(--space-2xl);">
            @if($errors->any())
                <div
                    style="background: #FEF2F2; border: 1px solid #FECACA; color: #DC2626; padding: var(--space-md); border-radius: var(--radius-md); margin-bottom: var(--space-lg);">
                    <div style="display: flex; align-items: center; gap: var(--space-sm); margin-bottom: var(--space-sm);">
                        <i class="fas fa-exclamation-triangle"></i>
                        <strong>Please fix the following errors:</strong>
                    </div>
                    <ul style="margin: 0; padding-left: var(--space-lg);">
                        @foreach($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form method="POST" action="{{ route('admin.admins.store') }}">
                @csrf

                <div
                    style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-lg); margin-bottom: var(--space-lg);">
                    <div class="form-group">
                        <label class="form-label">First Name *</label>
                        <input type="text" name="first_name" value="{{ old('first_name') }}" required class="form-input"
                            placeholder="Enter first name">
                        @error('first_name')
                            <div class="form-error">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </div>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label class="form-label">Last Name *</label>
                        <input type="text" name="last_name" value="{{ old('last_name') }}" required class="form-input"
                            placeholder="Enter last name">
                        @error('last_name')
                            <div class="form-error">
                                <i class="fas fa-exclamation-circle"></i>
                                {{ $message }}
                            </div>
                        @enderror
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Phone Number *</label>
                    <input type="text" name="phone" value="{{ old('phone') }}" required class="form-input"
                        placeholder="e.g., 0994134966">
                    <div style="font-size: 0.8rem; color: var(--text-grey); margin-top: var(--space-xs);">Phone number will
                        be used for login</div>
                    @error('phone')
                        <div class="form-error">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>

                <div class="form-group">
                    <label class="form-label">Password *</label>
                    <input type="password" name="password" required class="form-input"
                        placeholder="Enter secure password (min. 6 characters)">
                    <div style="font-size: 0.8rem; color: var(--text-grey); margin-top: var(--space-xs);">Minimum 6
                        characters required</div>
                    @error('password')
                        <div class="form-error">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>

                <div class="form-group">
                    <label class="form-label">Birth Date *</label>
                    <div style="display: grid; grid-template-columns: 1fr 2fr 1fr; gap: 12px;">
                        <!-- Day -->
                        <div style="position: relative;">
                            <select name="birth_day" class="birth-select" style="width: 100%; padding: 12px 16px; border: 2px solid var(--border-grey); border-radius: var(--radius-md); font-size: 0.9rem; transition: var(--transition); background: var(--white); color: var(--text-dark); appearance: none; cursor: pointer;">
                                <option value="">Day</option>
                                @for($i = 1; $i <= 31; $i++)
                                    <option value="{{ $i }}" {{ old('birth_day') == $i ? 'selected' : '' }}>{{ $i }}</option>
                                @endfor
                            </select>
                            <i class="fas fa-chevron-down" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--text-grey); pointer-events: none; font-size: 0.8rem;"></i>
                        </div>

                        <!-- Month -->
                        <div style="position: relative;">
                            <select name="birth_month" class="birth-select" style="width: 100%; padding: 12px 16px; border: 2px solid var(--border-grey); border-radius: var(--radius-md); font-size: 0.9rem; transition: var(--transition); background: var(--white); color: var(--text-dark); appearance: none; cursor: pointer;">
                                <option value="">Month</option>
                                <option value="1" {{ old('birth_month') == 1 ? 'selected' : '' }}>January</option>
                                <option value="2" {{ old('birth_month') == 2 ? 'selected' : '' }}>February</option>
                                <option value="3" {{ old('birth_month') == 3 ? 'selected' : '' }}>March</option>
                                <option value="4" {{ old('birth_month') == 4 ? 'selected' : '' }}>April</option>
                                <option value="5" {{ old('birth_month') == 5 ? 'selected' : '' }}>May</option>
                                <option value="6" {{ old('birth_month') == 6 ? 'selected' : '' }}>June</option>
                                <option value="7" {{ old('birth_month') == 7 ? 'selected' : '' }}>July</option>
                                <option value="8" {{ old('birth_month') == 8 ? 'selected' : '' }}>August</option>
                                <option value="9" {{ old('birth_month') == 9 ? 'selected' : '' }}>September</option>
                                <option value="10" {{ old('birth_month') == 10 ? 'selected' : '' }}>October</option>
                                <option value="11" {{ old('birth_month') == 11 ? 'selected' : '' }}>November</option>
                                <option value="12" {{ old('birth_month') == 12 ? 'selected' : '' }}>December</option>
                            </select>
                            <i class="fas fa-chevron-down" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--text-grey); pointer-events: none; font-size: 0.8rem;"></i>
                        </div>

                        <!-- Year -->
                        <div style="position: relative;">
                            <select name="birth_year" class="birth-select" style="width: 100%; padding: 12px 16px; border: 2px solid var(--border-grey); border-radius: var(--radius-md); font-size: 0.9rem; transition: var(--transition); background: var(--white); color: var(--text-dark); appearance: none; cursor: pointer;">
                                <option value="">Year</option>
                                @for($i = date('Y') - 18; $i >= date('Y') - 80; $i--)
                                    <option value="{{ $i }}" {{ old('birth_year') == $i ? 'selected' : '' }}>{{ $i }}</option>
                                @endfor
                            </select>
                            <i class="fas fa-chevron-down" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--text-grey); pointer-events: none; font-size: 0.8rem;"></i>
                        </div>
                    </div>

                    @error('birth_day')
                        <div class="form-error">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                    @error('birth_month')
                        <div class="form-error">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                    @error('birth_year')
                        <div class="form-error">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>

                <div
                    style="display: flex; gap: var(--space-md); padding-top: var(--space-lg); border-top: 1px solid var(--border-grey);">
                    <button type="submit" class="btn btn-primary">
                        <span class="btn-text">
                            <i class="fas fa-user-plus"></i>
                            Create Administrator
                        </span>
                    </button>
                    <a href="{{ route('admin.admins') }}" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i>
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

    @push('scripts')
        <script>
            // Auto-format phone number
            document.querySelector('input[name="phone"]').addEventListener('input', function (e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length > 10) value = value.slice(0, 10);
                e.target.value = value;
            });

            // Dynamic birth date updates
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
        </script>
    @endpush
@endsection
