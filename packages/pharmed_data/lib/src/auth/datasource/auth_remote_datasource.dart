// packages/pharmed_data/lib/src/auth/datasource/auth_remote_datasource.dart
//
// [SWREQ-DATA-AUTH-001]
// Login ve oturum yenileme (refresh) endpoint'lerini çağırır,
// access + refresh token çiftini döndürür.
// Plain Dio kullanılır — login endpoint'i token gerektirmez,
// ApiManager (interceptor'lı) yerine ham Dio doğru tercih.
// getCurrentUser sorumluluğu UserDataSource'tadır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Login / refresh yanıtından okunan token çifti.
///
/// Yanıt yapısı: `{ "isSuccess": true, "data": "<accessToken>", "refreshToken": "<refreshToken>" }`
/// [refreshToken] eski sunucu sürümlerinde dönmeyebilir → null.
class AuthSessionTokens {
  const AuthSessionTokens({required this.accessToken, this.refreshToken});

  final String accessToken;
  final String? refreshToken;
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthSessionTokens> login({
    required String email,
    required String password,
    String? macAddress,
    int? stationId,
  });
  Future<AuthSessionTokens> loginWithBadge({required String cardData, String? macAddress});
  Future<AuthSessionTokens> loginWithFingerprint(FingerprintLoginRequestDTO request);

  /// [SWREQ-DATA-AUTH-005] POST /Login/session/refresh — yeni token çifti.
  /// Refresh token geçersiz/süresi dolmuşsa sunucu 4xx döner (DioException).
  Future<AuthSessionTokens> refreshSession({required String refreshToken});
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  const AuthRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<AuthSessionTokens> login({
    required String email,
    required String password,
    String? macAddress,
    int? stationId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/Login/login',
      data: {
        'email': email,
        'password': password,
        if (macAddress != null) 'macAddress': macAddress,
        if (stationId != null) 'stationId': stationId,
      },
    );

    return _parseTokens(response.data);
  }

  @override
  Future<AuthSessionTokens> loginWithBadge({required String cardData, String? macAddress}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/Login/loginManageCard/$cardData',
      data: {'manageCardValue': cardData, if (macAddress != null) 'macAddress': macAddress},
    );

    return _parseTokens(response.data);
  }

  /// [SWREQ-FP-103] POST /Login/loginFingerprint — eşleşen kullanıcının token'ı.
  /// Eşleşme yoksa sunucu 401 döner (bkz. API dokümanı).
  @override
  Future<AuthSessionTokens> loginWithFingerprint(FingerprintLoginRequestDTO request) async {
    final body = request.toJson();
    _debugPrintFingerprintLoginBody(body);
    final response = await _dio.post<Map<String, dynamic>>('/Login/loginFingerprint', data: body);

    return _parseTokens(response.data);
  }

  /// [SWREQ-DATA-AUTH-005] Plain Dio ile çağrılır — TokenInterceptor'dan geçmez,
  /// böylece refresh isteğinin kendi 401'i yeniden refresh döngüsü başlatamaz.
  @override
  Future<AuthSessionTokens> refreshSession({required String refreshToken}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/Login/session/refresh',
      data: {'refreshToken': refreshToken},
    );

    return _parseTokens(response.data);
  }

  /// ApiResponse yapısı: `{ "isSuccess": true, "data": "<accessToken>", "refreshToken": "<refreshToken>" }`
  AuthSessionTokens _parseTokens(Map<String, dynamic>? body) {
    final data = body?['data'];

    if (data is! String || data.isEmpty) {
      throw ServiceException(message: contextlessL10n().authError_invalidTokenResponse, statusCode: 500);
    }

    final refresh = body?['refreshToken'];
    return AuthSessionTokens(accessToken: data, refreshToken: refresh is String && refresh.isNotEmpty ? refresh : null);
  }

  /// Servise giden gövdeyi konsola basar — YALNIZCA debug build'de çalışır
  /// (assert içinde; release/profile'da derleyici tamamen atar).
  /// Gövdede biyometrik şablon var: MedLogger'a (kalıcı log dosyası)
  /// bilerek YAZILMAZ (KVKK).
  static void _debugPrintFingerprintLoginBody(Map<String, dynamic> body) {
    assert(() {
      // ignore: avoid_print
      print('[FP-LOGIN] POST /Login/loginFingerprint body:\n${const JsonEncoder.withIndent('  ').convert(body)}');
      return true;
    }());
  }
}
