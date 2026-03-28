import 'package:dio/dio.dart';
import 'auth_token_provider.dart';

class TokenInterceptor extends Interceptor {
  final AuthTokenProvider _tokenProvider;

  TokenInterceptor({required AuthTokenProvider tokenProvider}) : _tokenProvider = tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenProvider.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _tokenProvider.onUnauthorized();
    }
    return handler.next(err);
  }
}
