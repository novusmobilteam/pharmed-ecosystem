import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../core.dart';

// ignore: constant_identifier_names
enum HttpMethod { GET, POST, PUT, DELETE }

enum ResponseEnvelope { auto, apiResponse, raw }

typedef Parser<T> = T? Function(Object? data);

abstract class BaseRemoteDataSource with Logging {
  final APIManager apiManager;

  BaseRemoteDataSource({required this.apiManager});

  @override
  String get loggerName => runtimeType.toString();

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
    String? searchField, // Örn: 'name', 'title', 'barcode'
    String searchOperator = 'contains',
    // Tek alan: searchFields: ['name']
    // Çok alan: searchFields: ['name', 'surname', 'registrationNumber']
    List<String>? searchFields,
  }) {
    // 1. Mevcut query varsa onu al, yoksa yeni oluştur
    final finalQuery = query ?? <String, dynamic>{};

    // 2. Pagination Parametreleri
    if (skip != null) finalQuery['skip'] = skip;
    if (take != null) finalQuery['take'] = take;

    // Pagination yapılacaksa bu parametre zorunlu
    if (skip != null || take != null) {
      finalQuery['requireTotalCount'] = true;
    }

    // Tek alan:  ["name","contains","ahmet"]
    // Çok alan:  [["name","contains","ahmet"],"or",["surname","contains","ahmet"]]
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
      operation: 'fetchRequest',
      envelope: envelope,
    );
  }

  /// DevExtreme filter formatı üretir.
  /// Tek alan  → '["name","contains","ahmet"]'
  /// Çok alan  → '[["name","contains","ahmet"],"or",["surname","contains","ahmet"]]'
  String _buildFilter(String text, List<String> fields, String operator) {
    if (fields.length == 1) {
      return '["${fields[0]}","$operator","$text"]';
    }

    final conditions = fields.map((field) => '["$field","$operator","$text"]').toList();

    // Koşullar arasına "or" ekle: [cond1, "or", cond2, "or", cond3]
    final buffer = StringBuffer('[');
    for (int i = 0; i < conditions.length; i++) {
      buffer.write(conditions[i]);
      if (i < conditions.length - 1) buffer.write(',"or",');
    }
    buffer.write(']');
    return buffer.toString();
  }

  Future<Result<T?>> createRequest<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    required Parser<T> parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) {
    return _request<T>(
      method: HttpMethod.POST,
      path: path,
      body: body,
      query: query,
      parser: parser,
      successLog: successLog,
      operation: 'createRequest',
      envelope: envelope,
    );
  }

  Future<Result<List<T>?>> createBulkRequest<T>({
    required String path,
    required List<Object> body,
    Map<String, dynamic>? query,
    Parser<List<T>>? parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) {
    return _request<List<T>>(
      method: HttpMethod.POST,
      path: path,
      body: body,
      query: query,
      parser: parser,
      successLog: successLog,
      operation: 'createBulkRequest',
      envelope: envelope,
    );
  }

  Future<Result<T?>> updateRequest<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    required Parser<T> parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) {
    return _request<T>(
      method: HttpMethod.PUT,
      path: path,
      body: body,
      query: query,
      parser: parser,
      successLog: successLog,
      operation: 'updateRequest',
      envelope: envelope,
    );
  }

  Future<Result<List<T>?>> updateBulkRequest<T>({
    required String path,
    required List<Object> body,
    Map<String, dynamic>? query,
    Parser<List<T>>? parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) {
    return _request<List<T>>(
      method: HttpMethod.PUT,
      path: path,
      body: body,
      query: query,
      parser: parser,
      successLog: successLog,
      operation: 'updateBulkRequest',
      envelope: envelope,
    );
  }

  Future<Result<T?>> deleteRequest<T>({
    required String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    required Parser<T> parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) {
    return _request<T>(
      method: HttpMethod.DELETE,
      path: path,
      body: body,
      query: query,
      parser: parser,
      successLog: successLog,
      operation: 'deleteRequest',
      envelope: envelope,
    );
  }

  Future<Result<List<T>?>> deleteBulkRequest<T>({
    required String path,
    required List<Object> body,
    Map<String, dynamic>? query,
    Parser<List<T>>? parser,
    String? successLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) {
    return _request<List<T>>(
      method: HttpMethod.DELETE,
      path: path,
      body: body,
      query: query,
      parser: parser,
      successLog: successLog,
      operation: 'deleteBulkRequest',
      envelope: envelope,
    );
  }

  Future<Result<T?>> _request<T>({
    required HttpMethod method,
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Parser<T>? parser,
    String? successLog,
    String? emptyLog,
    required String operation,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
  }) async {
    // debugPrint('=== API REQUEST DEBUG ===');
    // debugPrint('Method: $method');
    // debugPrint('Path: $path');
    // debugPrint('Request Body: $body');

    try {
      final response = switch (method) {
        HttpMethod.GET => await apiManager.get(path, queryParameters: query),
        HttpMethod.POST => await apiManager.post(path, data: body, queryParameters: query),
        HttpMethod.PUT => await apiManager.put(path, data: body),
        HttpMethod.DELETE => await apiManager.delete(path, queryParameters: query, data: body),
      };

      // debugPrint('Response Status: ${response.statusCode}');
      // debugPrint('Response Type: ${response.data.runtimeType}');
      // debugPrint('Response Data: ${response.data}');
      // debugPrint('=========================');

      final data = response.data;
      //final statusCode = response.statusCode;
      final isEmptyBody = data == null || (data is String && data.trim().isEmpty);

      if (isEmptyBody) {
        logOp(operation: operation, status: LogStatus.success, message: successLog);
        return Result.ok(null);
      }

      // if (statusCode == 201) {
      //   final created = parser != null ? parser(data) : null;
      //   logOp(
      //     operation: operation,
      //     status: LogStatus.success,
      //     message: successLog ?? 'Created',
      //     count: created is List ? created.length : null,
      //   );
      //
      //   return Result.ok(created);
      // }

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
              final msg = emptyLog ?? successLog;
              logOp(operation: operation, status: LogStatus.success, message: msg);
              return Result.ok(null);
            }
            final count = (apiRes?.data is List) ? (apiRes?.data as List).length : null;
            logOp(operation: operation, status: LogStatus.success, message: successLog, count: count);
            return Result.ok(apiRes?.data);
          }

          final msg = apiError.message?.trim().isNotEmpty == true
              ? apiError.message!
              : (apiError.message?.trim().isNotEmpty == true
                    ? apiError.message!
                    : 'Sunucu hatası. Lütfen daha sonra tekrar deneyiniz.');
          logOp(operation: operation, status: LogStatus.failure, message: msg, statusCode: apiError.statusCode);
          return Result.error(CustomException(message: msg));
        }

        try {
          final parsed = parser != null ? parser(data) : null;
          logOp(
            operation: operation,
            status: LogStatus.success,
            message: successLog,
            count: parsed is List ? parsed.length : null,
          );
          return Result.ok(parsed);
        } catch (e) {
          logOp(operation: operation, status: LogStatus.exception, message: 'Parser error: $e');
          return Result.error(CustomException(message: 'Veri işleme hatası: $e'));
        }
      }

      try {
        final parsed = parser != null ? parser(data) : null;
        logOp(
          operation: operation,
          status: LogStatus.success,
          message: successLog,
          count: parsed is List ? parsed.length : null,
        );
        return Result.ok(parsed);
      } catch (e) {
        logOp(operation: operation, status: LogStatus.exception, message: 'Parser error: $e');
        return Result.error(CustomException(message: 'Veri işleme hatası: $e'));
      }
    } on DioException catch (e) {
      String? message;
      int? code = e.response?.statusCode;

      final data = e.response?.data;

      debugPrint('Error Message: ${e.message}');
      debugPrint(data?.toString());

      if (data is String && data.trim().isNotEmpty) {
        message = data;
      } else if (data is Map<String, dynamic>) {
        message = (data['error']) as String?;
        final raw = data['status'] ?? data['code'];
        if (raw is num) code = raw.toInt();
      }

      logOp(operation: operation, status: LogStatus.exception, message: message, statusCode: code);
      return Result.error(CustomException(message: message, statusCode: code));
    } catch (e) {
      logOp(operation: operation, status: LogStatus.exception, message: e.toString());
      return Result.error(CustomException(message: e.toString()));
    }
  }
}

