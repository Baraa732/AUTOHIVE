import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/common/animated_input_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../shared/main_navigation_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  String? _lastShownError;

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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    _lastShownError = null;
    await ref.read(authProvider.notifier).login(
      _phoneController.text.trim(),
      _passwordController.text,
    );
  }

  void _showError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.primaryPink),
            const SizedBox(width: 8),
            Text(
              l10n.translate('login_error'),
              style: TextStyle(
                color: AppTheme.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppTheme.getSubtextColor(isDark),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('ok'),
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);
        
        if (authState.isAuthenticated && authState.user != null) {
          _lastShownError = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                (route) => false,
              );
            }
          });
        }
        
        if (authState.error != null && !authState.isLoading && _lastShownError != authState.error) {
          _lastShownError = authState.error;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showError(authState.error!);
            }
          });
        }
        
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.getBackgroundGradient(isDark),
            ),
            child: Stack(
              children: [
                _buildAnimatedBackground(isDark),
                SafeArea(
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              _buildHeader(isDark, l10n),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 40),
                                        _buildLogo(),
                                        const SizedBox(height: 40),
                                        _buildTitle(isDark, l10n),
                                        const SizedBox(height: 40),
                                        
                                        AnimatedInputField(
                                          controller: _phoneController,
                                          label: l10n.translate('phone_number'),
                                          icon: Icons.phone_outlined,
                                          keyboardType: TextInputType.phone,
                                          isDark: isDark,
                                          hintText: '09xxxxxxxx',
                                          primaryColor: AppTheme.primaryOrange,
                                          secondaryColor: AppTheme.primaryBlue,
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return l10n.translate('phone_required');
                                            }
                                            if (!RegExp(r'^09[0-9]{8}$').hasMatch(value!)) {
                                              return l10n.translate('phone_invalid');
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 20),

                                        AnimatedInputField(
                                          controller: _passwordController,
                                          label: l10n.translate('password'),
                                          icon: Icons.lock_outlined,
                                          isDark: isDark,
                                          hintText: l10n.translate('enter_your_password'),
                                          obscureText: _obscurePassword,
                                          primaryColor: AppTheme.primaryBlue,
                                          secondaryColor: AppTheme.primaryOrange,
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return l10n.translate('password_required');
                                            }
                                            return null;
                                          },
                                          onTap: () {
                                            setState(() => _obscurePassword = !_obscurePassword);
                                          },
                                        ),

                                        const SizedBox(height: 40),
                                        _buildLoginButton(authState.isLoading, l10n),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      },
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
                        AppTheme.primaryOrange.withValues(alpha: isDark ? 0.3 : 0.1),
                        AppTheme.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.05),
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
                        AppTheme.primaryBlue.withValues(alpha: isDark ? 0.4 : 0.1),
                        AppTheme.primaryOrange.withValues(alpha: isDark ? 0.3 : 0.08),
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

  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.getBorderColor(isDark)),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.getTextColor(isDark)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
                    ).createShader(bounds),
                    child: Text(
                      l10n.translate('welcome_back'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextColor(isDark),
                      ),
                    ),
                  ),
                  Text(
                    l10n.translate('sign_in_to_continue'),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.getSubtextColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 80,
        height: 80,
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
        child: const Icon(Icons.home_work, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildTitle(bool isDark, AppLocalizations l10n) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
            ).createShader(bounds),
            child: const Text(
              'AUTOHIVE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('your_home_awaits'),
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getSubtextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading, AppLocalizations l10n) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
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
          onPressed: isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  l10n.translate('login'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
