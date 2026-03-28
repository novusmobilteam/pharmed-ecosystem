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

abstract interface class IAuthRemoteDataSource {
  Future<String> login({required String email, required String password, String? macAddress});
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
      throw const ServiceException(message: 'Sunucudan geçersiz token yanıtı alındı', statusCode: 500);
    }

    return data;
  }
}
