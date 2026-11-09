// [SWREQ-NET-006] [IEC 62304 §9.2]
// Her HTTP isteğini ve sonucunu tek bir korelasyon id'si (`req`) ile loglar:
//   → istek   : method, path, query, gövde (hassas alanlar maskeli)
//   ← yanıt   : status, süre; zarf `isSuccess=false` ise yanıt gövdesi
//   ✕ hata    : status, süre, yanıt gövdesi, Dio hata tipi
// Amaç: sahadaki bir cihazda "işlem neden kesildi" sorusunun, hangi servise
// hangi parametrelerle gidildiği ve servisin ne döndüğüyle cevaplanabilmesi.
//
// Sınıf: Class B

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class NetworkLogInterceptor extends Interceptor {
  static const _unit = 'SW-UNIT-NET';
  static const _swreq = 'SWREQ-NET-006';
  static const _idKey = 'logRequestId';
  static const _watchKey = 'logStopwatch';

  static int _seq = 0;

  /// İsteğin korelasyon id'si — diğer loglar (ör. APIManager hata eşlemesi)
  /// aynı isteği işaret etmek için kullanır.
  static String? requestIdOf(RequestOptions options) => options.extra[_idKey] as String?;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = 'r${++_seq}';
    options.extra[_idKey] = id;
    options.extra[_watchKey] = Stopwatch()..start();

    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: '→ ${options.method} ${options.path}',
      context: {
        'req': id,
        if (options.queryParameters.isNotEmpty) 'query': LogRedactor.redact(options.queryParameters),
        if (options.data != null) 'body': LogRedactor.compact(options.data),
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final data = response.data;
    final base = _base(options, response.statusCode);

    // 200 dönüp zarfta başarısızlık bildiren servisler (`isSuccess: false`).
    if (data is Map && data['isSuccess'] == false) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreq,
        message: '← ${options.method} ${options.path} isSuccess=false',
        context: {...base, 'response': LogRedactor.compact(data)},
      );
    } else {
      MedLogger.info(unit: _unit, swreq: _swreq, message: '← ${options.method} ${options.path}', context: base);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    MedLogger.error(
      unit: _unit,
      swreq: _swreq,
      message: '✕ ${options.method} ${options.path} (${err.type.name})',
      context: {
        ..._base(options, err.response?.statusCode),
        if (err.response?.data != null) 'response': LogRedactor.compact(err.response?.data),
        if (err.message != null) 'dioMessage': err.message,
        if (err.error != null) 'cause': err.error.toString(),
      },
    );
    handler.next(err);
  }

  Map<String, dynamic> _base(RequestOptions options, int? status) {
    final watch = options.extra[_watchKey];
    return {
      'req': options.extra[_idKey],
      'status': ?status,
      if (watch is Stopwatch) 'ms': watch.elapsedMilliseconds,
    };
  }
}

/// Log'a yazılan istek/yanıt gövdelerinden hassas alanları maskeler ve
/// boyutu sınırlar.
abstract final class LogRedactor {
  /// Anahtar adında bu parçalardan biri geçen alanlar maskelenir
  /// (büyük/küçük harf duyarsız): password, newPassword, accessToken…
  static const _sensitiveKeyParts = ['password', 'token', 'secret', 'authorization', 'fingerprint', 'template'];

  static const int maxLength = 4000;
  static const int _maxStringLength = 500;
  static const int _maxListItems = 50;

  static const masked = '***';

  static Object? redact(Object? value) => switch (value) {
    null || num() || bool() => value,
    String s => s.length > _maxStringLength ? '${s.substring(0, _maxStringLength)}…(+${s.length - _maxStringLength})' : s,
    Uint8List b => '<${b.length} bytes>',
    FormData f => '<multipart: ${f.fields.map((e) => e.key).join(', ')}; files: ${f.files.length}>',
    Stream() => '<stream>',
    Map m => {
      for (final e in m.entries) e.key.toString(): _isSensitive(e.key.toString()) ? masked : redact(e.value),
    },
    List l when l.length > 256 && l.every((e) => e is int) => '<${l.length} bytes>',
    List l => [
      for (final e in l.take(_maxListItems)) redact(e),
      if (l.length > _maxListItems) '…(+${l.length - _maxListItems})',
    ],
    _ => value.toString(),
  };

  /// [redact] + JSON metni, [maxLength] karakterle sınırlı.
  static String? compact(Object? value) {
    if (value == null) return null;
    final redacted = redact(value);
    String text;
    try {
      text = redacted is String ? redacted : jsonEncode(redacted);
    } catch (_) {
      text = redacted.toString();
    }
    return text.length > maxLength ? '${text.substring(0, maxLength)}…(+${text.length - maxLength})' : text;
  }

  static bool _isSensitive(String key) {
    final k = key.toLowerCase();
    return _sensitiveKeyParts.any(k.contains);
  }
}
