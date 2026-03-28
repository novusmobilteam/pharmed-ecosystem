import 'package:dio/dio.dart';

import '../storage/auth/auth.dart';
import 'token_interceptor.dart';

class APIManager {
  final Dio _dio;
  final AuthStorageNotifier _authNotifier;

  static const _baseUrl = 'https://developer.novusyazilim.com/agena/api';

  APIManager({
    required Dio dio,
    required AuthStorageNotifier authNotifier,
  })  : _dio = dio,
        _authNotifier = authNotifier {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.clear();

    _dio.interceptors.addAll([
      TokenInterceptor(authNotifier: _authNotifier),
      LogInterceptor(requestBody: true),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters, Object? data}) async {
    try {
      final Response<dynamic> response = await _dio.delete<dynamic>(
        path,
        queryParameters: queryParameters,
        data: data,
      );
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> put(String path, {Object? data}) async {
    try {
      final Response<dynamic> response = await _dio.put<dynamic>(path, data: data);
      return response;
    } on DioException catch (_) {
      rethrow;
    }
  }
}
