// packages/pharmed_data/lib/src/network/base_remote_datasource.dart
//
// [SWREQ-NET-002]
// Tüm remote datasource'ların extend ettiği temel sınıf.
// APIManager üzerinden HTTP çağrıları yapar.
// Loglama MedLogger ile yapılır.
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ignore: constant_identifier_names
enum HttpMethod { GET, POST, PUT, DELETE }

enum ResponseEnvelope { auto, apiResponse, raw }

typedef Parser<T> = T? Function(Object? data);

abstract class BaseRemoteDataSource {
  BaseRemoteDataSource({required this.apiManager});

  final APIManager apiManager;

  /// Alt sınıf kendi birim adını bildirir — log'larda görünür.
  /// Örn: 'SW-UNIT-ROLE', 'SW-UNIT-USER'
  String get logUnit;

  /// Alt sınıf kendi SWREQ kodunu bildirir.
  /// Örn: 'SWREQ-DATA-ROLE-001'
  String get logSwreq;

  // ── Yardımcı parser'lar (static — alt sınıflar direkt kullanır) ──────────

  static Parser<T> singleParser<T>(T Function(Map<String, dynamic>) fromJson) {
    return (obj) {
      if (obj is Map<String, dynamic>) return fromJson(obj);
      throw FormatException('Expected Map<String, dynamic> but got ${obj.runtimeType}');
    };
  }

  static Parser<List<T>> listParser<T>(T Function(Map<String, dynamic>) fromJson) {
    return (obj) {
      if (obj is List<dynamic>) {
        return obj.map((e) {
          if (e is Map<String, dynamic>) return fromJson(e);
          throw FormatException('Expected Map<String, dynamic> but got ${e.runtimeType}');
        }).toList();
      }
      throw FormatException('Expected List but got ${obj.runtimeType}');
    };
  }

