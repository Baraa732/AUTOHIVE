<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') - AUTOHIVE Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
        rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <style>
        :root {
            --bg-dark-1: #0e1330;
            --bg-dark-2: #17173a;
            --panel-purple: #241a46;
            --accent-orange: #ff6f2d;
            --accent-orange-2: #ff9b57;
            --accent-mustard: #f7c84a;
            --pale: #fff5e6;
            --navy-primary: #0e1330;
            --navy-dark: #17173a;
            --navy-light: #241a46;
            --orange-muted: #ff6f2d;
            --orange-light: #ff9b57;
            --orange-pale: #fff5e6;
            --text-dark: #0e1330;
            --text-grey: #5A6C7D;
            --text-light: #8B9DC3;
            --white: #FFFFFF;
            --off-white: #fff5e6;
            --light-grey: #f6b67a;
            /* --border-grey: rgba(255, 111, 45, 0.2); */
            --border-grey: rgb(224 236 255 / 74%);
            --sidebar-bg: #0e1330;
            --sidebar-border: #17173a;
            --card-bg: #FFFFFF;
            --primary: #0e1330;
            --blue: #bfc9ff;
            --primary-light: #fff5e6;
            --primary-dark: #17173a;
            --accent: #ff6f2d;
            --deep-green: #0e1330;
            --dark-secondary: #17173a;
            --yellow-accent: #ff6f2d;
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-xl: 20px;
            --shadow-soft: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
            --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --font-primary: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            --space-xs: 4px;
            --space-sm: 8px;
            --space-md: 16px;
            --space-lg: 24px;
            --space-xl: 32px;
            --space-2xl: 48px;
            --transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            --sidebar-width: 280px;
            --sidebar-collapsed: 80px;
            --header-height: 72px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: var(--font-primary);
            background: #f8fafc;
            color: var(--text-dark);
            line-height: 1.6;
            overflow: hidden;
            font-size: 14px;
        }

        .admin-layout {
            display: flex;
            min-height: 100vh;
            background: #f8fafc;
        }

        .sidebar {
            width: var(--sidebar-width);
            background:
                repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px),
                linear-gradient(180deg, #0e1330 0%, #17173a 100%);
            transition: all 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            position: fixed;
            height: 100vh;
            left: 0;
            top: 0;
            z-index: 1000;
            overflow-y: auto;
            box-shadow: 0 8px 30px rgba(12, 14, 30, 0.25);
            display: flex;
            flex-direction: column;
            transform: translateX(0);
        }

        .sidebar::-webkit-scrollbar {
            display: none;
        }

        .sidebar {
            -ms-overflow-style: none;
            scrollbar-width: none;
            overflow: clip;
        }

        .sidebar::before,
        .sidebar::after {
            content: '';
            position: absolute;
            inset: 0;
            pointer-events: none;
            mix-blend-mode: normal;
            opacity: 1;
        }

        .sidebar::before {
            width: 180%;
            height: 120%;
            left: -40%;
            top: -10%;
            transform: rotate(-18deg);
            background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%);
            clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%);
            filter: drop-shadow(0 8px 20px rgba(0, 0, 0, 0.35));
        }

        .sidebar::after {
            width: 140%;
            height: 90%;
            right: -30%;
            bottom: -20%;
            transform: rotate(12deg);
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.03) 0%, rgba(255, 255, 255, 0.0) 40%);
            clip-path: polygon(0 0, 80% 0, 95% 100%, 0% 100%);
            mix-blend-mode: overlay;
        }

        .sidebar.collapsed {
            width: var(--sidebar-collapsed);
            transform: translateX(-10px);
        }

        .accent-circle {
            position: absolute;
            width: 160px;
            height: 160px;
            right: -40px;
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

        .ring {
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

        .small-rect {
            position: absolute;
            left: 18%;
            top: 8%;
            width: 28px;
            height: 28px;
            border-radius: 6px;
            background: linear-gradient(180deg, #ff6f2d 0%, #ff9b57 100%);
            box-shadow: 0 6px 18px rgba(255, 110, 55, 0.12), inset 0 -3px 6px rgba(0, 0, 0, 0.15);
            transform: rotate(-12deg);
            pointer-events: none;
            z-index: 1;
        }

        .dots {
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

        .dots span {
            width: 6px;
            height: 6px;
            border-radius: 2px;
            background: linear-gradient(180deg, #fff5e6, rgba(255, 255, 255, 0.7));
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.25);
            display: block;
        }

        .right-glow {
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

        .sidebar.collapsed .nav-text,
        .sidebar.collapsed .logo-text,
        .sidebar.collapsed .nav-label {
            opacity: 0;
            transform: translateX(-30px) scale(0.8);
            transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }

        .sidebar.collapsed .sidebar-profile {
            transform: scale(0.6) translateX(-5px);
            margin-bottom: 10px;
        }

        .sidebar-header {
            padding: var(--space-lg);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            position: relative;
            background: transparent;
            z-index: 1;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            text-decoration: none;
            transition: all 0.5s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            animation: logoFloat 3s ease-in-out infinite;
        }

        @keyframes logoFloat {

            0%,
            100% {
                transform: translateY(0px);
            }

            50% {
                transform: translateY(-3px);
            }
        }

        .logo-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--accent-orange), var(--accent-orange-2));
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            color: var(--white);
            transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            box-shadow: 0 4px 12px rgba(255, 111, 45, 0.3);
            animation: iconPulse 2s ease-in-out infinite;
        }

        @keyframes iconPulse {

            0%,
            100% {
                transform: scale(1);
                box-shadow: 0 4px 12px rgba(255, 111, 45, 0.3);
            }

            50% {
                transform: scale(1.05);
                box-shadow: 0 6px 20px rgba(255, 111, 45, 0.5);
            }
        }

        .logo-text {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--white);
            transition: var(--transition);
            letter-spacing: -0.3px;
        }

        .sidebar.collapsed .logo-text {
            opacity: 0;
            visibility: hidden;
            transform: translateX(-20px);
        }



        .sidebar-nav {
            padding: var(--space-lg) 0;
            flex: 1;
        }

        .nav-section {
            margin-bottom: var(--space-lg);
        }

        .nav-label {
            padding: 0 var(--space-lg) var(--space-sm);
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--text-light);
            font-weight: 600;
            transition: var(--transition);
            position: relative;
            z-index: 1;
        }

        .sidebar.collapsed .nav-label {
            opacity: 0;
            visibility: hidden;
            transform: translateX(-20px);
        }

        .nav-items {
            list-style: none;
        }

        .nav-item {
            margin-bottom: 2px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            padding: 12px var(--space-lg);
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            position: relative;
            border-radius: 0 var(--radius-lg) var(--radius-lg) 0;
            margin-right: var(--space-md);
            font-weight: 500;
            transform: translateX(0);
            z-index: 1;
            opacity: 0;
            animation: slideInNav 0.6s ease-out forwards;
        }

        .nav-item:nth-child(1) .nav-link {
            animation-delay: 0.1s;
        }

        .nav-item:nth-child(2) .nav-link {
            animation-delay: 0.2s;
        }

        .nav-item:nth-child(3) .nav-link {
            animation-delay: 0.3s;
        }

        .nav-item:nth-child(4) .nav-link {
            animation-delay: 0.4s;
        }

        .nav-item:nth-child(5) .nav-link {
            animation-delay: 0.5s;
        }

        @keyframes slideInNav {
            from {
                opacity: 0;
                transform: translateX(-30px);
            }

            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .nav-link::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 3px;
            height: 0;
            background: var(--orange-muted);
            border-radius: 2px;
            transition: var(--transition);
        }

        .nav-link:hover {
            color: var(--white);
            background: rgba(255, 255, 255, 0.1);
            transform: translateX(8px) scale(1.02);
            box-shadow: 0 4px 15px rgba(255, 111, 45, 0.2);
        }

        .nav-link:hover::before {
            height: 20px;
        }

        .nav-link.active {
            color: var(--white);
            background: rgba(255, 111, 45, 0.2);
            transform: translateX(5px);
            box-shadow: 0 4px 15px rgba(255, 111, 45, 0.3);
        }

        .nav-link.active::before {
            height: 24px;
        }

        .nav-icon {
            width: 20px;
            text-align: center;
            font-size: 1.1rem;
            transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }

        .nav-link:hover .nav-icon {
            transform: rotate(10deg) scale(1.1);
            color: var(--orange-light);
        }

        .nav-link.active .nav-icon {
            transform: scale(1.1);
            color: var(--orange-light);
            animation: iconBounce 0.6s ease-out;
        }

        @keyframes iconBounce {

            0%,
            20%,
            60%,
            100% {
                transform: scale(1.1) translateY(0);
            }

            40% {
                transform: scale(1.2) translateY(-3px);
            }

            80% {
                transform: scale(1.15) translateY(-1px);
            }
        }

        .nav-text {
            font-weight: 500;
            transition: var(--transition);
            font-size: 0.9rem;
        }

        .sidebar.collapsed .nav-text {
            opacity: 0;
            visibility: hidden;
            transform: translateX(-10px);
        }

        .nav-badge {
            margin-left: auto;
            background: var(--orange-muted);
            color: var(--white);
            padding: 2px 8px;
            border-radius: var(--radius-lg);
            font-size: 0.65rem;
            font-weight: 600;
            min-width: 20px;
            text-align: center;
        }

        .main-content {
            flex: 1;
            margin-left: var(--sidebar-width);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            min-height: 100vh;
            overflow-y: auto;
            max-height: 100vh;
        }

        .main-content::-webkit-scrollbar {
            width: 8px;
        }

        .main-content::-webkit-scrollbar-track {
            background: var(--light-grey);
            border-radius: 4px;
        }

        .main-content::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, var(--primary), var(--accent));
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .main-content::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(135deg, var(--accent), var(--primary));
        }

        .sidebar.collapsed+.main-content {
            margin-left: var(--sidebar-collapsed);
        }

        .admin-header {
            height: var(--header-height);
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid var(--border-grey);
            padding: 0 var(--space-xl);
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 999;
            box-shadow: 0 4px 20px rgba(14, 19, 48, 0.1);
            margin: var(--space-md);
            border-radius: var(--radius-lg);
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: var(--space-md);
        }

        .page-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #0e1330;
            letter-spacing: -0.3px;
            display: flex;
            align-items: center;
            gap: var(--space-sm);
        }

        .page-title i {
            color: var(--accent-orange);
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: var(--space-md);
        }

        .admin-details {
            display: flex;
            align-items: center;
            gap: var(--space-sm);
            padding: var(--space-sm) var(--space-md);
            background:
                repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px),
                linear-gradient(180deg, #0e1330 0%, #17173a 100%);
            border-radius: var(--radius-md);
            border: 1px solid var(--border-grey);
            position: relative;
            overflow: hidden;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            color: inherit;
        }

        .admin-details::before,
        .admin-details::after {
            content: '';
            position: absolute;
            inset: 0;
            pointer-events: none;
            mix-blend-mode: normal;
            opacity: 1;
        }

        .admin-details::before {
            width: 180%;
            height: 120%;
            left: -40%;
            top: -10%;
            transform: rotate(-18deg);
            background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%);
            clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%);
            filter: drop-shadow(0 8px 20px rgba(0, 0, 0, 0.35));
        }

        .admin-details::after {
            width: 140%;
            height: 90%;
            right: -30%;
            bottom: -20%;
            transform: rotate(12deg);
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.03) 0%, rgba(255, 255, 255, 0.0) 40%);
            clip-path: polygon(0 0, 80% 0, 95% 100%, 0% 100%);
            mix-blend-mode: overlay;
        }

        .admin-details:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(14, 19, 48, 0.3);
        }

        .admin-details-accent-circle {
            position: absolute;
            width: 60px;
            height: 60px;
            right: -15px;
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

        .admin-details-small-rect {
            position: absolute;
            left: 10%;
            top: 10%;
            width: 12px;
            height: 12px;
            border-radius: 3px;
            background: linear-gradient(180deg, #ff6f2d 0%, #ff9b57 100%);
            box-shadow: 0 3px 8px rgba(255, 110, 55, 0.12), inset 0 -1px 3px rgba(0, 0, 0, 0.15);
            transform: rotate(-12deg);
            pointer-events: none;
            z-index: 1;
        }

        .admin-details-dots {
            position: absolute;
            right: 8px;
            top: 20%;
            display: grid;
            grid-template-columns: repeat(2, 3px);
            gap: 3px;
            transform: rotate(-8deg);
            opacity: 0.7;
            pointer-events: none;
            z-index: 1;
        }

        .admin-details-dots span {
            width: 3px;
            height: 3px;
            border-radius: 1px;
            background: linear-gradient(180deg, #fff5e6, rgba(255, 255, 255, 0.7));
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.25);
            display: block;
        }

        .admin-avatar {
            width: 36px;
            height: 36px;
            background: linear-gradient(135deg, var(--accent-orange), var(--accent-orange-2));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-weight: 600;
            font-size: 13px;
            box-shadow: 0 4px 12px rgba(255, 111, 45, 0.3);
        }

        .admin-name {
            font-weight: 600;
            color: var(--white);
            font-size: 0.9rem;
            position: relative;
            z-index: 2;
        }

        .logout-btn {
            background: #EF4444;
            color: var(--white);
            border: none;
            padding: 10px 16px;
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.85rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: var(--space-xs);
        }

        .logout-btn:hover {
            background: #DC2626;
            transform: translateY(-1px);
            box-shadow: var(--shadow-card);
        }

        .content-area {
            padding: var(--space-xl);
            background: transparent;
            min-height: calc(100vh - var(--header-height));
            transition: opacity 0.2s ease;
            animation: fadeInUp 0.6s ease-out;
        }

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

        @keyframes slideInLeft {
            from {
                opacity: 0;
                transform: translateX(-30px);
            }

            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes bounce {

            0%,
            20%,
            60%,
            100% {
                transform: translateY(0);
            }

            40% {
                transform: translateY(-3px);
            }

            80% {
                transform: translateY(-1px);
            }
        }

        /* Dashboard specific styles */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: var(--space-lg);
            margin-bottom: var(--space-2xl);
        }

        .stat-card {
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

        .stat-card:nth-child(1) {
            animation-delay: 0.1s;
        }

        .stat-card:nth-child(2) {
            animation-delay: 0.2s;
        }

        .stat-card:nth-child(3) {
            animation-delay: 0.3s;
        }

        .stat-card:nth-child(4) {
            animation-delay: 0.4s;
        }

        .stat-card:nth-child(5) {
            animation-delay: 0.5s;
        }

        .stat-card:nth-child(6) {
            animation-delay: 0.6s;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary), var(--blue));
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }

        .stat-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: var(--space-md);
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, var(--primary-dark), var(--blue));
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 1.2rem;
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

        .content-card {
            background: var(--white);
            border-radius: var(--radius-xl);
            border: 1px solid var(--border-grey);
            overflow: hidden;
            box-shadow: var(--shadow-soft);
            transition: transform 0.2s ease;
            animation: fadeInUp 0.7s ease-out;
            animation-delay: 0.3s;
            animation-fill-mode: both;
        }

        .card-header {
            padding: var(--space-lg);
            border-bottom: 1px solid var(--border-grey);
            background: var(--light-grey);
        }

        .card-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: var(--space-sm);
        }

        .card-title i {
            color: var(--primary);
        }

        .activity-item {
            display: flex;
            align-items: flex-start;
            gap: var(--space-md);
            padding: var(--space-md) 0;
            border-bottom: 1px solid var(--border-grey);
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-icon {
            width: 36px;
            height: 36px;
            background: var(--light-grey);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            font-size: 0.9rem;
            flex-shrink: 0;
        }

        .activity-content {
            flex: 1;
        }

        .activity-title {
            font-weight: 500;
            color: var(--text-dark);
            margin-bottom: 2px;
            font-size: 0.9rem;
        }

        .activity-time {
            color: var(--text-grey);
            font-size: 0.8rem;
        }

        /* Mobile Responsive */
        @media (max-width: 1024px) {
            .stats-grid {
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
                width: 100%;
                max-width: 300px;
            }

            .sidebar.mobile-open {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
            }

            .content-area {
                padding: var(--space-md);
            }

            .admin-header {
                padding: 0 var(--space-md);
            }

            .admin-details .admin-name {
                display: none;
            }

            .stats-grid {
                grid-template-columns: 1fr;
                gap: var(--space-md);
            }

            .page-title {
                font-size: 1.2rem;
            }

            .stat-number {
                font-size: 1.5rem;
            }

            .content-area>div[style*="grid-template-columns: 2fr 1fr"] {
                grid-template-columns: 1fr !important;
            }
        }

        @media (max-width: 480px) {
            .content-area {
                padding: var(--space-sm);
            }

            .stat-card {
                padding: var(--space-lg);
            }

            .admin-header {
                padding: 0 var(--space-sm);
            }

            .logout-btn span {
                display: none;
            }
        }

        /* Mobile menu toggle */
        .mobile-menu-toggle {
            display: none;
            background: none;
            border: none;
            color: var(--text-dark);
            font-size: 1.2rem;
            cursor: pointer;
            padding: var(--space-sm);
        }

        @media (max-width: 768px) {
            .mobile-menu-toggle {
                display: block;
            }
        }

        /* Overlay for mobile sidebar */
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
        }

        .sidebar-overlay.active {
            display: block;
        }

        /* Custom Confirmation Modal */
        .confirm-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 10000;
            animation: fadeIn 0.2s ease;
        }

        .confirm-modal.active {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .confirm-content {
            background: var(--white);
            border-radius: var(--radius-xl);
            padding: var(--space-2xl);
            max-width: 400px;
            width: 90%;
            box-shadow: var(--shadow-lg);
            animation: slideUp 0.3s ease;
            text-align: center;
        }

        .confirm-icon {
            width: 60px;
            height: 60px;
            margin: 0 auto var(--space-lg);
            background: #FEF2F2;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #EF4444;
            font-size: 1.5rem;
        }

        .confirm-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: var(--space-sm);
        }

        .confirm-message {
            color: var(--text-grey);
            margin-bottom: var(--space-xl);
            line-height: 1.5;
        }

        .confirm-buttons {
            display: flex;
            gap: var(--space-md);
            justify-content: center;
        }

        .confirm-btn {
            padding: 12px 24px;
            border: none;
            border-radius: var(--radius-md);
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            min-width: 100px;
        }

        .confirm-btn-danger {
            background: #EF4444;
            color: var(--white);
        }

        .confirm-btn-danger:hover {
            background: #DC2626;
            transform: translateY(-1px);
        }

        .confirm-btn-cancel {
            background: var(--light-grey);
            color: var(--text-dark);
            border: 1px solid var(--border-grey);
        }

        .confirm-btn-cancel:hover {
            background: var(--border-grey);
        }

        /* Notification System */
        .notification-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 10001;
            max-width: 400px;
            width: 100%;
        }

        .notification {
            background: var(--white);
            border-radius: var(--radius-md);
            padding: var(--space-md);
            margin-bottom: var(--space-sm);
            box-shadow: var(--shadow-lg);
            border-left: 4px solid var(--deep-green);
            display: flex;
            align-items: flex-start;
            gap: var(--space-md);
            animation: slideInRight 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .notification.success {
            border-left-color: #10B981;
        }

        .notification.error {
            border-left-color: #EF4444;
        }

        .notification.warning {
            border-left-color: #F59E0B;
        }

        .notification.info {
            border-left-color: #3B82F6;
        }

        .notification-icon {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            flex-shrink: 0;
        }

        .notification.success .notification-icon {
            background: #10B98120;
            color: #10B981;
        }

        .notification.error .notification-icon {
            background: #EF444420;
            color: #EF4444;
        }

        .notification.warning .notification-icon {
            background: #F59E0B20;
            color: #F59E0B;
        }

        .notification.info .notification-icon {
            background: #3B82F620;
            color: #3B82F6;
        }

        .notification-content {
            flex: 1;
        }

        .notification-title {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.9rem;
            margin-bottom: 2px;
        }

        .notification-message {
            color: var(--text-grey);
            font-size: 0.8rem;
            line-height: 1.4;
        }

        .notification-close {
            background: none;
            border: none;
            color: var(--text-grey);
            cursor: pointer;
            padding: 2px;
            border-radius: 4px;
            transition: var(--transition);
        }

        .notification-close:hover {
            background: var(--light-grey);
            color: var(--text-dark);
        }

        .notification-progress {
            position: absolute;
            bottom: 0;
            left: 0;
            height: 2px;
            background: var(--deep-green);
            animation: progress 5s linear;
        }

        .notification.success .notification-progress {
            background: #10B981;
        }

        .notification.error .notification-progress {
            background: #EF4444;
        }

        .notification.warning .notification-progress {
            background: #F59E0B;
        }

        .notification.info .notification-progress {
            background: #3B82F6;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideInRight {
            from {
                opacity: 0;
                transform: translateX(100%);
            }

            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes progress {
            from {
                width: 100%;
            }

            to {
                width: 0%;
            }
        }

        @media (max-width: 480px) {
            .notification-container {
                top: 10px;
                right: 10px;
                left: 10px;
                max-width: none;
            }

            .confirm-content {
                padding: var(--space-lg);
            }
        }
    </style>
</head>

<body>
    <div class="admin-layout">
        <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleMobileSidebar()"></div>
        <aside class="sidebar" id="sidebar">
            <div class="sidebar-header">
                @if(auth()->user()->profile_image)
                    <div class="sidebar-profile"
                        style="text-align: center; margin-bottom: 20px; position: relative; z-index: 2; transition: all 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55);">
                        <div
                            style="width: 80px; height: 80px; margin: 0 auto; position: relative; clip-path: polygon(50% 0%, 100% 38%, 82% 100%, 18% 100%, 0% 38%); background: linear-gradient(135deg, #ff6f2d, #ff9b57); padding: 3px;">
                            <img src="{{ auth()->user()->profile_image_url }}" alt="Profile"
                                style="width: 100%; height: 100%; object-fit: cover; clip-path: polygon(50% 0%, 100% 38%, 82% 100%, 18% 100%, 0% 38%);">
                        </div>
                    </div>
                @endif
                <a href="#" class="logo">
                    <div class="logo-icon">
                        <i class="fas fa-home"></i>
                    </div>
                    <span class="logo-text">AUTOHIVE</span>
                </a>
            </div>

            <div
                style="padding: 15px 24px 16px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); position: relative; z-index: 1;">
                <button onclick="toggleSidebar()" aria-label="Toggle sidebar"
                    style="width: 100%; background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 8px; padding: 8px; cursor: pointer; transition: all 0.3s ease; display: flex; align-items: center; justify-content: center; color: var(--white);"
                    onmouseover="this.style.background='var(--orange-muted)'; this.style.color='var(--white)'; this.style.transform='scale(1.05)'"
                    onmouseout="this.style.background='rgba(255, 255, 255, 0.1)'; this.style.color='var(--white)'; this.style.transform='scale(1)'">
                    <i class="fas fa-chevron-left" id="toggleIcon"></i>
                </button>
            </div>

            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-label">Main</div>
                    <ul class="nav-items">
                        <li><a href="{{ route('admin.dashboard') }}"
                                class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-chart-pie"></i>
                                <span class="nav-text">Dashboard</span>
                            </a></li>
                        <li><a href="{{ route('admin.users') }}"
                                class="nav-link {{ request()->routeIs('admin.users') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-user-friends"></i>
                                <span class="nav-text">Users</span>
                            </a></li>
                        <li><a href="{{ route('admin.apartments') }}"
                                class="nav-link {{ request()->routeIs('admin.apartments') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-home"></i>
                                <span class="nav-text">Apartments</span>
                            </a></li>
                        <li><a href="{{ route('admin.bookings') }}"
                                class="nav-link {{ request()->routeIs('admin.bookings') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-calendar-alt"></i>
                                <span class="nav-text">Bookings</span>
                            </a></li>
                        <li><a href="{{ route('admin.notifications') }}"
                                class="nav-link {{ request()->routeIs('admin.notifications') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-bell"></i>
                                <span class="nav-text">Notifications</span>
                                <span id="sidebarNotificationBadge" class="nav-badge" style="display: none;">0</span>
                            </a></li>
                    </ul>
                </div>

                <div class="nav-section">
                    <div class="nav-label">Management</div>
                    <ul class="nav-items">
                        <li><a href="{{ route('admin.wallet.requests') }}"
                                class="nav-link {{ request()->routeIs('admin.wallet.*') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-wallet"></i>
                                <span class="nav-text">Wallet Requests</span>
                            </a></li>
                        <li><a href="{{ route('admin.wallet.users') }}"
                                class="nav-link {{ request()->routeIs('admin.wallet.users') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-users"></i>
                                <span class="nav-text">User Wallets</span>
                            </a></li>
                        <li><a href="{{ route('admin.admins') }}"
                                class="nav-link {{ request()->routeIs('admin.admins*') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-users-cog"></i>
                                <span class="nav-text">Admins</span>
                            </a></li>
                        <li><a href="{{ route('admin.profile') }}"
                                class="nav-link {{ request()->routeIs('admin.profile') ? 'active' : '' }}">
                                <i class="nav-icon fas fa-user-edit"></i>
                                <span class="nav-text">Profile</span>
                            </a></li>
                    </ul>
                </div>
            </nav>

            <!-- Logout Section -->
            <div
                style="padding: var(--space-lg); margin-top: -45px; border-top: 1px solid rgba(255, 255, 255, 0.1); position: relative; z-index: 1;">
                <form method="POST" action="{{ route('admin.logout') }}" style="width: 100%;">
                    @csrf
                    <button type="submit" class="nav-link"
                        style="width: 100%; background: rgba(239, 68, 68, 0.2); color: rgba(255, 255, 255, 0.9); border: 1px solid rgba(239, 68, 68, 0.3); padding: 12px; border-radius: 12px; cursor: pointer; transition: all 0.3s ease; font-size: 0.9rem; font-weight: 500; display: flex; align-items: center; gap: 12px; overflow: hidden;"
                        onmouseover="this.style.background='#EF4444'; this.style.color='white'; this.style.transform='translateY(-2px)'"
                        onmouseout="this.style.background='rgba(239, 68, 68, 0.2)'; this.style.color='rgba(255, 255, 255, 0.9)'; this.style.transform='translateY(0)'">
                        <i class="nav-icon fas fa-sign-out-alt"></i>
                        <span class="nav-text">Logout</span>
                    </button>
                </form>
            </div>
            <!-- Decorative elements -->
            <div class="accent-circle" aria-hidden="true"></div>
            <div class="ring" aria-hidden="true"></div>
            <div class="small-rect" aria-hidden="true"></div>
            <div class="dots" aria-hidden="true">
                <span></span><span></span><span></span>
                <span></span><span></span><span></span>
                <span></span><span></span><span></span>
            </div>
            <div class="right-glow" aria-hidden="true"></div>
        </aside>

        <main class="main-content">
            <header class="admin-header">
                <div class="header-left">
                    <button class="mobile-menu-toggle" onclick="toggleMobileSidebar()">
                        <i class="fas fa-bars"></i>
                    </button>
                    <h1 class="page-title">
                        <i class="@yield('icon', 'fas fa-chart-line')"></i>
                        @yield('title')
                    </h1>
                </div>
                <div class="header-right">
                    <!-- Notification Bell -->
                    <div style="position: relative; margin-right: var(--space-md);">
                        <button onclick="toggleNotificationPanel()"
                            style="background: none; border: none; color: var(--text-grey); font-size: 1.2rem; cursor: pointer; padding: var(--space-sm); border-radius: var(--radius-sm); transition: var(--transition); position: relative;">
                            <i class="fas fa-bell"></i>
                            <span id="notificationBadge"
                                style="position: absolute; top: 2px; right: 2px; background: #EF4444; color: var(--white); border-radius: 50%; width: 18px; height: 18px; font-size: 0.7rem; display: none; align-items: center; justify-content: center; font-weight: 600;">0</span>
                        </button>

                        <!-- Notification Panel -->
                        <div id="notificationPanel"
                            style="position: absolute; top: 100%; right: 0; width: 350px; background: var(--white); border-radius: var(--radius-md); box-shadow: var(--shadow-lg); border: 1px solid var(--border-grey); display: none; z-index: 1000; max-height: 400px; overflow-y: auto;">
                            <div
                                style="padding: var(--space-md); border-bottom: 1px solid var(--border-grey); display: flex; justify-content: space-between; align-items: center;">
                                <h4 style="font-size: 0.9rem; font-weight: 600; color: var(--text-dark);">Notifications
                                </h4>
                                <button onclick="markAllAsRead()"
                                    style="background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px), linear-gradient(135deg, #0e1330, #17173a); color: white; font-size: 0.8rem; cursor: pointer; padding: 6px 12px; border-radius: 8px; border: none; position: relative; overflow: hidden;">
                                    <!-- Geometric elements -->
                                    <div
                                        style="position: absolute; width: 180%; height: 120%; left: -40%; top: -10%; transform: rotate(-18deg); background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%); clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%); pointer-events: none;">
                                    </div>
                                    <div
                                        style="position: absolute; width: 12px; height: 12px; right: 2px; top: 20%; border-radius: 50%; background: radial-gradient(circle at 30% 30%, #ff6f2d 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%); opacity: 0.7; pointer-events: none;">
                                    </div>
                                    <span style="position: relative; z-index: 2;">Mark all read</span>
                                </button>
                            </div>
                            <div id="notificationList" style="max-height: 300px; overflow-y: auto;">
                                <div style="padding: var(--space-xl); text-align: center; color: var(--text-grey);">
                                    <i class="fas fa-bell-slash"
                                        style="font-size: 2rem; margin-bottom: var(--space-sm); opacity: 0.3;"></i>
                                    <p>No new notifications</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <a href="{{ route('admin.profile') }}" class="admin-details">
                        <div class="admin-avatar">
                            @if(auth()->user()->profile_image)
                                <img src="{{ auth()->user()->profile_image_url }}" alt="Profile"
                                    style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">
                            @else
                                {{ substr(auth()->user()->first_name, 0, 1) }}{{ substr(auth()->user()->last_name, 0, 1) }}
                            @endif
                        </div>
                        <div class="admin-name">
                            {{ auth()->user()->first_name }} {{ auth()->user()->last_name }}
                        </div>

                        <!-- Geometric elements -->
                        <div class="admin-details-accent-circle" aria-hidden="true"></div>
                        <div class="admin-details-small-rect" aria-hidden="true"></div>
                        <div class="admin-details-dots" aria-hidden="true">
                            <span></span><span></span>
                            <span></span><span></span>
                        </div>
                    </a>
                </div>
            </header>

            <div class="content-area">


                @yield('content')
            </div>
        </main>
    </div>

    <!-- Confirmation Modal -->
    <div class="confirm-modal" id="confirmModal">
        <div class="confirm-content">
            <div class="confirm-icon">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <h3 class="confirm-title" id="confirmTitle">Confirm Action</h3>
            <p class="confirm-message" id="confirmMessage">Are you sure you want to proceed?</p>
            <div class="confirm-buttons">
                <button class="confirm-btn confirm-btn-cancel" onclick="closeConfirmModal()">Cancel</button>
                <button class="confirm-btn confirm-btn-danger" id="confirmButton">Confirm</button>
            </div>
        </div>
    </div>

    <!-- Notification Container -->
    <div class="notification-container" id="notificationContainer"></div>

    <script>
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const toggleIcon = document.getElementById('toggleIcon');
            const mainContent = document.querySelector('.main-content');

            sidebar.classList.toggle('collapsed');
            mainContent.classList.toggle('sidebar-collapsed');

            // Save sidebar state
            const isCollapsed = sidebar.classList.contains('collapsed');
            localStorage.setItem('sidebar-collapsed', isCollapsed);

            if (isCollapsed) {
                toggleIcon.classList.remove('fa-chevron-left');
                toggleIcon.classList.add('fa-chevron-right');
                toggleIcon.style.animation = 'bounce 0.3s ease';
            } else {
                toggleIcon.classList.remove('fa-chevron-right');
                toggleIcon.classList.add('fa-chevron-left');
                toggleIcon.style.animation = 'bounce 0.3s ease';
            }

            setTimeout(() => {
                toggleIcon.style.animation = '';
            }, 300);
        }

        // Restore sidebar state on page load
        function restoreSidebarState() {
            const isCollapsed = localStorage.getItem('sidebar-collapsed') === 'true';
            const sidebar = document.getElementById('sidebar');
            const toggleIcon = document.getElementById('toggleIcon');
            const mainContent = document.querySelector('.main-content');

            if (isCollapsed) {
                sidebar.classList.add('collapsed');
                mainContent.classList.add('sidebar-collapsed');
                toggleIcon.classList.remove('fa-chevron-left');
                toggleIcon.classList.add('fa-chevron-right');
            } else {
                sidebar.classList.remove('collapsed');
                mainContent.classList.remove('sidebar-collapsed');
                toggleIcon.classList.remove('fa-chevron-right');
                toggleIcon.classList.add('fa-chevron-left');
            }
        }

        function toggleMobileSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('sidebarOverlay');

            sidebar.classList.toggle('mobile-open');
            overlay.classList.toggle('active');
        }

        // Simple navigation
        document.addEventListener('DOMContentLoaded', function () {
            // Restore sidebar state
            restoreSidebarState();

            const navLinks = document.querySelectorAll('.nav-link');
            navLinks.forEach(link => {
                link.addEventListener('click', function () {
                    if (window.innerWidth <= 768) {
                        toggleMobileSidebar();
                    }
                });
            });

            // Initialize notification system
            initNotificationSystem();
        });

        // Confirmation Modal Functions
        function showConfirmModal(title, message, onConfirm, type = 'danger') {
            const modal = document.getElementById('confirmModal');
            const titleEl = document.getElementById('confirmTitle');
            const messageEl = document.getElementById('confirmMessage');
            const confirmBtn = document.getElementById('confirmButton');

            titleEl.textContent = title;
            messageEl.textContent = message;

            confirmBtn.onclick = function () {
                closeConfirmModal();
                if (onConfirm) onConfirm();
            };

            modal.classList.add('active');
        }

        function closeConfirmModal() {
            document.getElementById('confirmModal').classList.remove('active');
        }

        // Enhanced delete confirmation
        function confirmDelete(form, itemName = 'item') {
            showConfirmModal(
                'Delete ' + itemName,
                'This action cannot be undone. Are you sure you want to delete this ' + itemName.toLowerCase() + '?',
                function () {
                    form.submit();
                }
            );
        }

        // Admin delete confirmation with animation
        function confirmDeleteAdmin(adminId, adminName) {
            showConfirmModal(
                'Delete Administrator',
                `Are you sure you want to delete administrator "${adminName}"? This action cannot be undone.`,
                function () {
                    deleteAdminWithAnimation(adminId, adminName);
                }
            );
        }

        function deleteAdminWithAnimation(adminId, adminName) {
            const form = document.getElementById('deleteForm' + adminId);
            const row = form.closest('tr');

            // Add deleting class for animation
            row.classList.add('deleting');

            // Submit form after animation starts
            setTimeout(() => {
                form.submit();
            }, 250); // Half of animation duration

            // Show success notification
            showNotification('success', 'Admin Deleted', `Administrator "${adminName}" has been successfully deleted.`);
        }

        // Notification System
        let notificationId = 0;

        function showNotification(type, title, message, duration = 5000) {
            const container = document.getElementById('notificationContainer');
            const id = ++notificationId;

            const icons = {
                success: 'fas fa-check',
                error: 'fas fa-times',
                warning: 'fas fa-exclamation',
                info: 'fas fa-info'
            };

            const notification = document.createElement('div');
            notification.className = `notification ${type}`;
            notification.id = `notification-${id}`;

            notification.innerHTML = `
                <div class="notification-icon">
                    <i class="${icons[type]}"></i>
                </div>
                <div class="notification-content">
                    <div class="notification-title">${title}</div>
                    <div class="notification-message">${message}</div>
                </div>
                <button class="notification-close" onclick="removeNotification(${id})">
                    <i class="fas fa-times"></i>
                </button>
                <div class="notification-progress"></div>
            `;

            container.appendChild(notification);

            // Auto remove after duration
            setTimeout(() => removeNotification(id), duration);

            return id;
        }

        function removeNotification(id) {
            const notification = document.getElementById(`notification-${id}`);
            if (notification) {
                notification.style.animation = 'slideInRight 0.3s ease reverse';
                setTimeout(() => {
                    if (notification.parentNode) {
                        notification.parentNode.removeChild(notification);
                    }
                }, 300);
            }
        }

        // Initialize notification system
        function initNotificationSystem() {
            console.log('🔔 Initializing notification system');
            // Show Laravel session messages as notifications
            @if(session('success'))
                console.log('✅ Session success message found');
                showNotification('success', 'Success', '{{ session('success') }}');
            @endif

            @if(session('error'))
                showNotification('error', 'Error', '{{ session('error') }}');
            @endif

            @if($errors->any())
                showNotification('error', 'Validation Error', '{{ $errors->first() }}');
            @endif
        }

        // Notification Panel Functions
        function toggleNotificationPanel() {
            const panel = document.getElementById('notificationPanel');
            const isVisible = panel.style.display === 'block';

            if (isVisible) {
                panel.style.display = 'none';
            } else {
                panel.style.display = 'block';
                loadNotifications();
            }
        }

        function loadNotifications() {
            // Use the web route for admin notifications
            fetch('/admin/notifications/pending', {
                method: 'GET',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                credentials: 'same-origin'
            })
                .then(response => response.json())
                .then(data => {
                    const list = document.getElementById('notificationList');
                    const badge = document.getElementById('notificationBadge');
                    const sidebarBadge = document.getElementById('sidebarNotificationBadge');

                    if (data.success && data.data && data.data.length > 0) {
                        list.innerHTML = '';
                        data.data.forEach(notification => {
                            const item = createNotificationItem(notification);
                            list.appendChild(item);
                        });

                        const count = data.data.length;
                        badge.textContent = count;
                        badge.style.display = 'flex';
                        sidebarBadge.textContent = count;
                        sidebarBadge.style.display = 'inline';
                    } else {
                        list.innerHTML = `
                        <div style="padding: var(--space-xl); text-align: center; color: var(--text-grey);">
                            <i class="fas fa-bell-slash" style="font-size: 2rem; margin-bottom: var(--space-sm); opacity: 0.3;"></i>
                            <p>No new notifications</p>
                        </div>
                    `;
                        badge.style.display = 'none';
                        sidebarBadge.style.display = 'none';
                    }
                })
                .catch(error => {
                    console.log('Failed to load notifications:', error);
                    // Fallback to empty state
                    const list = document.getElementById('notificationList');
                    list.innerHTML = `
                    <div style="padding: var(--space-xl); text-align: center; color: var(--text-grey);">
                        <i class="fas fa-exclamation-triangle" style="font-size: 2rem; margin-bottom: var(--space-sm); opacity: 0.3;"></i>
                        <p>Failed to load notifications</p>
                    </div>
                `;
                });
        }

        function createNotificationItem(notification) {
            const item = document.createElement('div');
            item.style.cssText = 'padding: var(--space-md); border-bottom: 1px solid var(--border-grey); cursor: pointer; transition: var(--transition);';
            item.onmouseover = () => item.style.background = 'var(--off-white)';
            item.onmouseout = () => item.style.background = 'transparent';

            const icons = {
                success: 'fas fa-check-circle',
                error: 'fas fa-exclamation-circle',
                warning: 'fas fa-exclamation-triangle',
                info: 'fas fa-info-circle'
            };

            const colors = {
                success: '#10B981',
                error: '#EF4444',
                warning: '#F59E0B',
                info: '#3B82F6'
            };

            item.innerHTML = `
                <div style="display: flex; align-items: flex-start; gap: var(--space-sm);">
                    <i class="${icons[notification.type] || icons.info}" style="color: ${colors[notification.type] || colors.info}; margin-top: 2px;"></i>
                    <div style="flex: 1;">
                        <div style="font-weight: 600; color: var(--text-dark); font-size: 0.85rem; margin-bottom: 2px;">${notification.title}</div>
                        <div style="color: var(--text-grey); font-size: 0.8rem; line-height: 1.3;">${notification.message}</div>
                    </div>
                </div>
            `;

            return item;
        }

        function markAllAsRead() {
            fetch('/admin/notifications/read-all', {
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    'Accept': 'application/json'
                }
            })
                .then(() => {
                    document.getElementById('notificationBadge').style.display = 'none';
                    loadNotifications();
                })
                .catch(error => console.log('Failed to mark notifications as read:', error));
        }

        // Real-time notifications via polling
        let lastNotificationCount = 0;
        let hasShownInitialNotification = false;

        function initRealTimeNotifications() {
            setInterval(checkForNewNotifications, 10000); // Check every 10 seconds for faster updates
        }

        function checkForNewNotifications() {
            fetch('/admin/notifications/pending', {
                method: 'GET',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                credentials: 'same-origin'
            })
                .then(response => response.json())
                .then(data => {
                    const badge = document.getElementById('notificationBadge');
                    const sidebarBadge = document.getElementById('sidebarNotificationBadge');

                    if (data.success && data.data && data.data.length > 0) {
                        const count = data.data.length;
                        badge.textContent = count;
                        badge.style.display = 'flex';
                        sidebarBadge.textContent = count;
                        sidebarBadge.style.display = 'inline';

                        // Only show toast if count increased (new registration)
                        if (hasShownInitialNotification && count > lastNotificationCount) {
                            showNotification(
                                'info',
                                'New User Registration',
                                `There ${count > 1 ? 'are' : 'is'} ${count} pending user registration${count > 1 ? 's' : ''} requiring approval.`,
                                5000
                            );
                        }
                        
                        lastNotificationCount = count;
                        hasShownInitialNotification = true;
                    } else {
                        badge.style.display = 'none';
                        sidebarBadge.style.display = 'none';
                        lastNotificationCount = 0;
                    }
                })
                .catch(error => console.log('Notification check failed:', error));
        }

        // Close notification panel when clicking outside
        document.addEventListener('click', function (event) {
            const panel = document.getElementById('notificationPanel');
            const button = event.target.closest('[onclick="toggleNotificationPanel()"]');

            if (!panel.contains(event.target) && !button) {
                panel.style.display = 'none';
            }
        });

        // Notifications Page Functions
        function showNotificationsPage() {
            transitionToPage(() => {
                const contentArea = document.querySelector('.content-area');
                contentArea.innerHTML = `
                <div class="content-card">
                    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <h3 class="card-title">
                            <i class="fas fa-bell"></i>
                            User Approval Notifications
                        </h3>
                        <button onclick="refreshNotifications()" style="background: repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0 6px, transparent 6px 24px), linear-gradient(135deg, #0e1330, #17173a); color: white; border: none; padding: 8px 16px; border-radius: 8px; cursor: pointer; font-size: 0.8rem; position: relative; overflow: hidden;">
                            <!-- Geometric elements -->
                            <div style="position: absolute; width: 180%; height: 120%; left: -40%; top: -10%; transform: rotate(-18deg); background: linear-gradient(180deg, rgba(36, 26, 70, 0.98) 0%, rgba(28, 20, 58, 0.95) 100%); clip-path: polygon(10% 0, 100% 0, 90% 100%, 0% 100%); pointer-events: none;"></div>
                            <div style="position: absolute; width: 15px; height: 15px; right: 3px; top: 25%; border-radius: 50%; background: radial-gradient(circle at 30% 30%, #ff6f2d 0%, #ff9b57 45%, rgba(255, 111, 45, 0.85) 60%, transparent 70%); opacity: 0.8; pointer-events: none;"></div>
                            <span style="position: relative; z-index: 2;"><i class="fas fa-sync-alt"></i> Refresh</span>
                        </button>
                    </div>
                    <div id="notificationsContent" style="padding: var(--space-lg);">
                        <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
                            <i class="fas fa-spinner fa-spin" style="font-size: 2rem; margin-bottom: var(--space-md);"></i>
                            <p>Loading notifications...</p>
                        </div>
                    </div>
                </div>
            `;

                // Update active nav link
                document.querySelectorAll('.nav-link').forEach(link => link.classList.remove('active'));
                event.target.closest('.nav-link').classList.add('active');

                loadUserApprovalNotifications();
            });
        }

        function loadUserApprovalNotifications() {
            fetch('/admin/notifications/pending', {
                method: 'GET',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                credentials: 'same-origin'
            })
                .then(response => response.json())
                .then(data => {
                    const content = document.getElementById('notificationsContent');

                    if (data.success && data.data.length > 0) {
                        content.innerHTML = data.data.map(notification => `
                        <div style="background: var(--white); border: 1px solid var(--border-grey); border-radius: var(--radius-md); padding: var(--space-lg); margin-bottom: var(--space-md); box-shadow: var(--shadow-soft);">
                            <div style="display: flex; justify-content: between; align-items: flex-start; gap: var(--space-md);">
                                <div style="flex: 1;">
                                    <h4 style="color: var(--text-dark); font-size: 1rem; font-weight: 600; margin-bottom: var(--space-sm);">${notification.title}</h4>
                                    <p style="color: var(--text-grey); margin-bottom: var(--space-md); font-size: 0.9rem;">${notification.message}</p>
                                    
                                    ${notification.user ? `
                                        <div style="background: var(--light-grey); padding: var(--space-md); border-radius: var(--radius-sm); margin-bottom: var(--space-md);">
                                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: var(--space-sm); font-size: 0.85rem;">
                                                <div><strong>ID:</strong> ${notification.user.display_id || 'USR-' + notification.user.id}</div>
                                                <div><strong>Name:</strong> ${notification.user.name}</div>
                                                <div><strong>Email:</strong> ${notification.user.email}</div>
                                                <div><strong>Role:</strong> ${notification.user.role}</div>
                                                <div><strong>Phone:</strong> ${notification.user.phone || 'N/A'}</div>
                                                <div><strong>Status:</strong> <span style="color: #F59E0B; font-weight: 600;">Pending Approval</span></div>
                                            </div>
                                        </div>
                                    ` : ''}
                                    
                                    <div style="display: flex; gap: var(--space-sm);">
                                        <button onclick="approveUser(${notification.user?.id})" style="background: #10B981; color: white; border: none; padding: 10px 20px; border-radius: var(--radius-sm); cursor: pointer; font-weight: 500; transition: var(--transition);" onmouseover="this.style.background='#059669'" onmouseout="this.style.background='#10B981'">
                                            <i class="fas fa-check"></i> Approve User
                                        </button>
                                        <button onclick="rejectUser(${notification.user?.id})" style="background: #EF4444; color: white; border: none; padding: 10px 20px; border-radius: var(--radius-sm); cursor: pointer; font-weight: 500; transition: var(--transition);" onmouseover="this.style.background='#DC2626'" onmouseout="this.style.background='#EF4444'">
                                            <i class="fas fa-times"></i> Reject User
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `).join('');
                    } else {
                        content.innerHTML = `
                        <div style="text-align: center; padding: var(--space-2xl); color: var(--text-grey);">
                            <i class="fas fa-bell-slash" style="font-size: 3rem; margin-bottom: var(--space-md); opacity: 0.3;"></i>
                            <h3 style="margin-bottom: var(--space-sm);">No Pending Notifications</h3>
                            <p>All user approval requests have been processed.</p>
                        </div>
                    `;
                    }
                })
                .catch(error => {
                    document.getElementById('notificationsContent').innerHTML = `
                    <div style="text-align: center; padding: var(--space-2xl); color: #EF4444;">
                        <i class="fas fa-exclamation-triangle" style="font-size: 2rem; margin-bottom: var(--space-md);"></i>
                        <p>Failed to load notifications</p>
                    </div>
                `;
                });
        }

        function approveUser(userId) {
            fetch(`/admin/notifications/approve-user/${userId}`, {
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                credentials: 'same-origin'
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showNotification('success', 'Success', 'User approved successfully');
                        setTimeout(() => {
                            loadUserApprovalNotifications();
                            updateNotificationBadges();
                            checkForNewNotifications(); // Immediate refresh
                        }, 500);
                    } else {
                        showNotification('error', 'Error', data.message || 'Failed to approve user');
                    }
                })
                .catch(() => showNotification('error', 'Error', 'Failed to approve user'));
        }

        function rejectUser(userId) {
            showConfirmModal(
                'Reject User',
                'Are you sure you want to reject this user? This action cannot be undone.',
                function () {
                    fetch(`/admin/notifications/reject-user/${userId}`, {
                        method: 'POST',
                        headers: {
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                            'Accept': 'application/json',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        credentials: 'same-origin'
                    })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                showNotification('success', 'Success', 'User rejected successfully');
                                setTimeout(() => {
                                    loadUserApprovalNotifications();
                                    updateNotificationBadges();
                                    checkForNewNotifications(); // Immediate refresh
                                }, 500);
                            } else {
                                showNotification('error', 'Error', data.message || 'Failed to reject user');
                            }
                        })
                        .catch(() => showNotification('error', 'Error', 'Failed to reject user'));
                }
            );
        }

        function refreshNotifications() {
            const refreshBtn = event.target;
            refreshBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Refreshing';
            refreshBtn.disabled = true;

            setTimeout(() => {
                loadUserApprovalNotifications();
                updateNotificationBadges();
                checkForNewNotifications();

                refreshBtn.innerHTML = '<i class="fas fa-sync-alt"></i> Refresh';
                refreshBtn.disabled = false;
            }, 1000);
        }

        function updateNotificationBadges() {
            fetch('/admin/notifications/pending', {
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                credentials: 'same-origin'
            })
                .then(response => response.json())
                .then(data => {
                    const count = data.success ? data.data.length : 0;
                    const sidebarBadge = document.getElementById('sidebarNotificationBadge');
                    const headerBadge = document.getElementById('notificationBadge');

                    if (count > 0) {
                        sidebarBadge.textContent = count;
                        sidebarBadge.style.display = 'inline';
                        headerBadge.textContent = count;
                        headerBadge.style.display = 'flex';
                    } else {
                        sidebarBadge.style.display = 'none';
                        headerBadge.style.display = 'none';
                    }
                })
                .catch(error => console.log('Failed to update badges:', error));
        }

        // Simple page transition
        function transitionToPage(callback) {
            const contentArea = document.querySelector('.content-area');
            contentArea.style.opacity = '0.7';

            setTimeout(() => {
                if (callback) callback();
                contentArea.style.opacity = '1';
            }, 100);
        }

        // Enhanced real-time notifications
        let notificationInterval;

        function startNotificationPolling() {
            updateNotificationBadges(); // Initial load

            // Clear existing interval
            if (notificationInterval) {
                clearInterval(notificationInterval);
            }

            // Start polling every 3 seconds for faster updates
            notificationInterval = setInterval(() => {
                updateNotificationBadges();
                checkForNewNotifications();
            }, 3000);
        }

        // Start real-time notifications
        document.addEventListener('DOMContentLoaded', function () {
            console.log('🚀 Layout DOMContentLoaded - Starting notification systems');
            initRealTimeNotifications();
            startNotificationPolling();

            // Refresh when page becomes visible (user switches back to tab)
            document.addEventListener('visibilitychange', function () {
                if (!document.hidden) {
                    updateNotificationBadges();
                    checkForNewNotifications();
                }
            });
        });
    </script>
</body>

</html>
