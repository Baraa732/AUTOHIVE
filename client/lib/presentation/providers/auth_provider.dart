import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import '../../core/network/auth_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _clearStoredAuth();
  }


  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.login(phone, password);
      if (result['success'] == true && result['user'] != null) {
        final user = User.fromJson(result['user']);
        await _storeAuth(result['token'], user);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        throw Exception(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '').trim();
      final finalError = errorMsg.isEmpty ? 'Login failed. Please try again.' : errorMsg;
      state = state.copyWith(
        error: finalError,
        isLoading: false,
      );
    }
  }

  Future<void> register(String firstName, String lastName, String phone, String password, String city, String governorate) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.register(firstName, lastName, phone, password, city, governorate);
      if (result['success'] == true && result['data'] != null) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      } else {
        throw Exception(result['message'] ?? 'Registration failed');
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '').trim();
      state = state.copyWith(
        error: errorMsg.isEmpty ? 'Registration failed. Please try again.' : errorMsg,
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    try {
      // Call logout API if needed
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }
    await _clearStoredAuth();
    state = const AuthState(isAuthenticated: false, user: null);
  }

  Future<void> _storeAuth(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson())); // Use jsonEncode instead of toString
  }

  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});