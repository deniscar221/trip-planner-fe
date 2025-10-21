import 'package:ai_trip_planner/features/trip/data/models/user_model.dart';
import 'package:ai_trip_planner/features/trip/domain/repositories/trip_repository.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../injection_container.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(sl<TripRepository>(), sl<FlutterSecureStorage>())
    ..checkAuth();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final TripRepository _tripRepository;
  final FlutterSecureStorage _secureStorage;

  AuthNotifier(this._tripRepository, this._secureStorage) : super(AuthInitial());

  Future<void> checkAuth() async {
    final token = await _secureStorage.read(key: 'token');
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      final user = User(
          username: decodedToken['sub'], email: 'user@example.com');
      state = Authenticated(token, user);
    }
  }

  Future<void> login(String username, String password) async {
    state = AuthLoading();
    try {
      final token = await _tripRepository.signIn(username, password);
      await _secureStorage.write(key: 'token', value: token);
      final decodedToken = JwtDecoder.decode(token);
      final user = User(
          username: decodedToken['sub'], email: 'user@example.com');
      state = Authenticated(token, user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = const AuthError('Invalid username or password');
      } else {
        state = const AuthError('An unexpected error occurred');
      }
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    state = AuthLoading();
    try {
      final token = await _tripRepository.signUp(username, email, password);
      await _secureStorage.write(key: 'token', value: token);
      final decodedToken = JwtDecoder.decode(token);
      final user = User(
          username: decodedToken['sub'], email: 'user@example.com');
      state = Authenticated(token, user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        state = const AuthError('Username or email already exists');
      } else {
        state = const AuthError('An unexpected error occurred');
      }
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
    state = AuthInitial();
  }
}
