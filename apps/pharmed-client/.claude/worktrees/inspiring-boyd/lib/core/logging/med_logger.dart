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

import 'package:flutter/foundation.dart';
import '../flavor/app_flavor.dart';

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
  });

  final DateTime timestamp;
  final LogLevel level;
  final String unit;
  final String swreq;
  final String message;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'level': level.tag.trim(),
    'unit': unit,
    'swreq': swreq,
    'message': message,
    if (context != null) 'context': context,
    if (error != null) 'error': error.toString(),
  };

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

  static void setRemoteSink(LogSink sink) {
    _remoteSink = sink;
  }

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
    );

    // Buffer
    _buffer.add(entry);
    if (_buffer.length > _bufferMaxSize) {
      _buffer.removeAt(0);
    }

    // Console (mock/dev'de)
    final config = FlavorConfig.instance;
    if (config.logNetworkCalls || level == LogLevel.error) {
      debugPrint(entry.toString());
    }

    // Remote sink (prod'da LAN log sunucusu)
    _remoteSink?.write(entry);
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
    // TODO: Dio ile gerçek implementasyon
  }
}
