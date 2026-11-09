// lib/core/logging/med_logger.dart
//
// [SWREQ-CORE-LOG-001]
// IEC 62304 §9.2 uyumlu loglama sistemi.
//
// Her log kaydı şunları içerir:
//   - timestamp   : ISO 8601
//   - level       : INFO | WARN | ERROR
//   - unit        : SW-UNIT-DS, SW-UNIT-RE, SW-UNIT-DO, SW-UNIT-UI
//   - swreq       : SWREQ-DS-001 gibi gereksinim referansı
//   - message     : açıklama
//   - context     : ek veri (cabinId, count, vb.)
//   - error       : exception (opsiyonel)
//
// Production'da LAN log sunucusuna gönderilir.
// Mock/Dev'de debugPrint kullanılır.

import 'dart:convert';

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────
// Log seviyeleri
// ─────────────────────────────────────────────────────────────────

enum LogLevel {
  /// Yalnızca konsol (verbose) ve bellekteki "önceki adımlar" — dosyaya ve
  /// uzak hedefe yazılmaz. Başarılı okuma istekleri, ekran verisi yükleme vb.
  debug,
  info,
  warn,
  error;

  String get tag => switch (this) {
    LogLevel.debug => 'DEBUG',
    LogLevel.info => 'INFO ',
    LogLevel.warn => 'WARN ',
    LogLevel.error => 'ERROR',
  };
}

// ─────────────────────────────────────────────────────────────────
// LogEntry — tek bir log kaydı
// ─────────────────────────────────────────────────────────────────

class LogEntry {
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.unit,
    required this.swreq,
    required this.message,
    this.context,
    this.error,
    this.stackTrace,
    this.session,
    this.breadcrumbs,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String unit;
  final String swreq;
  final String message;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;

  /// Kaydın anındaki oturum bağlamı (kullanıcı, istasyon, servis, ekran).
  /// Bkz. [MedLogger.setSessionValue].
  final Map<String, Object?>? session;

  /// WARN/ERROR kayıtlarında, kayıttan hemen önceki (dosyaya yazılmamış)
  /// debug adımları — "hatadan önce ne oldu". Bkz. [MedLogger.breadcrumbCapacity].
  final List<String>? breadcrumbs;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'level': level.tag.trim(),
    'unit': unit,
    'swreq': swreq,
    'message': message,
    if (context != null) 'context': context,
    if (error != null) 'error': error.toString(),
    if (session != null && session!.isNotEmpty) 'session': session,
    if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    if (breadcrumbs != null && breadcrumbs!.isNotEmpty) 'breadcrumbs': breadcrumbs,
  };

  /// "Önceki adımlar" listesindeki tek satır: saat + mesaj + kısa bağlam.
  String toBreadcrumbLine() {
    final t = timestamp;
    String two(int v) => v.toString().padLeft(2, '0');
    final time = '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.${t.millisecond.toString().padLeft(3, '0')}';
    if (context == null || context!.isEmpty) return '$time $message';
    final ctx = _json(context);
    return '$time $message ${ctx.length > 300 ? '${ctx.substring(0, 300)}…' : ctx}';
  }

  /// Dosyaya yazılan satır: tek satır başlık + (varsa) girintili stack trace.
  /// Context/session JSON olarak yazılır — Map.toString() tırnakları yuttuğu
  /// için değerler (ör. servis yanıt gövdesi) okunamaz hale geliyordu.
  String toLogLine() {
    final b = StringBuffer()
      ..write(timestamp.toIso8601String())
      ..write(' ${level.tag} [$unit][$swreq] $message');
    if (context != null && context!.isNotEmpty) b.write(' | ctx=${_json(context)}');
    if (session != null && session!.isNotEmpty) b.write(' | session=${_json(session)}');
    if (error != null) b.write(' | error=$error');
    if (stackTrace != null) {
      for (final line in stackTrace.toString().trimRight().split('\n').take(40)) {
        b.write('\n    $line');
      }
    }
    if (breadcrumbs != null && breadcrumbs!.isNotEmpty) {
      b.write('\n    önceki adımlar (${breadcrumbs!.length}):');
      for (final line in breadcrumbs!) {
        b.write('\n      · $line');
      }
    }
    return b.toString();
  }

  static String _json(Object? value) {
    try {
      return jsonEncode(value, toEncodable: (o) => o.toString());
    } catch (_) {
      return value.toString();
    }
  }

  @override
  String toString() {
    final ctx = context != null ? ' | $context' : '';
    final err = error != null ? ' | ERROR: $error' : '';
    return '[${timestamp.toIso8601String()}]'
        '[${level.tag}]'
        '[$unit]'
        '[$swreq] '
        '$message'
        '$ctx'
        '$err';
  }
}

