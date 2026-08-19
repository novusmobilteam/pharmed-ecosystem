// packages/pharmed_data/lib/src/network/api_manager.dart
//
// [SWREQ-NET-001]
// Merkezi HTTP istemcisi.
// DioException → AppException dönüşümü tek yer.
// Her istek/yanıt MedLogger ile izlenir.
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'auth_token_provider.dart';
import 'token_interceptor.dart';

class APIManager {
  APIManager({
    required String baseUrl,
    required AuthTokenProvider tokenProvider,
    Duration connectTimeout = const Duration(seconds: 60),
    Duration receiveTimeout = const Duration(seconds: 0),
    List<Interceptor>? extraInterceptors,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
           headers: {'Content-Type': 'application/json'},
         ),
       ) {
    _dio.interceptors.addAll([TokenInterceptor(tokenProvider: tokenProvider), ...?extraInterceptors]);
  }

  final Dio _dio;

  // ── Public HTTP metodları ─────────────────────────────────────

  /// parser null → Result<void> döner
  Future<Result<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, T Function(dynamic)? parser}) =>
      _execute(
        call: () => _dio.get<dynamic>(path, queryParameters: queryParameters),
        parser: parser,
        method: 'GET',
        path: path,
      );

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) => _execute(
    call: () => _dio.post<dynamic>(path, data: data, queryParameters: queryParameters),
    parser: parser,
    method: 'POST',
    path: path,
  );

  Future<Result<T>> put<T>(String path, {dynamic data, T Function(dynamic)? parser}) => _execute(
    call: () => _dio.put<dynamic>(path, data: data),
    parser: parser,
    method: 'PUT',
    path: path,
  );

  Future<Result<T>> patch<T>(String path, {dynamic data, T Function(dynamic)? parser}) => _execute(
    call: () => _dio.patch<dynamic>(path, data: data),
    parser: parser,
    method: 'PATCH',
    path: path,
  );

  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) => _execute(
    call: () => _dio.delete<dynamic>(path, data: data, queryParameters: queryParameters),
    parser: parser,
    method: 'DELETE',
    path: path,
  );

  // ── İç implementasyon ─────────────────────────────────────────

  Future<Result<T>> _execute<T>({
    required Future<Response<dynamic>> Function() call,
    required T Function(dynamic)? parser,
    required String method,
    required String path,
  }) async {
    MedLogger.info(
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-001',
      message: '$method isteği başlatıldı',
      context: {'path': path},
    );

    try {
      final response = await call();
      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      MedLogger.info(
        unit: 'SW-UNIT-NET',
        swreq: 'SWREQ-NET-001',
        message: '$method yanıt alındı',
        context: {'path': path, 'status': statusCode},
      );

      // parser null → void dönüş
      if (parser == null) {
        return Result.ok(null as T);
      }

      // boş body
      if (body == null || (body is String && body.trim().isEmpty)) {
        MedLogger.warn(
          unit: 'SW-UNIT-NET',
          swreq: 'SWREQ-NET-001',
          message: 'Boş yanıt gövdesi',
          context: {'path': path, 'status': statusCode},
        );
        return Result.error(EmptyResponseException(message: contextlessL10n().dataError_emptyResponse));
      }

      try {
        return Result.ok(parser(body));
      } catch (e, stack) {
        MedLogger.error(
          unit: 'SW-UNIT-NET',
          swreq: 'SWREQ-NET-001',
          message: 'Parse hatası',
          context: {'path': path},
          error: e,
          stackTrace: stack,
        );
        return Result.error(MalformedDataException(message: contextlessL10n().dataError_malformedResponse, cause: e));
      }
    } on DioException catch (e) {
      final exception = _mapDioException(e, path);
      return Result.error(exception);
    } catch (e, stack) {
      MedLogger.error(
        unit: 'SW-UNIT-NET',
        swreq: 'SWREQ-NET-001',
        message: 'Beklenmedik hata',
        context: {'path': path},
        error: e,
        stackTrace: stack,
      );
      return Result.error(UnexpectedException(cause: e));
    }
  }

  // ── Exception mapping — tek yer ──────────────────────────────
  // [SWREQ-NET-005] [IEC 62304 §9.2]

  AppException _mapDioException(DioException e, String path) {
    // Her durumda önce response body'den mesaj okumaya çalış
    final msg = _extractResponseMessage(e) ?? e.message;

    final exception = switch (e.type) {
      DioExceptionType.connectionTimeout || DioExceptionType.receiveTimeout || DioExceptionType.sendTimeout =>
        TimeoutException(message: msg ?? contextlessL10n().dataError_requestTimeout, cause: e),
      DioExceptionType.connectionError => NetworkUnavailableException(
        message: msg ?? contextlessL10n().dataError_networkUnavailable,
        cause: e,
      ),
      DioExceptionType.badResponse => ServiceException(
        message: msg ?? contextlessL10n().dataError_genericApiError,
        statusCode: e.response?.statusCode ?? 0,
        traceId: e.response?.headers.value('x-trace-id'),
        cause: e,
      ),
      DioExceptionType.cancel => UnexpectedException(
        message: msg ?? contextlessL10n().dataError_requestCancelled,
        cause: e,
      ),
      _ => UnexpectedException(message: msg ?? contextlessL10n().dataError_genericApiError, cause: e),
    };

    MedLogger.error(
      unit: 'SW-UNIT-NET',
      swreq: 'SWREQ-NET-001',
      message: 'DioException: ${e.type.name}',
      context: {'path': path, 'statusCode': e.response?.statusCode},
      error: e,
    );

    return exception;
  }

  String? _extractResponseMessage(DioException e) {
    final data = e.response?.data;
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map<String, dynamic>) {
      const candidates = ['error', 'message', 'title', 'detail', 'errorMessage', 'description'];
      for (final key in candidates) {
        final val = data[key];
        if (val is String && val.trim().isNotEmpty) return val.trim();
      }
    }
    return null;
  }
}
