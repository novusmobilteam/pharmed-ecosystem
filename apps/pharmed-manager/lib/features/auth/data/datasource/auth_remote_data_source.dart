import 'package:dio/dio.dart';

import '../../../../core/core.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<ApiResponse<String>> login({
    required String email,
    required String password,
    required String macAddress,
  }) async {
    final response = await _dio.post(
      '/Login/login',
      data: {'email': email, 'password': password, 'macAddress': macAddress},
    );

    return ApiResponse<String>.fromJson(response.data as Map<String, dynamic>, (json) => json as String);
  }
}
