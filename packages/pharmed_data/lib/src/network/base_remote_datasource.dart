import 'dart:convert';

import 'package:pharmed_core/pharmed_core.dart'; // Result, ApiResponse, ApiError vb. buradan geldiğini varsayıyorum
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum HttpMethod { GET, POST, PUT, DELETE }

enum ResponseEnvelope { auto, apiResponse, raw }

typedef Parser<T> = T? Function(Object? data);

abstract class BaseRemoteDataSource {
  final APIManager apiManager;

  BaseRemoteDataSource({required this.apiManager});

  /// Alt sınıflar loglarda görünmesi için kendi birim adını tanımlar.
  String get logUnit;
  String get logSwreq;

  // ── Statik Yardımcı Parser'lar ─────────────────────────────────────────────

  static Parser<T> singleParser<T>(T Function(Map<String, dynamic>) fromJson) {
    return (obj) {
      if (obj is Map<String, dynamic>) return fromJson(obj);
      throw FormatException('Expected Map but got ${obj.runtimeType}');
    };
  }

  static Parser<List<T>> listParser<T>(T Function(Map<String, dynamic>) fromJson) {
    return (obj) {
      if (obj is List) {
        return obj.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      }
      throw FormatException('Expected List but got ${obj.runtimeType}');
    };
  }

  /// String, int, double gibi primitif tipler için liste parser'ı.
  /// `fromJson` callback'i olmadığı için [listParser]'dan ayrıdır.
  static Parser<List<T>> primitiveListParser<T>() {
    return (obj) {
      if (obj is List) return obj.cast<T>();
      throw FormatException('Expected List but got ${obj.runtimeType}');
    };
  }

  static Parser<ApiResponse<List<T>>> apiResponseListParser<T>(T Function(Map<String, dynamic>) fromJson) {
    return (obj) {
      // Eğer raw envelope ile tüm Map geldiyse
      if (obj is Map<String, dynamic>) {
        return ApiResponse<List<T>>.fromJson(obj, (dataJson) {
          if (dataJson is List) {
            return dataJson.map((e) => fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        });
      }
      // Eğer otomatik soyulmuş bir List geldiyse (Fallback)
      if (obj is List) {
        return ApiResponse<List<T>>(
          isSuccess: true,
          statusCode: 200,
          data: obj.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
        );
      }
      throw FormatException('Unexpected type for ApiResponse: ${obj.runtimeType}');
    };
  }

  static Parser<void> voidParser() => (_) {};

  // ── İstek Metodları ────────────────────────────────────────────────────────
  // ── Create (POST) ──────────────────────────────────────────────────────────

  Future<Result<T?>> postRequest<T>({
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
      successLog: successLog ?? 'Kayıt başarıyla oluşturuldu',
      envelope: envelope,
    );
  }

  Future<Result<List<T>?>> postBulkRequest<T>({
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
      successLog: successLog ?? 'Toplu kayıt başarıyla oluşturuldu',
      envelope: envelope,
    );
  }

  // ── Update (PUT) ──────────────────────────────────────────────────────────

  Future<Result<T?>> putRequest<T>({
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
      successLog: successLog ?? 'Güncelleme başarılı',
      envelope: envelope,
    );
  }

  Future<Result<List<T>?>> putBulkRequest<T>({
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
      successLog: successLog ?? 'Toplu güncelleme başarılı',
      envelope: envelope,
    );
  }

  // ── Delete (DELETE) ───────────────────────────────────────────────────────

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
      successLog: successLog ?? 'Silme işlemi başarılı',
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
      successLog: successLog ?? 'Toplu silme işlemi başarılı',
      envelope: envelope,
    );
  }

  Future<Result<T?>> fetchRequest<T>({
    required String path,
    Map<String, dynamic>? query,
    required Parser<T> parser,
    String? successLog,
    String? emptyLog,
    ResponseEnvelope envelope = ResponseEnvelope.auto,
    int? skip,
    int? take,
    String? searchQuery,
    List<String>? searchFields,
    String searchOperator = 'contains',
    String? dateField,
    DateTime? startDate,
    DateTime? endDate,
    List<Object>? filters,
  }) {
    final finalQuery = Map<String, dynamic>.from(query ?? {});
    if (skip != null) finalQuery['skip'] = skip;
    if (take != null) finalQuery['take'] = take;
    if (skip != null || take != null) finalQuery['requireTotalCount'] = true;

    final filter = _buildFilter(
      searchText: searchQuery,
      searchFields: searchFields,
      searchOperator: searchOperator,
      dateField: dateField,
      startDate: startDate,
      endDate: endDate,
      filters: filters,
    );

    if (filter != null) finalQuery['filter'] = filter;

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

  // createRequest, updateRequest vb. metodları da benzer şekilde _request'e yönlendirebilirsin...

  // ── Ana İstek Yönetimi ──────────────────────────────────────────────────────

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
      message: '${method.name} başlatıldı: $path',
      context: {'query': query, 'body': body},
    );

