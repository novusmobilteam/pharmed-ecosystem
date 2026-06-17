// [SWREQ-CORE-LOG-002]
// Release/exe ortamında log'ları kalıcı dosyaya yazar.
// debugPrint exe'de görünmediği için tanılama bununla yapılır.
//
// Sınıf: Class B

import 'dart:io';
import 'package:pharmed_ui/pharmed_ui.dart';

class FileLogSink implements LogSink {
  FileLogSink(this._file);
  final File _file;

  @override
  void write(LogEntry entry) {
    try {
      _file.writeAsStringSync('${entry}\n', mode: FileMode.append, flush: true);
    } catch (_) {}
  }
}
