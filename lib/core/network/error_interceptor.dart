import 'package:ai_trip_planner/features/trip/presentation/provider/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorInterceptor extends Interceptor {
  final ProviderContainer _container;

  ErrorInterceptor(this._container);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _container.read(authProvider.notifier).logout();
    }
    super.onError(err, handler);
  }
}