// ─────────────────────────────────────────────────────────────────
// MedLogger
// ─────────────────────────────────────────────────────────────────

abstract final class MedLogger {
  // Son N kaydı bellekte tut (dashboard'a göndermek için)
  static final List<LogEntry> _buffer = [];
  static const int _bufferMaxSize = 200;

  // Remote sink — production'da LAN log sunucusuna gönderir
  static LogSink? _remoteSink;

  // Ek hedefler (ör. cihazdaki günlük log dosyası — FileLogSink).
  static final List<LogSink> _sinks = [];

  // Her kayda eklenen oturum bağlamı.
  static final Map<String, Object?> _session = {};

  /// Bellekte tutulan, henüz kalıcı loga yazılmamış debug adımı sayısı.
  /// İlk WARN/ERROR kaydına "önceki adımlar" olarak eklenip boşaltılır.
  static const int breadcrumbCapacity = 100;
  static final List<LogEntry> _breadcrumbs = [];

  /// Aynı [dedupeKey] ile gelen kayıtlar bu süre içinde tekrar yazılmaz.
  static const Duration dedupeWindow = Duration(minutes: 5);
  static final Map<String, ({DateTime since, int suppressed})> _dedupe = {};

  // FlavorConfig yerine dışarıdan configure edilir
  static bool _verboseLogging = false;

  static void configure({bool verboseLogging = false, LogSink? remoteSink}) {
    _verboseLogging = verboseLogging;
    if (remoteSink != null) _remoteSink = remoteSink;
  }

  static void setRemoteSink(LogSink sink) {
    _remoteSink = sink;
  }

  /// Ek log hedefi ekler (ör. dosya). Aynı sink iki kez eklenmez.
  static void addSink(LogSink sink) {
    if (!_sinks.contains(sink)) _sinks.add(sink);
  }

  // ── Oturum bağlamı ──────────────────────────────────────────
  // [SWREQ-CORE-LOG-003] Bir işlemin kim tarafından, hangi istasyon/servis ve
  // ekranda yapıldığı her kayıtta görünsün diye. Kişisel veri (hasta bilgisi)
  // buraya KONMAZ — yalnızca operatör ve cihaz bağlamı.

  /// [value] null ise anahtar kaldırılır.
  static void setSessionValue(String key, Object? value) {
    if (value == null) {
      _session.remove(key);
    } else {
      _session[key] = value;
    }
  }

  static void clearSession() => _session.clear();

  static Map<String, Object?> get session => Map.unmodifiable(_session);

  // ── Public API ──────────────────────────────────────────────

  /// Kalıcı loga yazılmaz — bkz. [LogLevel.debug].
  static void debug({
    required String unit,
    required String swreq,
    required String message,
    Map<String, dynamic>? context,
  }) {
    _log(LogLevel.debug, unit, swreq, message, context);
  }

  static void info({
    required String unit,
    required String swreq,
    required String message,
    Map<String, dynamic>? context,
  }) {
    _log(LogLevel.info, unit, swreq, message, context);
  }

  /// [dedupeKey]: rutin, tekrarlayabilen hatalar (ör. ağ kopukken periyodik
  /// istekler) için. Aynı anahtar [dedupeWindow] içinde tekrar yazılmaz;
  /// pencere dolduktan sonraki ilk kayıtta bastırılan sayı belirtilir.
  static void warn({
    required String unit,
    required String swreq,
    required String message,
    Map<String, dynamic>? context,
    String? dedupeKey,
  }) {
    _log(LogLevel.warn, unit, swreq, message, context, dedupeKey: dedupeKey);
  }

  static void error({
    required String unit,
    required String swreq,
    required String message,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
    String? dedupeKey,
  }) {
    _log(LogLevel.error, unit, swreq, message, context, error: error, stackTrace: stackTrace, dedupeKey: dedupeKey);
  }

  /// [SWREQ-CORE-LOG-004] Bir işlem servise GİTMEDEN client kuralına
  /// takıldığında çağrılır. [rule] sabit, aranabilir bir koddur
  /// (ör. `INTAKE_WITNESS_REQUIRED`); [context] kararı veren değerleri taşır.
  static void ruleRejected({
    required String unit,
    required String swreq,
    required String rule,
    String? message,
    Map<String, dynamic>? context,
  }) {
    _log(LogLevel.warn, unit, swreq, 'Kural reddi: $rule${message != null ? ' — $message' : ''}', {
      'rule': rule,
      ...?context,
    });
  }

