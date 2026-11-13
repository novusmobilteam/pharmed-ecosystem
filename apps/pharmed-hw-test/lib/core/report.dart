// Test raporu: teknisyenin yaptığı her test adımı (ne denendi, sonuç, ayrıntı)
// burada toplanır ve trafik kaydıyla birlikte metin dosyasına aktarılır.

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'env.dart';
import 'test_status.dart';
import 'traffic_log.dart';

enum StepResult { ok, fail, info }

extension StepResultStatus on StepResult {
  /// Ortak durum modelindeki karşılığı (rozet / ikon / renk için).
  TestStatus get status => switch (this) {
    StepResult.ok => TestStatus.passed,
    StepResult.fail => TestStatus.failed,
    StepResult.info => TestStatus.info,
  };
}

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

/// Rapordaki senaryo satırı (test listesindeki senaryonun son sonucu).
class ReportScenario {
  const ReportScenario({
    required this.group,
    required this.title,
    required this.location,
    required this.status,
    this.detail,
    this.time,
  });

  final String group;
  final String title;
  final String location;
  final TestStatus status;
  final String? detail;
  final DateTime? time;
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
    required String? cabinType,
    required List<TrafficEntry> traffic,
    List<String> cabinLines = const [],
    List<String> serumLines = const [],
    List<ReportScenario> scenarios = const [],
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
      ..writeln('Kabin tipi : ${cabinType ?? '-'}')
      ..writeln();

    if (cabinLines.isNotEmpty) {
      b.writeln('── Kabin ──');
      cabinLines.forEach(b.writeln);
      b.writeln();
    }
    if (serumLines.isNotEmpty) {
      b.writeln('── Serum tanımı (bu testte kullanılan, kaydedilmedi) ──');
      serumLines.forEach(b.writeln);
      b.writeln();
    }

    if (scenarios.isNotEmpty) {
      int count(TestStatus st) => scenarios.where((x) => x.status == st).length;
      final waiting = scenarios.where((x) => !x.status.isFinished).length;
      b.writeln(
        '── Test senaryoları (${scenarios.length}): ${count(TestStatus.passed)} başarılı, '
        '${count(TestStatus.failed)} başarısız, ${count(TestStatus.skipped)} atlandı, $waiting yapılmadı ──',
      );
      String? group;
      for (final sc in scenarios) {
        if (sc.group != group) {
          group = sc.group;
          b
            ..writeln()
            ..writeln(group);
        }
        final mark = sc.status.isFinished ? sc.status.label.toUpperCase() : 'YAPILMADI';
        b.writeln('  [$mark] ${sc.title}  (${sc.location})');
        if (sc.detail != null && sc.detail!.isNotEmpty) b.writeln('            ${sc.detail}');
      }
      b.writeln();
    }

    b.writeln('── Test adımları, zaman sırasıyla (${_steps.length}) ──');
    DateTime? previous;
    for (final s in _steps) {
      b.writeln('${formatTime(s.time)}  [${s.resultLabel}] ${s.title}');
      if (s.detail != null && s.detail!.isNotEmpty) {
        for (final line in s.detail!.split('\n')) {
          b.writeln('              $line');
        }
      }
      // Hatalı adımda, bir önceki adımdan bu yana hattaki ham trafik.
      if (s.result == StepResult.fail) {
        final from = previous;
        final related = traffic
            .where((t) => !t.time.isAfter(s.time) && (from == null || t.time.isAfter(from)))
            .toList();
        final shown = related.length > 40 ? related.sublist(related.length - 40) : related;
        if (shown.isNotEmpty) {
          b.writeln('              Ham trafik (${shown.length}${related.length > shown.length ? ' / ${related.length}' : ''}):');
          for (final t in shown) {
            b.writeln('                ${t.toLine()}');
          }
        }
      }
      previous = s.time;
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
