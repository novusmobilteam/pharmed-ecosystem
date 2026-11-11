// Test raporu: teknisyenin yaptığı her test adımı (ne denendi, sonuç, ayrıntı)
// burada toplanır ve trafik kaydıyla birlikte metin dosyasına aktarılır.

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'env.dart';
import 'traffic_log.dart';

enum StepResult { ok, fail, info }

class TestStep {
  TestStep({required this.title, required this.result, this.detail}) : time = DateTime.now();

  final DateTime time;
  final String title;
  final StepResult result;
  final String? detail;

  String get resultLabel => switch (result) {
    StepResult.ok => 'BAŞARILI',
    StepResult.fail => 'HATALI',
    StepResult.info => 'BİLGİ',
  };
}

class TestReport extends ChangeNotifier {
  final List<TestStep> _steps = [];

  List<TestStep> get steps => List.unmodifiable(_steps);

  void add(String title, StepResult result, {String? detail}) {
    _steps.add(TestStep(title: title, result: result, detail: detail));
    notifyListeners();
  }

  void clear() {
    _steps.clear();
    notifyListeners();
  }

  /// Raporu `Belgeler\PharMed-HwTest\` altına yazar ve dosya yolunu döner.
  Future<String> export({
    required String? user,
    required String? port,
    required List<TrafficEntry> traffic,
  }) async {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final stamp = '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';

    final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? Directory.current.path;
    final dir = Directory('$home${Platform.pathSeparator}Documents${Platform.pathSeparator}PharMed-HwTest');
    await dir.create(recursive: true);
    final file = File('${dir.path}${Platform.pathSeparator}rapor-$stamp.txt');

    final b = StringBuffer()
      ..writeln('PharMed Donanım Test Raporu')
      ..writeln('Tarih      : $now')
      ..writeln('Uygulama   : ${AppEnv.version} (${AppEnv.instance.flavor})')
      ..writeln('Bilgisayar : ${Platform.localHostname}')
      ..writeln('Kullanıcı  : ${user ?? '-'}')
      ..writeln('COM port   : ${port ?? '-'}')
      ..writeln()
      ..writeln('── Test adımları (${_steps.length}) ──');
    for (final s in _steps) {
      b.writeln('${formatTime(s.time)}  [${s.resultLabel}] ${s.title}');
      if (s.detail != null && s.detail!.isNotEmpty) {
        for (final line in s.detail!.split('\n')) {
          b.writeln('              $line');
        }
      }
    }
    b
      ..writeln()
      ..writeln('── Seri hat trafiği (${traffic.length}) ──');
    for (final t in traffic) {
      b.writeln(t.toLine());
    }

    await file.writeAsString(b.toString());
    return file.path;
  }
}
