// [SWREQ-NET-007] LogEntry → backend FrontendLogCreateModel.
//
// Şema `additionalProperties: false` — burada yalnızca şemadaki alanlar
// yazılır ve uzunluk sınırları istemcide uygulanır (sınırı aşan satırı
// backend reddeder, kayıt kaybolur). Backend'in indekslediği alanlar (rule,
// req, errorType, http, relatedOperationId) context'ten ayrı alanlara
// çıkarılır; context olduğu gibi de gönderilir. Şema değişirse yalnızca
// burası güncellenir.

import 'package:pharmed_ui/pharmed_ui.dart';

import 'device_identity.dart';

abstract final class DeviceLogMapper {
  // FrontendLogCreateModel / FrontendLogHttpModel sınırları
  static const int maxMessage = 1000;
  static const int maxError = 8000;
  static const int maxStackTrace = 16000;
  static const int maxStackLines = 40;
  static const int maxRule = 128;
  static const int maxReq = 128;
  static const int maxErrorType = 256;
  static const int maxUnit = 100;
  static const int maxSwreq = 100;
  static const int maxMethod = 16;
  static const int maxPath = 2048;
  static const int maxBreadcrumbs = 100;

  /// DEBUG kayıtları gönderilmez — null döner.
  static Map<String, dynamic>? toJson(LogEntry e, {required String appRunId, String? id}) {
    if (e.level == LogLevel.debug) return null;
    final ctx = e.context ?? const <String, dynamic>{};

    String? str(Object? v, int max) {
      if (v == null) return null;
      final s = '$v';
      return s.isEmpty ? null : _cap(s, max);
    }

    int? integer(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

    final method = str(ctx['method'], maxMethod);
    final path = str(ctx['path'], maxPath);
    final status = integer(ctx['status'] ?? ctx['statusCode']);
    final ms = integer(ctx['ms']);
    // İşlem yapan isteğin yanıtındaki operationId — log, backend'deki işlem
    // kaydıyla (ve kamera kaydıyla) bu alan üzerinden ilişkilendirilir.
    final operationId = integer(ctx['operationId']);

    final stack = e.stackTrace?.toString().trimRight().split('\n').take(maxStackLines).join('\n');

    return {
      'id': id ?? uuidV4(),
      'appRunId': appRunId,
      'timestamp': e.timestamp.toUtc().toIso8601String(),
      'level': e.level.tag.trim(),
      'unit': _cap(e.unit, maxUnit),
      'swreq': _cap(e.swreq, maxSwreq),
      'message': e.message.isEmpty ? '-' : _cap(e.message, maxMessage),
      if (ctx.isNotEmpty) 'context': ctx,
      if (e.session != null && e.session!.isNotEmpty) 'session': e.session,
      if (e.error != null) 'error': _cap(e.error.toString(), maxError),
      if (stack != null && stack.isNotEmpty) 'stackTrace': _cap(stack, maxStackTrace),
      if (e.breadcrumbs != null && e.breadcrumbs!.isNotEmpty) 'breadcrumbs': e.breadcrumbs!.take(maxBreadcrumbs).toList(),
      'rule': ?str(ctx['rule'], maxRule),
      'req': ?str(ctx['req'], maxReq),
      'errorType': ?str(ctx['errorType'], maxErrorType),
      if (operationId != null && operationId > 0) 'relatedOperationId': operationId,
      if (method != null && path != null)
        'http': {
          'method': method,
          'path': path,
          if (status != null && status >= 0 && status <= 599) 'status': status,
          if (ms != null && ms >= 0) 'ms': ms,
        },
    };
  }

  /// Sınırı aşan metin, sonuna '…' eklenerek tam [max] karaktere kırpılır.
  static String _cap(String s, int max) => s.length <= max ? s : '${s.substring(0, max - 1)}…';
}
