// [SWREQ-NET-001] [SWREQ-DATA-AUTH-005]
// Her isteğe Authorization / Accept-Language ekler.
// 401 → refresh token ile oturumu yenile → isteği BİR KEZ tekrar dene.
// Refresh başarısızsa (veya tekrar denenen istek yine 401 alırsa)
// onUnauthorized → oturum kapanır.
// Sınıf: Class B

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'auth_token_provider.dart';

class TokenInterceptor extends Interceptor {
  final AuthTokenProvider _tokenProvider;

  /// 401 sonrası isteği yeniden göndermek için kullanılan Dio (APIManager'ın
  /// kendi Dio'su). null → refresh/retry yapılmaz, eski davranış (401 = logout).
  final Dio? _retryDio;

  TokenInterceptor({required AuthTokenProvider tokenProvider, Dio? retryDio})
    : _tokenProvider = tokenProvider,
      _retryDio = retryDio;

  static const _retriedKey = 'pharmed_auth_retried';

  // Body'si debug'da yazdırılacak endpoint'ler
  static const _debugBodyPaths = <String>[
    '/auth/fingerprint-login', // ← gerçek path ile değiştir
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenProvider.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept-Language'] = _tokenProvider.currentLocale;

    if (kDebugMode && _debugBodyPaths.any(options.path.contains)) {
      debugPrint('[${options.method}] ${options.uri}');
      debugPrint('body: ${_prettyBody(options.data)}');
    }

    return handler.next(options);
  }

  String _prettyBody(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString(); // FormData vb. encode edilemezse
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    final options = err.requestOptions;
    final retryDio = _retryDio;

    // Zaten bir kez yenilenip tekrar denenmiş istek yine 401 → oturum geçersiz.
    if (retryDio == null || options.extra[_retriedKey] == true) {
      _tokenProvider.onUnauthorized();
      return handler.next(err);
    }

    // İstek gönderildikten sonra başka bir istek token'ı zaten yenilemiş
    // olabilir — o durumda yeni refresh atmadan güncel token'la tekrar dene.
    final sentToken = _bearerOf(options);
    final current = _tokenProvider.accessToken;
    final alreadyRefreshed = current != null && current.isNotEmpty && current != sentToken;
    final refreshed = alreadyRefreshed || await _tokenProvider.refreshAccessToken();

    if (!refreshed) {
      _tokenProvider.onUnauthorized();
      return handler.next(err);
    }

    // Tüketilmiş FormData yeniden gönderilemez — klonla; klonlanamıyorsa
    // tekrar deneme (token yenilendi, oturum açık kalır; çağıran hatayı görür).
    final data = options.data;
    if (data is FormData) {
      try {
        options.data = data.clone();
      } catch (_) {
        return handler.next(err);
      }
    }

    options.extra[_retriedKey] = true;
    MedLogger.info(
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-DATA-AUTH-005',
      message: 'Token yenilendi, istek tekrar deneniyor',
      context: {'method': options.method, 'path': options.path},
    );

    try {
      // onRequest yeni token'ı Authorization header'ına yazar.
      final response = await retryDio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      // Tekrar denemenin 401'i kendi onError geçişinde zaten ele alındı.
      return handler.next(e);
    }
  }

  static String? _bearerOf(RequestOptions options) {
    final header = options.headers['Authorization'];
    if (header is! String || !header.startsWith('Bearer ')) return null;
    return header.substring(7);
  }
}