  // ── Buffer erişimi (dashboard / health endpoint için) ────────

  static List<LogEntry> get recentLogs => List.unmodifiable(_buffer);

  static List<LogEntry> logsForUnit(String unit) => _buffer.where((e) => e.unit == unit).toList();

  static List<LogEntry> get errors => _buffer.where((e) => e.level == LogLevel.error).toList();

  static void clearBuffer() => _buffer.clear();

  /// Henüz kalıcı loga yazılmamış debug adımları.
  static List<LogEntry> get pendingBreadcrumbs => List.unmodifiable(_breadcrumbs);

  // ── İç implementasyon ───────────────────────────────────────

  static void _log(
    LogLevel level,
    String unit,
    String swreq,
    String message,
    Map<String, dynamic>? context, {
    Object? error,
    StackTrace? stackTrace,
    String? dedupeKey,
  }) {
    final now = DateTime.now();

    // Debug: konsol (verbose) + bellek. Kalıcı hedeflere gitmez.
    if (level == LogLevel.debug) {
      final entry = LogEntry(
        timestamp: now,
        level: level,
        unit: unit,
        swreq: swreq,
        message: message,
        context: context,
      );
      _breadcrumbs.add(entry);
      if (_breadcrumbs.length > breadcrumbCapacity) _breadcrumbs.removeAt(0);
      _addToBuffer(entry);
      if (_verboseLogging) debugPrint(entry.toString());
      return;
    }

    // Tekrarlayan rutin hata bastırma.
    if (dedupeKey != null) {
      final state = _dedupe[dedupeKey];
      if (state != null && now.difference(state.since) < dedupeWindow) {
        _dedupe[dedupeKey] = (since: state.since, suppressed: state.suppressed + 1);
        return;
      }
      _dedupe[dedupeKey] = (since: now, suppressed: 0);
      if (state != null && state.suppressed > 0) {
        context = {...?context, 'suppressedRepeats': state.suppressed};
      }
    }

    // WARN/ERROR: bekleyen debug adımları "önceki adımlar" olarak eklenir.
    List<String>? breadcrumbs;
    if (level.index >= LogLevel.warn.index && _breadcrumbs.isNotEmpty) {
      breadcrumbs = [for (final b in _breadcrumbs) b.toBreadcrumbLine()];
      _breadcrumbs.clear();
    }

    final entry = LogEntry(
      timestamp: now,
      level: level,
      unit: unit,
      swreq: swreq,
      message: message,
      context: context,
      error: error,
      stackTrace: stackTrace,
      session: _session.isEmpty ? null : Map.of(_session),
      breadcrumbs: breadcrumbs,
    );

    _addToBuffer(entry);

    // Console (mock/dev'de)
    if (_verboseLogging || level == LogLevel.error) {
      debugPrint(entry.toString());
    }

    // Remote sink (prod'da LAN log sunucusu) ve ek hedefler.
    // Bir sink'in hatası loglamayı (ve uygulamayı) durdurmamalı.
    for (final sink in [?_remoteSink, ..._sinks]) {
      try {
        sink.write(entry);
      } catch (_) {}
    }
  }

  static void _addToBuffer(LogEntry entry) {
    _buffer.add(entry);
    if (_buffer.length > _bufferMaxSize) {
      _buffer.removeAt(0);
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// LogSink — remote log hedefi için interface
// ─────────────────────────────────────────────────────────────────

abstract interface class LogSink {
  void write(LogEntry entry);
}

// ─────────────────────────────────────────────────────────────────
// LanLogSink — LAN sunucusuna HTTP ile log gönderir
// Production'da MedLogger.setRemoteSink(LanLogSink()) ile inject edilir
// ─────────────────────────────────────────────────────────────────

class LanLogSink implements LogSink {
  LanLogSink({required this.endpoint});

  /// Örn: "http://192.168.1.100/api/logs"
  final String endpoint;

  // Gönderim başarısız olursa buffer'da tutulur, sonra tekrar denenir
  final List<LogEntry> _pending = [];

  @override
  void write(LogEntry entry) {
    // Fire-and-forget — log gönderimi uygulamayı bloklamamalı
    _send(entry);
  }

  Future<void> _send(LogEntry entry) async {
    // HTTP POST implementasyonu buraya
    // Dio veya http paketi kullanılabilir
    // Başarısız olursa _pending'e ekle, sonraki başarılı logda flush et
    _pending.add(entry);
  }
}
