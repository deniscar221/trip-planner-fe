import 'package:ai_trip_planner/features/trip/data/models/user_model.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthInitial());

  void login(String username, String password) async {
    state = AuthLoading();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      const token = 'fake-jwt-token';
      final user = User(username: username, email: 'user@example.com');
      state = Authenticated(token, user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  void logout() {
    state = AuthInitial();
  }
}