    try {
      // APIManager'a parser'ı geçiyoruz ki APIManager Result.ok(null) dönmesin.
      final result = await switch (method) {
        HttpMethod.GET => apiManager.get<dynamic>(path, queryParameters: query, parser: (d) => d),
        HttpMethod.POST => apiManager.post<dynamic>(path, data: body, queryParameters: query, parser: (d) => d),
        HttpMethod.PUT => apiManager.put<dynamic>(path, data: body, parser: (d) => d),
        HttpMethod.DELETE => apiManager.delete<dynamic>(path, queryParameters: query, data: body, parser: (d) => d),
      };

      return result.when(
        ok: (rawData) {
          if (rawData == null || (rawData is String && rawData.trim().isEmpty)) {
            MedLogger.info(unit: logUnit, swreq: logSwreq, message: emptyLog ?? 'Boş yanıt');
            return Result.ok(null);
          }

          // Veri Map ise ApiResponse kontrolü yapıyoruz (Envelope mantığı)
          if (rawData is Map<String, dynamic>) {
            final shouldTreatAsApiResponse = switch (envelope) {
              ResponseEnvelope.apiResponse => true,
              ResponseEnvelope.raw => false,
              ResponseEnvelope.auto => _looksLikeApiResponse(rawData),
            };

            if (shouldTreatAsApiResponse) {
              final apiRes = parser != null ? ApiResponse<T?>.fromJson(rawData, parser) : null;
              final isSuccess = apiRes?.isSuccess ?? true;

              if (isSuccess) {
                if (apiRes?.data == null) {
                  MedLogger.info(unit: logUnit, swreq: logSwreq, message: emptyLog ?? 'Veri null');
                  return Result.ok(null);
                }
                MedLogger.info(unit: logUnit, swreq: logSwreq, message: successLog ?? 'Başarılı');
                return Result.ok(apiRes?.data);
              } else {
                final apiError = ApiError.fromJson(rawData);
                MedLogger.warn(unit: logUnit, swreq: logSwreq, message: apiError.message ?? 'Hata');
                return Result.error(
                  ServiceException(
                    message: apiError.message ?? contextlessL10n().dataError_envelopeErrorFallback,
                    statusCode: apiError.statusCode ?? 0,
                  ),
                );
              }
            }
          }

          // Raw Parse (Envelope raw ise veya data Map değilse direkt burası çalışır)
          try {
            final parsed = parser != null ? parser(rawData) : null;
            MedLogger.info(unit: logUnit, swreq: logSwreq, message: successLog ?? 'Başarılı');
            return Result.ok(parsed);
          } catch (e) {
            MedLogger.error(unit: logUnit, swreq: logSwreq, message: 'Parse Hatası', error: e);
            return Result.error(MalformedDataException(cause: e, message: ''));
          }
        },
        error: (failure) {
          MedLogger.error(unit: logUnit, swreq: logSwreq, message: 'İstek Hatası', error: failure);
          return Result.error(failure);
        },
      );
    } catch (e, stack) {
      MedLogger.error(unit: logUnit, swreq: logSwreq, message: 'Beklenmedik Hata', error: e, stackTrace: stack);
      return Result.error(UnexpectedException(cause: e));
    }
  }

  bool _looksLikeApiResponse(Map<String, dynamic> m) {
    return m.containsKey('isSuccess') ||
        (m.containsKey('status') && m.containsKey('data')) ||
        (m.containsKey('data') && m.containsKey('totalCount'));
  }

  /// Build a DevExtreme filter expression combining search and date range filters.
  /// Returns null if both are empty.
  String? _buildFilter({
    String? searchText,
    List<String>? searchFields,
    String searchOperator = 'contains',
    String? dateField,
    DateTime? startDate,
    DateTime? endDate,
    List<Object>? filters,
  }) {
    final parts = <Object>[
      if (_buildSearchPart(searchText, searchFields, searchOperator) case final s?) s,
      if (_buildDatePart(dateField, startDate, endDate) case final d?) d,
      if (filters != null) ...filters,
    ];

    if (parts.isEmpty) return null;
    if (parts.length == 1) return jsonEncode(parts.first);

    final joined = <Object>[];
    for (var i = 0; i < parts.length; i++) {
      joined.add(parts[i]);
      if (i < parts.length - 1) joined.add('and');
    }
    return jsonEncode(joined);
  }

  Object? _buildSearchPart(String? text, List<String>? fields, String operator) {
    if (text == null || text.isEmpty || fields == null || fields.isEmpty) return null;
    if (fields.length == 1) return [fields[0], operator, text];

    final parts = <Object>[];
    for (var i = 0; i < fields.length; i++) {
      parts.add([fields[i], operator, text]);
      if (i < fields.length - 1) parts.add('or');
    }
    return parts;
  }

  Object? _buildDatePart(String? dateField, DateTime? start, DateTime? end) {
    if (dateField == null || (start == null && end == null)) return null;
    if (start != null && end != null) {
      return [
        [dateField, '>=', start.toIso8601String()],
        'and',
        [dateField, '<=', end.toIso8601String()],
      ];
    }
    if (start != null) return [dateField, '>=', start.toIso8601String()];
    return [dateField, '<=', end!.toIso8601String()];
  }
}