Parser<T> singleParser<T>(T Function(Map<String, dynamic>) fromJson) {
  return (obj) {
    if (obj is Map<String, dynamic>) {
      return fromJson(obj);
    }
    throw FormatException('Expected Map<String, dynamic> but got ${obj.runtimeType}');
  };
}

Parser<List<T>> listParser<T>(T Function(Map<String, dynamic>) fromJson) {
  return (obj) {
    if (obj is List<dynamic>) {
      return obj.map((e) {
        if (e is Map<String, dynamic>) {
          return fromJson(e);
        }
        throw FormatException('Expected Map<String, dynamic> but got ${e.runtimeType}');
      }).toList();
    }
    throw FormatException('Expected List but got ${obj.runtimeType}');
  };
}

Parser<ApiResponse<List<T>>> apiResponseListParser<T>(T Function(Map<String, dynamic>) fromJson) {
  return (obj) {
    // Eğer obj zaten bir List ise (fetchRequest data'yı soyup göndermiş demektir)
    if (obj is List) {
      return ApiResponse<List<T>>(
        isSuccess: true,
        statusCode: 200,
        data: obj.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      );
    }

    // Eğer obj tüm gövde (Map) ise
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

Parser<void> voidParser() => (_) {};

bool _looksLikeApiResponse(Map<String, dynamic> m) {
  // Daha spesifik kontrol
  if (m.containsKey('status') && (m.containsKey('data') || m.containsKey('message'))) {
    return true;
  }
  if (m.containsKey('data') && m.containsKey('totalCount')) {
    return true;
  }
  // Yeni kontroller
  if (m.containsKey('isSuccess')) return true;
  if (m.containsKey('result') && m.containsKey('message')) return true;

  return false;
}
