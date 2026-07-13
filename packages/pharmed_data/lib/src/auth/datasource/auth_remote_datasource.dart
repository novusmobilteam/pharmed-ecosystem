// packages/pharmed_data/lib/src/auth/datasource/auth_remote_datasource.dart
//
// [SWREQ-DATA-AUTH-001]
// Sadece login endpoint'ini çağırır, token string döndürür.
// Plain Dio kullanılır — login endpoint'i token gerektirmez,
// ApiManager (interceptor'lı) yerine ham Dio doğru tercih.
// getCurrentUser sorumluluğu UserDataSource'tadır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

abstract interface class IAuthRemoteDataSource {
  Future<String> login({required String email, required String password, String? macAddress});
  Future<String> loginWithBadge({required String cardData, String? macAddress});
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  const AuthRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<String> login({required String email, required String password, String? macAddress}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/Login/login',
      data: {'email': email, 'password': password, if (macAddress != null) 'macAddress': macAddress},
    );

    // ApiResponse<String> yapısı: { "isSuccess": true, "data": "<token>" }
    final body = response.data!;
    final data = body['data'];

    if (data is! String || data.isEmpty) {
      throw ServiceException(message: contextlessL10n().authError_invalidTokenResponse, statusCode: 500);
    }

    return data;
  }

  @override
  Future<String> loginWithBadge({required String cardData, String? macAddress}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/Login/loginManageCard/$cardData',
      data: {'manageCardValue': cardData, if (macAddress != null) 'macAddress': macAddress},
    );

    final body = response.data!;
    final data = body['data'];

    if (data is! String || data.isEmpty) {
      throw ServiceException(message: contextlessL10n().authError_invalidTokenResponse, statusCode: 500);
    }

    return data;
  }
}
