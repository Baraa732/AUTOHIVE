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
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthNotifier(this._authService) : super(const AuthState()) {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);
      
      if (token != null && userData != null && token.isNotEmpty && userData.isNotEmpty) {
        try {
          // Parse JSON properly instead of using Uri.splitQueryString
          final Map<String, dynamic> userMap = Map<String, dynamic>.from(
            jsonDecode(userData)
          );
          final user = User.fromJson(userMap);
          state = state.copyWith(user: user, isAuthenticated: true);
        } catch (e) {
          await _clearStoredAuth();
        }
      } else {
        // Ensure we start with unauthenticated state if no valid data
        state = const AuthState(isAuthenticated: false);
      }
    } catch (e) {
      // Silently handle errors during auth loading
      await _clearStoredAuth();
      state = const AuthState(isAuthenticated: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.login(email, password);
      final user = User.fromJson(result['user']);
      
      await _storeAuth(result['token'], user);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> register(String firstName, String lastName, String phone, String password, String role, String city, String governorate) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.register(firstName, lastName, phone, password, role, city, governorate);
      final user = User.fromJson(result['user']);
      
      await _storeAuth(result['token'], user);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
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