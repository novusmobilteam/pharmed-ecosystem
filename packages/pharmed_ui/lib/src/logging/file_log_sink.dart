// [SWREQ-CORE-LOG-002]
// Log'ları cihazda günlük dosyalara yazar: `<prefix>-YYYY-MM-DD.log`.
// debugPrint release/exe'de görünmediği için sahadaki tanılama bununla yapılır.
// [retention] süresinden eski dosyalar açılışta ve gün değişiminde silinir.
//
// Sınıf: Class B

import 'dart:io';

import 'package:pharmed_ui/pharmed_ui.dart';

class FileLogSink implements LogSink {
  FileLogSink._({required this.directory, required this.filePrefix, required this.retention});

  /// Klasörü oluşturur ve eski dosyaları temizler.
  static Future<FileLogSink> open({
    required Directory directory,
    String filePrefix = 'pharmed',
    Duration retention = const Duration(days: 14),
  }) async {
    await directory.create(recursive: true);
    final sink = FileLogSink._(directory: directory, filePrefix: filePrefix, retention: retention);
    sink._sweep(DateTime.now());
    return sink;
  }

  final Directory directory;
  final String filePrefix;
  final Duration retention;

  String? _currentDay;
  File? _file;

  /// Bugünün log dosyası (henüz yazılmadıysa null).
  File? get currentFile => _file;

  @override
  void write(LogEntry entry) {
    try {
      final day = _day(entry.timestamp);
      if (day != _currentDay) {
        _currentDay = day;
        _file = File('${directory.path}${Platform.pathSeparator}$filePrefix-$day.log');
        _sweep(entry.timestamp);
      }
      // Senkron + flush: uygulama çökse bile son satırlar diskte kalır.
      _file!.writeAsStringSync('${entry.toLogLine()}\n', mode: FileMode.append, flush: true);
    } catch (_) {
      // Log yazılamaması uygulamayı durdurmamalı.
    }
  }

  void _sweep(DateTime now) {
    try {
      final cutoff = _day(now.subtract(retention));
      final pattern = RegExp('^${RegExp.escape(filePrefix)}-(\\d{4}-\\d{2}-\\d{2})\\.log\$');
      for (final f in directory.listSync().whereType<File>()) {
        final name = f.uri.pathSegments.last;
        final day = pattern.firstMatch(name)?.group(1);
        if (day != null && day.compareTo(cutoff) < 0) f.deleteSync();
      }
    } catch (_) {}
  }

  static String _day(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
}
