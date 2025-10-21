import 'package:ai_trip_planner/features/trip/data/models/user_model.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthInitial());

  Future<void> login(String username, String password) async {
    state = AuthLoading();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      if (username == 'test' && password == 'password') {
        const token = 'fake-jwt-token';
        final user = User(username: username, email: 'user@example.com');
        state = Authenticated(token, user);
      } else {
        state = const AuthError('Invalid username or password');
      }
    } catch (e) {
      state = const AuthError('An unexpected error occurred');
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    state = AuthLoading();
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        const token = 'fake-jwt-token';
        final user = User(username: username, email: email);
        state = Authenticated(token, user);
      } else {
        state = const AuthError('Please fill all fields');
      }
    } catch (e) {
      state = const AuthError('An unexpected error occurred');
    }
  }

  void logout() {
    state = AuthInitial();
  }
}
