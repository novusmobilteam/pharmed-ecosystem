import 'package:dio/dio.dart';
import 'auth_token_provider.dart';

import 'dart:convert';

import 'package:flutter/foundation.dart';

class TokenInterceptor extends Interceptor {
  final AuthTokenProvider _tokenProvider;

  TokenInterceptor({required AuthTokenProvider tokenProvider}) : _tokenProvider = tokenProvider;

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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _tokenProvider.onUnauthorized();
    }
    return handler.next(err);
  }
}
