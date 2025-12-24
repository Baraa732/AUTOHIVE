import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';
import '../tenant/tenant_navigation_screen.dart';
import '../landlord/landlord_navigation_screen.dart';
import '../../providers/auth_provider.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isConnected = ref.watch(isConnectedProvider);

    // Show loading only if auth is still loading
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
        ),
      );
    }

    // Use auth user data or fallback to default tenant
    final user = authState.user?.toJson() ?? {'role': 'tenant'};

    // Route to appropriate navigation based on user role
    Widget navigationScreen;
    if (user['role'] == 'landlord') {
      navigationScreen = const LandlordNavigationScreen();
    } else {
      navigationScreen = const TenantNavigationScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          navigationScreen,
          // Network status indicator
          if (!isConnected)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.red,
                child: const Text(
                  'No internet connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
