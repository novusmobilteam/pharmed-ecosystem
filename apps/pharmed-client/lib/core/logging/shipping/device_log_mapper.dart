// [SWREQ-NET-007] LogEntry → sözleşmedeki kayıt gövdesi.
//
// "PharMed Cihaz Logları — Backend API Sözleşmesi", Veri modeli. Backend'in
// indekslediği alanlar (rule, req, errorType, http) context'ten ayrı alanlara
// çıkarılır; context olduğu gibi de gönderilir. Endpoint değişirse yalnızca
// burası güncellenir.

import 'package:pharmed_ui/pharmed_ui.dart';

import 'device_identity.dart';

abstract final class DeviceLogMapper {
  static const int maxMessage = 1000;
  static const int maxError = 4000;
  static const int maxStackLines = 40;

  /// DEBUG kayıtları gönderilmez — null döner.
  static Map<String, dynamic>? toJson(LogEntry e, {required String appRunId, String? id}) {
    if (e.level == LogLevel.debug) return null;
    final ctx = e.context ?? const <String, dynamic>{};

    String? str(Object? v) => v == null ? null : '$v';
    int? integer(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

    final method = str(ctx['method']);
    final path = str(ctx['path']);
    final status = integer(ctx['status'] ?? ctx['statusCode']);
    final ms = integer(ctx['ms']);

    return {
      'id': id ?? uuidV4(),
      'appRunId': appRunId,
      'timestamp': e.timestamp.toUtc().toIso8601String(),
      'level': e.level.tag.trim(),
      'unit': e.unit,
      'swreq': e.swreq,
      'message': _truncate(e.message, maxMessage),
      if (ctx.isNotEmpty) 'context': ctx,
      if (e.session != null && e.session!.isNotEmpty) 'session': e.session,
      if (e.error != null) 'error': _truncate(e.error.toString(), maxError),
      if (e.stackTrace != null) 'stackTrace': e.stackTrace.toString().trimRight().split('\n').take(maxStackLines).join('\n'),
      if (e.breadcrumbs != null && e.breadcrumbs!.isNotEmpty) 'breadcrumbs': e.breadcrumbs,
      'rule': ?str(ctx['rule']),
      'req': ?str(ctx['req']),
      'errorType': ?str(ctx['errorType']),
      if (method != null && path != null)
        'http': {'method': method, 'path': path, 'status': ?status, 'ms': ?ms},
    };
  }

  static String _truncate(String s, int max) => s.length <= max ? s : '${s.substring(0, max)}…';
}
