import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import 'navigation_screen.dart';
import '../../providers/auth_provider.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isConnected = ref.watch(isConnectedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(isDark),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFff6f2d)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: Stack(
        children: [
          const NavigationScreen(),
          if (!isConnected)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.red,
                child: Text(
                  l10n.translate('no_internet'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
