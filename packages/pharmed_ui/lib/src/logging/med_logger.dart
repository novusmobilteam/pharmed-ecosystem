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
  info,
  warn,
  error;

  String get tag => switch (this) {
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
  };

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

  static void info({
    required String unit,
    required String swreq,
    required String message,
    Map<String, dynamic>? context,
  }) {
    _log(LogLevel.info, unit, swreq, message, context);
  }

  static void warn({
    required String unit,
    required String swreq,
    required String message,
    Map<String, dynamic>? context,
  }) {
    _log(LogLevel.warn, unit, swreq, message, context);
  }

  static void error({
    required String unit,
    required String swreq,
    required String message,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, unit, swreq, message, context, error: error, stackTrace: stackTrace);
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

  // ── İç implementasyon ───────────────────────────────────────

  static void _log(
    LogLevel level,
    String unit,
    String swreq,
    String message,
    Map<String, dynamic>? context, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      unit: unit,
      swreq: swreq,
      message: message,
      context: context,
      error: error,
      stackTrace: stackTrace,
      session: _session.isEmpty ? null : Map.of(_session),
    );

    // Buffer
    _buffer.add(entry);
    if (_buffer.length > _bufferMaxSize) {
      _buffer.removeAt(0);
    }

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