  static Parser<ApiResponse<List<T>>> apiResponseListParser<T>(T Function(Map<String, dynamic>) fromJson) {
    return (obj) {
      if (obj is List) {
        return ApiResponse<List<T>>(
          isSuccess: true,
          statusCode: 200,
          data: obj.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
        );
      }
      if (obj is Map<String, dynamic>) {
        return ApiResponse<List<T>>.fromJson(obj, (dataJson) {
          if (dataJson is List) {
            return dataJson.map((e) => fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        });
      }
      throw FormatException('Beklenen Map veya List ama gelen: ${obj.runtimeType}');
    };
  }

  static Parser<void> voidParser() => (_) {};

  // ── Public request metodları ─────────────────────────────────────────────

  /// GET — sayfalama, arama ve filter desteği ile.
  Future<Result<T?>> fetchRequest<T>({
    required String path,
    Map<String, dynamic>? query,
    required Parser<T> parser,
    String? successLog,
    String? emptyLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
    int? skip,
    int? take,
    String? searchText,
    List<String>? searchFields,
    String searchOperator = 'contains',
  }) {
    final finalQuery = Map<String, dynamic>.from(query ?? {});

    if (skip != null) finalQuery['skip'] = skip;
    if (take != null) finalQuery['take'] = take;
    if (skip != null || take != null) finalQuery['requireTotalCount'] = true;

    if (searchText != null && searchText.isNotEmpty && searchFields != null && searchFields.isNotEmpty) {
      finalQuery['filter'] = _buildFilter(searchText, searchFields, searchOperator);
    }

    return _request<T>(
      method: HttpMethod.GET,
      path: path,
      query: finalQuery,
      parser: parser,
      successLog: successLog,
      emptyLog: emptyLog,
      envelope: envelope,
    );
  }

  Future<Result<T?>> createRequest<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    required Parser<T> parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) => _request<T>(
    method: HttpMethod.POST,
    path: path,
    body: body,
    query: query,
    parser: parser,
    successLog: successLog,
    envelope: envelope,
  );

  Future<Result<List<T>?>> createBulkRequest<T>({
    required String path,
    required List<Object> body,
    Map<String, dynamic>? query,
    Parser<List<T>>? parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) => _request<List<T>>(
    method: HttpMethod.POST,
    path: path,
    body: body,
    query: query,
    parser: parser,
    successLog: successLog,
    envelope: envelope,
  );

  Future<Result<T?>> updateRequest<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    required Parser<T> parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) => _request<T>(
    method: HttpMethod.PUT,
    path: path,
    body: body,
    query: query,
    parser: parser,
    successLog: successLog,
    envelope: envelope,
  );

  Future<Result<List<T>?>> updateBulkRequest<T>({
    required String path,
    required List<Object> body,
    Map<String, dynamic>? query,
    Parser<List<T>>? parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) => _request<List<T>>(
    method: HttpMethod.PUT,
    path: path,
    body: body,
    query: query,
    parser: parser,
    successLog: successLog,
    envelope: envelope,
  );

  Future<Result<T?>> deleteRequest<T>({
    required String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    required Parser<T> parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) => _request<T>(
    method: HttpMethod.DELETE,
    path: path,
    body: body,
    query: query,
    parser: parser,
    successLog: successLog,
    envelope: envelope,
  );

  Future<Result<List<T>?>> deleteBulkRequest<T>({
    required String path,
    required List<Object> body,
    Map<String, dynamic>? query,
    Parser<List<T>>? parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) => _request<List<T>>(
    method: HttpMethod.DELETE,
    path: path,
    body: body,
    query: query,
    parser: parser,
    successLog: successLog,
    envelope: envelope,
  );

  // ── İç implementasyon ────────────────────────────────────────────────────

  Future<Result<T?>> _request<T>({
    required HttpMethod method,
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Parser<T>? parser,
    String? successLog,
    String? emptyLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) async {
    MedLogger.info(
      unit: logUnit,
      swreq: logSwreq,
      message: '${method.name} $path',
      context: {if (query != null) 'query': query},
    );

    try {
      final response = switch (method) {
        HttpMethod.GET => await apiManager.get(path, queryParameters: query),
        HttpMethod.POST => await apiManager.post(path, data: body, queryParameters: query),
        HttpMethod.PUT => await apiManager.put(path, data: body),
        HttpMethod.DELETE => await apiManager.delete(path, queryParameters: query, data: body),
      };

      // APIManager Result<T> döndürüyor — response burada zaten Result
      // Aşağıdaki blok APIManager'ın ham Dio response döndürdüğü eski yapı için.
      // Yeni yapıda APIManager Result<T> döndürdüğünden bu method imzası
      // güncellenmeli. Şimdilik Response<dynamic> uyumlu tutuluyor.
      final data = (response as dynamic).data;
      final isEmptyBody = data == null || (data is String && data.trim().isEmpty);

      if (isEmptyBody) {
        MedLogger.info(
          unit: logUnit,
          swreq: logSwreq,
          message: emptyLog ?? successLog ?? 'Boş yanıt',
          context: {'path': path},
        );
        return Result.ok(null);
      }

      if (data is Map<String, dynamic>) {
        final shouldTreatAsApiResponse = switch (envelope) {
          ResponseEnvelope.apiResponse => true,
          ResponseEnvelope.raw => false,
          ResponseEnvelope.auto => _looksLikeApiResponse(data),
        };

        if (shouldTreatAsApiResponse) {
          final apiRes = parser != null ? ApiResponse<T?>.fromJson(data, parser) : null;
          final apiError = ApiError.fromJson(data);
          final isSuccess = apiRes?.isSuccess ?? true;

          if (isSuccess) {
            if (apiRes?.data == null) {
              MedLogger.info(
                unit: logUnit,
                swreq: logSwreq,
                message: emptyLog ?? successLog ?? 'Veri boş',
                context: {'path': path},
              );
              return Result.ok(null);
            }
            final count = apiRes?.data is List ? (apiRes?.data as List).length : null;
            MedLogger.info(
              unit: logUnit,
              swreq: logSwreq,
              message: successLog ?? 'Başarılı',
              context: {'path': path, if (count != null) 'count': count},
            );
            return Result.ok(apiRes?.data);
          }

          final msg = apiError.message?.trim().isNotEmpty == true
              ? apiError.message!
              : 'Sunucu hatası. Lütfen daha sonra tekrar deneyiniz.';
          MedLogger.warn(
            unit: logUnit,
            swreq: logSwreq,
            message: msg,
            context: {'path': path, 'statusCode': apiError.statusCode},
          );
          return Result.error(ServiceException(message: msg, statusCode: apiError.statusCode ?? 0));
        }
      }

      // Raw parse
      try {
        final parsed = parser != null ? parser(data) : null;
        final count = parsed is List ? parsed.length : null;
        MedLogger.info(
          unit: logUnit,
          swreq: logSwreq,
          message: successLog ?? 'Başarılı',
          context: {'path': path, if (count != null) 'count': count},
        );
        return Result.ok(parsed);
      } catch (e, stack) {
        MedLogger.error(
          unit: logUnit,
          swreq: logSwreq,
          message: 'Parse hatası',
          context: {'path': path},
          error: e,
          stackTrace: stack,
        );
        return Result.error(MalformedDataException(message: 'Veri işleme hatası', cause: e));
      }
    } on DioException catch (e) {
      final message = _parseDioError(e);
      MedLogger.error(
        unit: logUnit,
        swreq: logSwreq,
        message: 'DioException: ${e.type.name}',
        context: {'path': path, 'statusCode': e.response?.statusCode},
        error: e,
      );
      return Result.error(ServiceException(message: message, statusCode: e.response?.statusCode ?? 0));
    } catch (e, stack) {
      MedLogger.error(
        unit: logUnit,
        swreq: logSwreq,
        message: 'Beklenmedik hata',
        context: {'path': path},
        error: e,
        stackTrace: stack,
      );
      return Result.error(UnexpectedException(cause: e));
    }
  }

  // ── Yardımcılar ──────────────────────────────────────────────────────────

  String _buildFilter(String text, List<String> fields, String operator) {
    if (fields.length == 1) {
      return '["${fields[0]}","$operator","$text"]';
    }
    final conditions = fields.map((field) => '["$field","$operator","$text"]').toList();
    final buffer = StringBuffer('[');
    for (int i = 0; i < conditions.length; i++) {
      buffer.write(conditions[i]);
      if (i < conditions.length - 1) buffer.write(',"or",');
    }
    buffer.write(']');
    return buffer.toString();
  }

  String _parseDioError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is String && data.trim().isNotEmpty) return data;
      if (data is Map<String, dynamic>) {
        return (data['error'] as String?) ?? (data['message'] as String?) ?? 'Bir hata oluştu';
      }
    } catch (_) {}
    return e.message ?? 'Bir hata oluştu';
  }

  bool _looksLikeApiResponse(Map<String, dynamic> m) {
    if (m.containsKey('isSuccess')) return true;
    if (m.containsKey('status') && (m.containsKey('data') || m.containsKey('message'))) return true;
    if (m.containsKey('data') && m.containsKey('totalCount')) return true;
    if (m.containsKey('result') && m.containsKey('message')) return true;
    return false;
  }
}
