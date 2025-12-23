<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - AUTOHIVE</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --deep-green: #0e1330;
            --mint-light: #fff5e6;
            --yellow-accent: #ff6f2d;
            --text-dark: #0e1330;
            --text-grey: #6B7280;
            --white: #FFFFFF;
            --off-white: #fff5e6;
            --light-grey: #f6b67a;
            --border-grey: rgba(255, 111, 45, 0.2);
            --darker: #0e1330;
            --dark-secondary: #17173a;
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-xl: 20px;
            --shadow-soft: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
            --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --font-primary: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            --transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: var(--font-primary);
            background: #f8fafc;
            min-height: 100vh;
            display: flex;
            overflow: hidden;
            position: relative;
        }

        /* Animated Background */
        .animated-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 0;
        }

        .floating-shapes {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        .shape {
            position: absolute;
            background: rgba(255, 111, 45, 0.1);
            border-radius: 50%;
        }

        .shape-1 {
            width: 80px;
            height: 80px;
            top: 20%;
            left: 10%;
            animation: float 6s ease-in-out infinite;
        }

        .shape-2 {
            width: 120px;
            height: 120px;
            top: 60%;
            right: 15%;
            animation: float 8s ease-in-out infinite reverse;
        }

        .shape-3 {
            width: 60px;
            height: 60px;
            bottom: 20%;
            left: 20%;
            animation: float 7s ease-in-out infinite;
        }

        .shape-4 {
            width: 100px;
            height: 100px;
            top: 10%;
            right: 30%;
            animation: float 9s ease-in-out infinite reverse;
        }

        .shape-5 {
            width: 40px;
            height: 40px;
            top: 70%;
            left: 60%;
            animation: float 5s ease-in-out infinite;
        }

        .shape-6 {
            width: 90px;
            height: 90px;
            bottom: 40%;
            right: 10%;
            animation: float 10s ease-in-out infinite reverse;
        }

        .particles {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        .particle {
            position: absolute;
            width: 4px;
            height: 4px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            animation: particle 15s linear infinite;
        }

        .particle:nth-child(1) { left: 10%; animation-delay: 0s; }
        .particle:nth-child(2) { left: 20%; animation-delay: 2s; }
        .particle:nth-child(3) { left: 30%; animation-delay: 4s; }
        .particle:nth-child(4) { left: 40%; animation-delay: 6s; }
        .particle:nth-child(5) { left: 50%; animation-delay: 8s; }
        .particle:nth-child(6) { left: 60%; animation-delay: 10s; }
        .particle:nth-child(7) { left: 70%; animation-delay: 12s; }
        .particle:nth-child(8) { left: 80%; animation-delay: 14s; }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            33% { transform: translateY(-20px) rotate(120deg); }
            66% { transform: translateY(20px) rotate(240deg); }
        }

        @keyframes particle {
            0% { transform: translateY(100vh) rotate(0deg); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translateY(-100vh) rotate(360deg); opacity: 0; }
        }

        /* Login Container */
        .login-container {
            display: flex;
            width: 100%;
            height: 100vh;
            position: relative;
            z-index: 1;
        }

        .login-card {
            flex: 1;
            max-width: 500px;
            background: var(--white);
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 3rem;
            position: relative;
            animation: slideInLeft 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .side-panel {
            flex: 1;
            background: 
                repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px),
                linear-gradient(180deg, var(--deep-green) 0%, var(--dark-secondary) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        
        .side-panel::before,
        .side-panel::after {
            content: '';
            position: absolute;
            inset: 0;
            pointer-events: none;
            mix-blend-mode: normal;
            opacity: 1;
        }
        
        .side-panel::before {
            width: 180%;
            height: 120%;
            left: -40%;
            top: -10%;
            transform: rotate(-18deg);
            background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%);
            clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%);
            filter: drop-shadow(0 8px 20px rgba(0, 0, 0, 0.35));
        }
        
        .side-panel::after {
            width: 140%;
            height: 90%;
            right: -30%;
            bottom: -20%;
            transform: rotate(12deg);
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.03) 0%, rgba(255, 255, 255, 0.0) 40%);
            clip-path: polygon(0 0, 80% 0, 95% 100%, 0% 100%);
            mix-blend-mode: overlay;
        }
        
        .geometric-accent-circle {
            position: absolute;
            width: 160px;
            height: 160px;
            right: -40px;
            top: 40%;
            border-radius: 50%;
            transform: translateY(-50%) rotate(-10deg);
            background: radial-gradient(circle at 30% 30%, var(--yellow-accent) 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%);
            filter: blur(0.6px);
            mix-blend-mode: screen;
            opacity: 0.98;
            pointer-events: none;
            z-index: 1;
        }
        
        .geometric-ring {
            position: absolute;
            width: 240px;
            height: 240px;
            left: -80px;
            bottom: -60px;
            border-radius: 50%;
            border: 10px solid rgba(255, 150, 80, 0.14);
            transform: rotate(-20deg);
            pointer-events: none;
            z-index: 1;
        }
        
        .geometric-small-rect {
            position: absolute;
            left: 18%;
            top: 8%;
            width: 28px;
            height: 28px;
            border-radius: 6px;
            background: linear-gradient(180deg, var(--yellow-accent) 0%, #ff9b57 100%);
            box-shadow: 0 6px 18px rgba(255, 110, 55, 0.12), inset 0 -3px 6px rgba(0, 0, 0, 0.15);
            transform: rotate(-12deg);
            pointer-events: none;
            z-index: 1;
        }
        
        .geometric-dots {
            position: absolute;
            right: 20px;
            top: 18%;
            display: grid;
            grid-template-columns: repeat(3, 6px);
            gap: 8px;
            transform: rotate(-8deg);
            opacity: 0.95;
            pointer-events: none;
            z-index: 1;
        }
        
        .geometric-dots span {
            width: 6px;
            height: 6px;
            border-radius: 2px;
            background: linear-gradient(180deg, #fff5e6, rgba(255, 255, 255, 0.7));
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.25);
            display: block;
        }
        
        .geometric-right-glow {
            position: absolute;
            right: -6%;
            top: 0;
            width: 22%;
            height: 100%;
            pointer-events: none;
            background: linear-gradient(90deg, rgba(255, 255, 255, 0.02), rgba(255, 255, 255, 0.0) 40%);
            mix-blend-mode: soft-light;
            z-index: 1;
        }

        .side-panel::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="50" cy="50" r="1" fill="%23ffffff" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>') repeat;
            opacity: 0.3;
        }

        .panel-content {
            text-align: center;
            color: var(--white);
            z-index: 1;
            position: relative;
            animation: slideInRight 0.8s cubic-bezier(0.4, 0, 0.2, 1) 0.2s both;
        }

        .panel-icon {
            font-size: 4rem;
            margin-bottom: 2rem;
            color: var(--yellow-accent);
            animation: pulse 2s infinite;
        }

        .panel-content h2 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            letter-spacing: -0.02em;
        }

        .panel-content p {
            font-size: 1.1rem;
            opacity: 0.9;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        .features {
            display: flex;
            flex-direction: column;
            gap: 1rem;
            align-items: center;
        }

        .feature {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 0.95rem;
            opacity: 0.8;
        }

        .feature i {
            color: var(--yellow-accent);
            width: 20px;
        }

        /* Logo Section */
        .logo-section {
            text-align: center;
            margin-bottom: 3rem;
            animation: fadeInUp 0.6s ease 0.3s both;
        }

        .logo-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--deep-green) 0%, var(--yellow-accent) 100%);
            border-radius: var(--radius-xl);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2rem;
            color: var(--white);
            box-shadow: 0 8px 20px rgba(255, 111, 45, 0.3);
            animation: pulse 2s infinite;
        }

        .logo-text {
            font-size: 2rem;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 0.5rem;
            letter-spacing: -0.02em;
        }

        .logo-subtitle {
            color: var(--text-grey);
            font-size: 1rem;
            font-weight: 500;
        }

        /* Form Styles */
        .login-form {
            animation: fadeInUp 0.6s ease 0.5s both;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-grey);
            font-size: 1.1rem;
            transition: var(--transition);
            z-index: 2;
        }

        .form-input {
            width: 100%;
            padding: 1rem 1rem 1rem 3rem;
            border: 2px solid var(--border-grey);
            border-radius: var(--radius-md);
            font-family: var(--font-primary);
            font-size: 1rem;
            transition: var(--transition);
            background: var(--white);
            position: relative;
            z-index: 1;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--deep-green);
            box-shadow: 0 0 0 3px rgba(14, 19, 48, 0.1);
        }

        .form-input:focus + .input-icon {
            color: var(--deep-green);
        }

        .input-line {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 0;
            height: 2px;
            background: var(--deep-green);
            transition: var(--transition);
        }

        .form-input:focus ~ .input-line {
            width: 100%;
        }

        .password-toggle {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--text-grey);
            cursor: pointer;
            font-size: 1rem;
            transition: var(--transition);
            z-index: 2;
        }

        .password-toggle:hover {
            color: var(--deep-green);
        }

        .login-btn {
            width: 100%;
            padding: 1rem;
            background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px), linear-gradient(135deg, var(--deep-green) 0%, var(--dark-secondary) 100%);
            color: var(--white);
            border: none;
            border-radius: var(--radius-md);
            font-family: var(--font-primary);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            box-shadow: 0 4px 12px rgba(14, 19, 48, 0.3);
        }
        
        .login-btn::before {
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
        
        .login-btn::after {
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
        
        .login-btn .btn-text,
        .login-btn .btn-loader {
            position: relative;
            z-index: 2;
        }

        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }

        .btn-loader {
            display: none;
            width: 20px;
            height: 20px;
        }

        .loader-ring {
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: var(--white);
            animation: spin 1s linear infinite;
        }

        .login-btn.loading .btn-loader {
            display: block;
        }

        .login-btn.loading .btn-text {
            display: none;
        }

        .error-message {
            color: #EF4444;
            font-size: 0.875rem;
            margin-top: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .alert {
            padding: 1rem;
            border-radius: var(--radius-md);
            margin-top: 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .alert-error {
            background: #FEF2F2;
            color: #DC2626;
            border: 1px solid #FECACA;
        }

        .login-footer {
            text-align: center;
            margin-top: 2rem;
            color: var(--text-grey);
            font-size: 0.875rem;
        }

        @keyframes slideInLeft {
            from { opacity: 0; transform: translateX(-50px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(50px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        @media (max-width: 768px) {
            .login-container {
                flex-direction: column;
            }
            .side-panel {
                display: none;
            }
            .login-card {
                max-width: none;
                padding: 2rem;
            }
        }
    </style>
</head>
<body>
    <!-- Animated Background -->
    <div class="animated-bg">
        <div class="floating-shapes">
            <div class="shape shape-1"></div>
            <div class="shape shape-2"></div>
            <div class="shape shape-3"></div>
            <div class="shape shape-4"></div>
            <div class="shape shape-5"></div>
            <div class="shape shape-6"></div>
        </div>
        <div class="particles">
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
        </div>
    </div>

    <!-- Login Container -->
    <div class="login-container">
        <div class="login-card">
            <!-- Logo Section -->
            <div class="logo-section">
                <div class="logo-icon">
                    <i class="fas fa-home"></i>
                </div>
                <h1 class="logo-text">AUTOHIVE</h1>
                <p class="logo-subtitle">Admin Portal</p>
            </div>

            <!-- Login Form -->
            <form class="login-form" method="POST" action="{{ route('admin.login.post') }}" 
                  autocomplete="off" novalidate data-lpignore="true">
                @csrf
                
                <!-- Phone Field -->
                <div class="form-group">
                    <div class="input-wrapper">
                        <i class="fas fa-phone input-icon"></i>
                        <input type="text" name="phone" class="form-input" placeholder="Phone Number" 
                               value="{{ old('phone') }}" required autocomplete="new-password" autofocus 
                               data-lpignore="true" data-form-type="other" 
                               maxlength="15" pattern="[0-9]+">
                        <div class="input-line"></div>
                    </div>
                    @error('phone')
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>

                <!-- Password Field -->
                <div class="form-group">
                    <div class="input-wrapper">
                        <i class="fas fa-lock input-icon"></i>
                        <input type="password" name="password" class="form-input" placeholder="Password" 
                               required autocomplete="new-password" 
                               data-lpignore="true" data-form-type="other" 
                               maxlength="255" minlength="6">
                        <button type="button" class="password-toggle" onclick="togglePassword()">
                            <i class="fas fa-eye" id="passwordIcon"></i>
                        </button>
                        <div class="input-line"></div>
                    </div>
                    @error('password')
                        <div class="error-message">
                            <i class="fas fa-exclamation-circle"></i>
                            {{ $message }}
                        </div>
                    @enderror
                </div>

                <!-- Submit Button -->
                <button type="submit" class="login-btn" id="loginBtn">
                    <span class="btn-text">
                        <i class="fas fa-sign-in-alt"></i>
                        Sign In
                    </span>
                    <div class="btn-loader">
                        <div class="loader-ring"></div>
                    </div>
                </button>

                <!-- Error Messages -->
                @if ($errors->any())
                    <div class="alert alert-error">
                        <i class="fas fa-exclamation-triangle"></i>
                        <span>{{ $errors->first() }}</span>
                    </div>
                @endif
            </form>

            <!-- Footer -->
            <div class="login-footer">
                <p>&copy; {{ date('Y') }} AUTOHIVE. All rights reserved.</p>
            </div>
        </div>

        <!-- Side Panel -->
        <div class="side-panel">
            <div class="panel-content">
                <div class="panel-icon">
                    <i class="fas fa-building"></i>
                </div>
                <h2>Welcome Back!</h2>
                <p>Access your admin dashboard to manage apartments, bookings, and users on the AUTOHIVE platform.</p>
                <div class="features">
                    <div class="feature">
                        <i class="fas fa-chart-line"></i>
                        <span>Analytics Dashboard</span>
                    </div>
                    <div class="feature">
                        <i class="fas fa-users"></i>
                        <span>User Management</span>
                    </div>
                    <div class="feature">
                        <i class="fas fa-home"></i>
                        <span>Property Control</span>
                    </div>
                </div>
            </div>
            
            <!-- Geometric elements -->
            <div class="geometric-accent-circle" aria-hidden="true"></div>
            <div class="geometric-ring" aria-hidden="true"></div>
            <div class="geometric-small-rect" aria-hidden="true"></div>
            <div class="geometric-dots" aria-hidden="true">
                <span></span><span></span><span></span>
                <span></span><span></span><span></span>
                <span></span><span></span><span></span>
            </div>
            <div class="geometric-right-glow" aria-hidden="true"></div>
        </div>
    </div>

    <script>
        // Disable autocomplete and autofill
        document.addEventListener('DOMContentLoaded', function() {
            const inputs = document.querySelectorAll('input');
            inputs.forEach(input => {
                input.setAttribute('autocomplete', 'new-password');
                input.setAttribute('data-lpignore', 'true');
                input.setAttribute('data-form-type', 'other');
            });
        });

        // Password toggle
        function togglePassword() {
            const passwordInput = document.querySelector('input[name="password"]');
            const passwordIcon = document.getElementById('passwordIcon');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                passwordIcon.classList.remove('fa-eye');
                passwordIcon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                passwordIcon.classList.remove('fa-eye-slash');
                passwordIcon.classList.add('fa-eye');
            }
        }

        // Form submission
        document.querySelector('.login-form').addEventListener('submit', function() {
            const btn = document.getElementById('loginBtn');
            btn.classList.add('loading');
            btn.disabled = true;
        });

        // Input focus effects
        const inputs = document.querySelectorAll('.form-input');
        inputs.forEach(input => {
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.02)';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
            });
        });
    </script>
</body>
</html>