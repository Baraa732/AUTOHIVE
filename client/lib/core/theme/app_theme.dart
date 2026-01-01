import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavbarThemeData {
  final Color backgroundColor;
  final Color accentColor;
  final Color secondaryColor;
  final Color textLight;
  final Color textDim;
  final double navHeight;
  final double radius;
  final double indicatorSize;
  final double cutoutWidth;
  final double cutoutHeight;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const NavbarThemeData({
    required this.backgroundColor,
    required this.accentColor,
    required this.secondaryColor,
    required this.textLight,
    required this.textDim,
    required this.navHeight,
    required this.radius,
    required this.indicatorSize,
    required this.cutoutWidth,
    required this.cutoutHeight,
    required this.transitionDuration,
    required this.transitionCurve,
  });
}

class AppTheme {
  // Brand Colors - Updated to match welcome screen
  static Color primaryBlue = const Color(0xFF4a90e2);
  static Color primaryPink = const Color(0xFFEC4899);
  static Color primaryOrange = const Color(0xFFff6f2d);
  static Color primaryGreen = const Color(0xFF10B981);
  
  // Dark Theme Colors - Updated to match welcome screen
  static Color darkPrimary = const Color(0xFF0F0F23);
  static Color darkSecondary = const Color(0xFF1A1A2E);
  static Color darkTertiary = const Color(0xFF16213E);
  static Color darkSurface = const Color(0xFF1E1E2E);
  static Color darkCard = const Color(0xFF2A2A3E);
  
  // Light Theme Colors - Updated to match welcome screen
  static Color lightPrimary = const Color(0xFFF8FAFC);
  static Color lightSecondary = const Color(0xFFE2E8F0);
  static Color lightSurface = const Color(0xFFFFFFFF);
  static Color lightCard = const Color(0xFFF1F5F9);
  
  // Gradients - Updated to match welcome screen
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryOrange, primaryBlue],
  );
  
  static LinearGradient get darkBackgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPrimary, darkSecondary, darkTertiary],
    stops: const [0.0, 0.5, 1.0],
  );
  
  static LinearGradient get lightBackgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightPrimary, lightSecondary],
    stops: const [0.0, 1.0],
  );
  
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );
  
  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );
  
  // Text Styles
  static TextStyle get heroTitleDark => const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
  
  static TextStyle get heroTitleLight => const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1E293B),
    height: 1.2,
  );
  
  static TextStyle get titleDark => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static TextStyle get titleLight => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1E293B),
  );
  
  static TextStyle get subtitleDark => const TextStyle(
    fontSize: 16,
    color: Color(0xB3FFFFFF),
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get subtitleLight => const TextStyle(
    fontSize: 16,
    color: Color(0xFF64748B),
    fontWeight: FontWeight.w500,
  );
  
  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: lightPrimary,
    cardColor: lightCard,
    dividerColor: const Color(0xFFE2E8F0),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: titleLight,
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: titleLight,
      displayMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFF334155)),
      bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
      labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(color: Color(0xFF64748B)),
    
    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryPink,
      surface: lightSurface,
      error: const Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1E293B),
      onError: Colors.white,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkPrimary,
    cardColor: darkCard,
    dividerColor: const Color(0xFF374151),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: titleDark,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: titleDark,
      displayMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFFE2E8F0)),
      bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFFB3FFFF)),
      labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(color: Color(0xFFE2E8F0)),
    
    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryPink,
      surface: darkSurface,
      error: const Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
  );

  // Helper methods for backward compatibility
  static BoxDecoration getCardDecoration(bool isDark) => BoxDecoration(
    gradient: isDark ? darkCardGradient : lightCardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
      width: 1,
    ),
  );

  // Additional helper methods
  static LinearGradient getBackgroundGradient(bool isDark) => 
    isDark ? darkBackgroundGradient : lightBackgroundGradient;

  static Color getBackgroundColor(bool isDark) => isDark ? darkPrimary : lightPrimary;
  static Color getCardColor(bool isDark) => isDark ? darkCard : lightCard;
  static Color getBorderColor(bool isDark) => isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0);
  static Color getTextColor(bool isDark) => isDark ? Colors.white : const Color(0xFF1E293B);
  static Color getSubtextColor(bool isDark) => isDark ? const Color(0xB3FFFFFF) : const Color(0xFF64748B);
  
  // Text style helpers
  static TextStyle getHeroTitle(bool isDark) => isDark ? heroTitleDark : heroTitleLight;
  static TextStyle getTitle(bool isDark) => isDark ? titleDark : titleLight;
  static TextStyle getSubtitle(bool isDark) => isDark ? subtitleDark : subtitleLight;
  
  // Button decoration
  static BoxDecoration get buttonDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryBlue.withValues(alpha: 0.4),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // Navbar Theme - Dark
  static NavbarThemeData get darkNavbarTheme => NavbarThemeData(
    backgroundColor: darkCard,
    accentColor: primaryOrange,
    secondaryColor: primaryBlue,
    textLight: const Color(0xFFf8fafc),
    textDim: const Color(0xFF94a3b8),
    navHeight: 72,
    radius: 22,
    indicatorSize: 40,
    cutoutWidth: 80,
    cutoutHeight: 40,
    transitionDuration: const Duration(milliseconds: 550),
    transitionCurve: Curves.easeInOutCubic,
  );

  // Navbar Theme - Light
  static NavbarThemeData get lightNavbarTheme => NavbarThemeData(
    backgroundColor: const Color(0xFFF8FAFC),
    accentColor: primaryOrange,
    secondaryColor: primaryBlue,
    textLight: const Color(0xFF1E293B),
    textDim: const Color(0xFF64748B),
    navHeight: 72,
    radius: 22,
    indicatorSize: 40,
    cutoutWidth: 80,
    cutoutHeight: 40,
    transitionDuration: const Duration(milliseconds: 550),
    transitionCurve: Curves.easeInOutCubic,
  );

  // Get navbar theme based on brightness
  static NavbarThemeData getNavbarTheme(bool isDark) =>
      isDark ? darkNavbarTheme : lightNavbarTheme;
}