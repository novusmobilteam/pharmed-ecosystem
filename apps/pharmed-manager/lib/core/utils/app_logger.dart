// lib/core/logging.dart

import 'dart:developer' as developer;

/// Log durumu için kullanılacak tip.
enum LogStatus { success, failure, exception, inProgress }

extension _LogStatusExt on LogStatus {
  String get label => name.toUpperCase();
}

class AppLogger {
  /// operation: işlem adı (getFirms, createUser, vs.)
  /// status: LogStatus enum’undan bir değer
  /// count: opsiyonel veri sayısı
  /// message: opsiyonel açıklama
  static void operation({
    required String loggerName,
    required String operation,
    required LogStatus status,
    int? count,
    String? message,
    int? statusCode,
  }) {
    final parts = <String>[
      'Operation: $operation',
      'Status: ${status.label}',
      if (count != null) 'Data Count: $count',
      if (message != null) 'Message: "$message"',
      if (statusCode != null) 'StatusCode: $statusCode',
    ];
    developer.log(parts.join(' | '), name: loggerName);
  }
}

mixin Logging {
  /// Repo veya servis sınıfının adı
  String get loggerName;

  void logOp({required String operation, required LogStatus status, int? count, String? message, int? statusCode}) {
    AppLogger.operation(loggerName: loggerName, operation: operation, status: status, count: count, message: message);
  }
}
