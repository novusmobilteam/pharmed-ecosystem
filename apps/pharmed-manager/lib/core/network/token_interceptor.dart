import 'package:dio/dio.dart';

import '../storage/auth/auth.dart';

class TokenInterceptor extends Interceptor {
  final AuthStorageNotifier _authNotifier;

  TokenInterceptor({
    required AuthStorageNotifier authNotifier,
  }) : _authNotifier = authNotifier;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _authNotifier.accessToken;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _authNotifier.clearAuth();
    }

    return handler.next(err);
  }
}
