// lib/core/network/network_manager.dart
//
// [SWREQ-NET-001]
// Merkezi HTTP istemcisi.
//
// Sorumluluklar:
//   - Tüm HTTP metodları (GET, POST, PATCH, DELETE)
//   - DioException → AppException dönüşümü (tek yer)
//   - Her istek/yanıt MedLogger ile izlenir
//   - Result<T> döner — exception asla dışarı sızmaz
//
// Datasource'lar bu sınıfı kullanır, Dio'yu doğrudan bilmez.
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:result_dart/result_dart.dart';
import '../exception/app_exceptions.dart';
import '../logging/med_logger.dart';

// ─────────────────────────────────────────────────────────────────
// NetworkRequest — istek parametrelerini taşır
// ─────────────────────────────────────────────────────────────────

class NetworkRequest {
  const NetworkRequest({required this.path, required this.swreq, this.queryParameters, this.body, this.headers});

  final String path;

  /// İzlenebilirlik için gereksinim referansı
  final String swreq;

  final Map<String, dynamic>? queryParameters;
  final dynamic body;
  final Map<String, String>? headers;
}

// ─────────────────────────────────────────────────────────────────
// NetworkManager
// ─────────────────────────────────────────────────────────────────

class NetworkManager {
  NetworkManager({
    required String baseUrl,
    required Duration connectTimeout,
    required Duration receiveTimeout,
    List<Interceptor>? interceptors,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
           headers: {'Content-Type': 'application/json'},
         ),
       ) {
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  final Dio _dio;

  // ── Public HTTP metodları ─────────────────────────────────────

  /// [SWREQ-NET-001] GET isteği
  /// [T extends Object] — result_dart Object bound zorunluluğu
  Future<Result<T>> get<T extends Object>(NetworkRequest request, T Function(dynamic data) parser) async {
    return _execute(
      swreq: request.swreq,
      path: request.path,
      method: 'GET',
      call: () => _dio.get<dynamic>(
        request.path,
        queryParameters: request.queryParameters,
        options: Options(headers: request.headers),
      ),
      parser: parser,
    );
  }

  /// [SWREQ-NET-002] POST isteği — void dönüş
  Future<Result<Unit>> post(NetworkRequest request) async {
    return _executeVoid(
      swreq: request.swreq,
      path: request.path,
      method: 'POST',
      call: () => _dio.post<dynamic>(
        request.path,
        data: request.body,
        options: Options(headers: request.headers),
      ),
    );
  }

  /// [SWREQ-NET-003] PATCH isteği — void dönüş
  Future<Result<Unit>> patch(NetworkRequest request) async {
    return _executeVoid(
      swreq: request.swreq,
      path: request.path,
      method: 'PATCH',
      call: () => _dio.patch<dynamic>(
        request.path,
        data: request.body,
        options: Options(headers: request.headers),
      ),
    );
  }

  /// [SWREQ-NET-004] DELETE isteği — void dönüş
  Future<Result<Unit>> delete(NetworkRequest request) async {
    return _executeVoid(
      swreq: request.swreq,
      path: request.path,
      method: 'DELETE',
      call: () => _dio.delete<dynamic>(
        request.path,
        data: request.body,
        options: Options(headers: request.headers),
      ),
    );
  }

  // ── İç implementasyon ────────────────────────────────────────

  Future<Result<T>> _execute<T extends Object>({
    required String swreq,
    required String path,
    required String method,
    required Future<Response<dynamic>> Function() call,
    required T Function(dynamic) parser,
  }) async {
    MedLogger.info(unit: 'SW-UNIT-NET', swreq: swreq, message: '$method isteği başlatıldı', context: {'path': path});

    try {
      final response = await call();
      return _parseResponse<T>(response: response, swreq: swreq, path: path, parser: parser);
    } on DioException catch (e) {
      final exception = _mapDioException(e, swreq, path);
      return Failure(exception);
    } catch (e, stack) {
      MedLogger.error(
        unit: 'SW-UNIT-NET',
        swreq: swreq,
        message: '$method beklenmedik hata',
        context: {'path': path},
        error: e,
        stackTrace: stack,
      );
      return Failure(UnexpectedException(cause: e));
    }
  }

  Future<Result<Unit>> _executeVoid({
    required String swreq,
    required String path,
    required String method,
    required Future<Response<dynamic>> Function() call,
  }) async {
    MedLogger.info(unit: 'SW-UNIT-NET', swreq: swreq, message: '$method isteği başlatıldı', context: {'path': path});

    try {
      final response = await call();
      final status = response.statusCode ?? 0;

      if (status >= 200 && status < 300) {
        MedLogger.info(
          unit: 'SW-UNIT-NET',
          swreq: swreq,
          message: '$method başarılı',
          context: {'path': path, 'status': status},
        );
        return const Success(unit);
      }

      return Failure(_mapStatusCode(status, swreq, path));
    } on DioException catch (e) {
      return Failure(_mapDioException(e, swreq, path));
    } catch (e, stack) {
      MedLogger.error(
        unit: 'SW-UNIT-NET',
        swreq: swreq,
        message: '$method beklenmedik hata',
        context: {'path': path},
        error: e,
        stackTrace: stack,
      );
      return Failure(UnexpectedException(cause: e));
    }
  }

  Result<T> _parseResponse<T extends Object>({
    required Response<dynamic> response,
    required String swreq,
    required String path,
    required T Function(dynamic) parser,
  }) {
    final status = response.statusCode ?? 0;

    if (status < 200 || status >= 300) {
      return Failure(_mapStatusCode(status, swreq, path));
    }

    final body = response.data;

    if (body == null) {
      MedLogger.warn(
        unit: 'SW-UNIT-NET',
        swreq: swreq,
        message: 'Boş yanıt gövdesi',
        context: {'path': path, 'status': status},
      );
      return Failure(const EmptyResponseException(message: 'Servis boş yanıt döndürdü'));
    }

    try {
      final parsed = parser(body);
      MedLogger.info(
        unit: 'SW-UNIT-NET',
        swreq: swreq,
        message: 'Yanıt başarıyla işlendi',
        context: {'path': path, 'status': status},
      );
      return Success(parsed);
    } catch (e, stack) {
      MedLogger.error(
        unit: 'SW-UNIT-NET',
        swreq: swreq,
        message: 'JSON parse hatası',
        context: {'path': path},
        error: e,
        stackTrace: stack,
      );
      return Failure(MalformedDataException(message: 'Yanıt beklenen formatta değil', cause: e));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Exception mapping — tek yer, tüm datasource'lar buradan beslenir
  // [SWREQ-NET-005] [IEC 62304 §9.2]
  // ─────────────────────────────────────────────────────────────

  AppException _mapDioException(DioException e, String swreq, String path) {
    final exception = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => TimeoutException(message: 'İstek zaman aşımına uğradı', cause: e),
      DioExceptionType.connectionError => NetworkUnavailableException(message: 'Ağa bağlanılamadı', cause: e),
      DioExceptionType.badResponse => ServiceException(
        message: 'Sunucu hata döndürdü',
        statusCode: e.response?.statusCode ?? 0,
        traceId: e.response?.headers.value('x-trace-id'),
        cause: e,
      ),
      DioExceptionType.cancel => UnexpectedException(message: 'İstek iptal edildi', cause: e),
      _ => UnexpectedException(cause: e),
    };

    MedLogger.error(
      unit: 'SW-UNIT-NET',
      swreq: swreq,
      message: 'DioException: ${e.type.name}',
      context: {'path': path},
      error: e,
    );

    return exception;
  }

  AppException _mapStatusCode(int status, String swreq, String path) {
    MedLogger.error(
      unit: 'SW-UNIT-NET',
      swreq: swreq,
      message: 'Beklenmedik HTTP durum kodu: $status',
      context: {'path': path, 'status': status},
    );

    return ServiceException(message: 'HTTP $status', statusCode: status);
  }
}
