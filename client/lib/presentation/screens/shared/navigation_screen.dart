import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../shared/modern_home_screen.dart';
import '../shared/bookings_screen.dart';
import '../shared/favorites_screen.dart';
import '../shared/add_apartment_screen.dart';
import '../shared/profile_screen.dart';
import '../../widgets/common/enhanced_animated_navbar.dart';
import '../../../core/core.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (!authState.isAuthenticated || authState.user == null) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(isDark),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      const ModernHomeScreen(),
      const BookingsScreen(),
      const FavoritesScreen(),
      const AddApartmentScreen(),
      const ProfileScreen(),
    ];

    final List<BottomNavItem> navItems = [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: l10n.translate('home'),
      ),
      BottomNavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: l10n.translate('bookings'),
      ),
      BottomNavItem(
        icon: Icons.favorite_outline,
        activeIcon: Icons.favorite,
        label: l10n.translate('favorites'),
      ),
      BottomNavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: l10n.translate('add'),
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: l10n.translate('profile'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: EnhancedAnimatedNavbar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
      ),
    );
  }
}
