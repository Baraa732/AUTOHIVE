import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../providers/locale_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Reduced from 1500ms
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10), // Reduced from 15 seconds
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_backgroundController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(isDarkMode),
            Positioned(
              top: 50,
              right: 20,
              child: Row(
                children: [
                  _buildLanguageToggle(),
                  const SizedBox(width: 8),
                  const ThemeToggleButton(),
                ],
              ),
            ),
            SafeArea(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            _buildLogo(),
                            const SizedBox(height: 40),
                            _buildTitle(),
                            const SizedBox(height: 16),
                            _buildSubtitle(isDarkMode),
                            const Spacer(),
                            _buildLoginButton(context),
                            const SizedBox(height: 16),
                            _buildRegisterButton(context, isDarkMode),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    final isDarkMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDarkMode).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  color: AppTheme.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  isArabic ? 'ع' : 'EN',
                  style: TextStyle(
                    color: AppTheme.getTextColor(isDarkMode),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              right: -50,
              top: 100,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFff6f2d).withValues(alpha: isDark ? 0.3 : 0.1),
                        const Color(0xFF4a90e2).withValues(alpha: isDark ? 0.2 : 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -20,
              top: 300,
              child: Transform.rotate(
                angle: -_rotationAnimation.value * 1.5 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4a90e2).withValues(alpha: isDark ? 0.4 : 0.1),
                        const Color(0xFFff6f2d).withValues(alpha: isDark ? 0.3 : 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 200,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.8 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFff6f2d).withValues(alpha: isDark ? 0.5 : 0.12),
                        const Color(0xFF4a90e2).withValues(alpha: isDark ? 0.3 : 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFff6f2d).withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(Icons.home_work, size: 50, color: Colors.white),
      ),
    );
  }

  Widget _buildTitle() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
        ).createShader(bounds),
        child: const Text(
          'AUTOHIVE',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(
        l10n.translate('your_home_awaits'),
        style: TextStyle(
          fontSize: 16,
          color: AppTheme.getSubtextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFff6f2d).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(l10n.translate('login'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 2,
            color: AppTheme.getBorderColor(isDark),
          ),
          color: AppTheme.getCardColor(isDark),
        ),
        child: OutlinedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(l10n.translate('register'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(isDark))),
        ),
      ),
    );
  }
}
