import 'package:ai_trip_planner/features/trip/data/models/user_model.dart';
import 'package.flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial());

  void login(String username, String password) async {
    state = const AuthState.loading();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      const token = 'fake-jwt-token';
      final user = User(username: username, email: 'user@example.com');
      state = AuthState.authenticated(token, user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void logout() {
    state = const AuthState.initial();
  }
}
