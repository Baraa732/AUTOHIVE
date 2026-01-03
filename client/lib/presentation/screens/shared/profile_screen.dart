import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/profile_avatar.dart';
import '../../widgets/wallet_balance_widget.dart';
import '../auth/welcome_screen.dart';
import '../wallet/wallet_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.getBackgroundGradient(isDarkMode),
      ),
      child: Stack(
        children: [
          _buildAnimatedBackground(isDarkMode),
          SafeArea(child: _buildContent(isDarkMode, user)),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Widget _buildContent(bool isDark, User? user) {
    if (user == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFff6f2d).withValues(alpha: 0.3),
                      Color(0xFF4a90e2).withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.person_off,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                ).createShader(bounds),
                child: const Text(
                  'Not Logged In',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please login to view your profile',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 200,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFff6f2d).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ProfileAvatar(user: user.toJson(), size: 140, showBorder: true),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
            ).createShader(bounds),
            child: Text(
              '${user.firstName ?? ''} ${user.lastName ?? ''}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.phone ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          if (user.email != null) ...[
            const SizedBox(height: 8),
            Text(
              user.email ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 32),
          _buildWalletSection(),
          _buildThemeToggle(),
          _buildMenuItem(Icons.help, 'Help & Support', () {}),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24), // Extra bottom padding
        ],
      ),
    );
  }

  Widget _buildWalletSection() {
    final wallet = ref.watch(walletProvider);
    if (wallet.wallet != null) {
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WalletScreen(),
                ),
              );
            },
            child: WalletBalanceWidget(compact: true),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildThemeToggle() {
    final isDarkMode = ref.watch(themeProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Theme Mode',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextColor(isDarkMode),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) =>
                ref.read(themeProvider.notifier).toggleTheme(),
            activeThumbColor: const Color(0xFFff6f2d),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    final isDarkMode = ref.watch(themeProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getTextColor(isDarkMode),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.getSubtextColor(isDarkMode),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return Stack(
      children: [
        Positioned(
          right: -50,
          top: 100,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFff6f2d).withValues(alpha: isDark ? 0.3 : 0.1),
                  const Color(
                    0xFF4a90e2,
                  ).withValues(alpha: isDark ? 0.2 : 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: 200,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  const Color(
                    0xFF4a90e2,
                  ).withValues(alpha: isDark ? 0.4 : 0.08),
                  const Color(
                    0xFFff6f2d,
                  ).withValues(alpha: isDark ? 0.3 : 0.06),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
