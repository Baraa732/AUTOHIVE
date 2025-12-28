import 'package:flutter/material.dart';
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/shared/main_navigation_screen.dart';
import '../../presentation/screens/shared/apartment_details_screen.dart';
import '../../presentation/screens/shared/profile_screen.dart';
import '../../presentation/screens/shared/bookings_screen.dart';
import '../../presentation/screens/shared/add_apartment_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String apartmentDetails = '/apartment-details';
  static const String profile = '/profile';
  static const String bookings = '/bookings';
  static const String addApartment = '/add-apartment';

  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const MainNavigationScreen(),
    profile: (context) => const ProfileScreen(),
    bookings: (context) => const BookingsScreen(),
    addApartment: (context) => const AddApartmentScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case apartmentDetails:
        final apartmentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) =>
              ApartmentDetailsScreen(apartmentId: apartmentId),
        );
      default:
        return null;
    }
  }
}
