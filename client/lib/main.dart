import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection.dart';
import 'core/core.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/shared/main_navigation_screen.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await configureDependencies();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: 'AUTOHIVE',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppInitializer(),
      builder: (context, child) {
        return Directionality(
          textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: AnnotatedRegion(
            value: isDarkMode 
              ? const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Color(0xFF0F0F23),
                  systemNavigationBarIconBrightness: Brightness.light,
                )
              : const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Color(0xFFF8FAFC),
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
            child: child!,
          ),
        );
      },
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    final authState = ref.watch(authProvider);
    
    // Always show welcome screen if not authenticated or no user data
    if (!authState.isAuthenticated || authState.user == null) {
      return const WelcomeScreen();
    }
    
    return const MainNavigationScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'AUTOHIVE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
