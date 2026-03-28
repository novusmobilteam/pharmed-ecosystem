// packages/pharmed_data/lib/src/auth/interceptor/auth_interceptor.dart
//
// [SWREQ-DATA-AUTH-004]
// Her request'e Authorization header ekler.
// 401 gelirse AuthNotifier.logout() tetikler — oturum düşer.
// logout endpoint'ine token eklenmez (zaten geçersizdir).
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';

/// AuthInterceptor oluştururken dışarıdan iki callback alır:
///   tokenProvider : Hive'dan güncel token okur
///   onUnauthorized: 401 gelince AuthNotifier.logout() çağırır
///
/// Riverpod referansı burada tutulmaz — döngüsel bağımlılığı önler.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required Future<String?> Function() tokenProvider, required void Function() onUnauthorized})
    : _tokenProvider = tokenProvider,
      _onUnauthorized = onUnauthorized;

  final Future<String?> Function() _tokenProvider;
  final void Function() _onUnauthorized;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _onUnauthorized();
    }
    handler.next(err);
  }
}
