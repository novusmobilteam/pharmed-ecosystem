// Test raporu: teknisyenin yaptığı her test adımı (ne denendi, sonuç, ayrıntı)
// burada toplanır. Dışa aktarımda aynı klasöre iki dosya yazılır:
//   • rapor-<tarih>.txt — her şey: tanımlar, senaryolar, tüm adımlar, trafik
//   • rapor-<tarih>.pdf — paylaşılacak özet (markasız): bilgiler, kabin,
//     senaryo sonuçları, hatalı adımlar ve ham trafikleri, imza alanı

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'cabin_model.dart';
import 'env.dart';
import 'report_pdf.dart';
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

/// Hatalı bir adım ve o adıma ait ham hat trafiği.
class FailedStep {
  const FailedStep(this.step, this.traffic, {this.totalTraffic = 0});

  final TestStep step;

  /// Bir önceki adımdan bu adıma kadarki trafik (en fazla son 40 satır).
  final List<TrafficEntry> traffic;

  /// Kırpılmadan önceki satır sayısı.
  final int totalTraffic;
}

/// Rapor başlığındaki bilgiler (txt ve PDF ortak).
class ReportInfo {
  const ReportInfo({
    required this.time,
    required this.user,
    required this.port,
    required this.cabinType,
    required this.host,
    required this.appVersion,
  });

  final DateTime time;
  final String? user;
  final String? port;
  final String? cabinType;
  final String host;
  final String appVersion;
}

class ReportFiles {
  const ReportFiles({required this.folder, required this.text, this.pdf, this.pdfError});

  final String folder;
  final String text;

  /// PDF yazılamadıysa null; neden [pdfError]'da.
  final String? pdf;
  final String? pdfError;
}

class TestReport extends ChangeNotifier {
  static const _maxTrafficPerStep = 40;

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

  /// Hatalı adımlar ve her birinin ham trafiği (bir önceki adımdan bu yana).
  List<FailedStep> failedSteps(List<TrafficEntry> traffic) {
    final out = <FailedStep>[];
    DateTime? previous;
    for (final s in _steps) {
      if (s.result == StepResult.fail) {
        final from = previous;
        final related = traffic
            .where((t) => !t.time.isAfter(s.time) && (from == null || t.time.isAfter(from)))
            .toList();
        final shown = related.length > _maxTrafficPerStep
            ? related.sublist(related.length - _maxTrafficPerStep)
            : related;
        out.add(FailedStep(s, shown, totalTraffic: related.length));
      }
      previous = s.time;
    }
    return out;
  }

  /// Raporu `Belgeler\PharMed-HwTest\` altına .txt ve .pdf olarak yazar.
  Future<ReportFiles> export({
    required String? user,
    required String? port,
    required String? cabinType,
    required List<TrafficEntry> traffic,
    CabinSnapshot? cabin,
    List<String> serumLines = const [],
    List<ReportScenario> scenarios = const [],
  }) async {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final stamp = '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';

    final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? Directory.current.path;
    final dir = Directory('$home${Platform.pathSeparator}Documents${Platform.pathSeparator}PharMed-HwTest');
    await dir.create(recursive: true);
    final base = '${dir.path}${Platform.pathSeparator}rapor-$stamp';

    final info = ReportInfo(
      time: now,
      user: user,
      port: port,
      cabinType: cabinType,
      host: Platform.localHostname,
      appVersion: '${AppEnv.version} (${AppEnv.instance.flavor})',
    );
    final failed = failedSteps(traffic);

    final textFile = File('$base.txt');
    await textFile.writeAsString(
      _text(info: info, traffic: traffic, cabin: cabin, serumLines: serumLines, scenarios: scenarios),
    );

    String? pdfPath;
    String? pdfError;
    try {
      final bytes = await buildReportPdf(
        info: info,
        cabin: cabin,
        serumLines: serumLines,
        scenarios: scenarios,
        failed: failed,
        stepCount: _steps.length,
      );
      final pdfFile = File('$base.pdf');
      await pdfFile.writeAsBytes(bytes);
      pdfPath = pdfFile.path;
    } catch (e) {
      pdfError = '$e';
    }

    return ReportFiles(folder: dir.path, text: textFile.path, pdf: pdfPath, pdfError: pdfError);
  }

  String _text({
    required ReportInfo info,
    required List<TrafficEntry> traffic,
    required CabinSnapshot? cabin,
    required List<String> serumLines,
    required List<ReportScenario> scenarios,
  }) {
    final b = StringBuffer()
      ..writeln('PharMed Donanım Test Raporu')
      ..writeln('Tarih      : ${info.time}')
      ..writeln('Uygulama   : ${info.appVersion}')
      ..writeln('Bilgisayar : ${info.host}')
      ..writeln('Kullanıcı  : ${info.user ?? '-'}')
      ..writeln('COM port   : ${info.port ?? '-'}')
      ..writeln('Kabin tipi : ${info.cabinType ?? '-'}')
      ..writeln();

    if (cabin != null) {
      b.writeln('── Kabin (${cabin.source.label}) ──');
      cabin.describe().forEach(b.writeln);
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

    final failedByStep = {for (final f in failedSteps(traffic)) f.step: f};
    b.writeln('── Test adımları, zaman sırasıyla (${_steps.length}) ──');
    for (final s in _steps) {
      b.writeln('${formatTime(s.time)}  [${s.resultLabel}] ${s.title}');
      if (s.detail != null && s.detail!.isNotEmpty) {
        for (final line in s.detail!.split('\n')) {
          b.writeln('              $line');
        }
      }
      // Hatalı adımda, bir önceki adımdan bu yana hattaki ham trafik.
      final f = failedByStep[s];
      if (f != null && f.traffic.isNotEmpty) {
        final more = f.totalTraffic > f.traffic.length ? ' / ${f.totalTraffic}' : '';
        b.writeln('              Ham trafik (${f.traffic.length}$more):');
        for (final t in f.traffic) {
          b.writeln('                ${t.toLine()}');
        }
      }
    }

    b
      ..writeln()
      ..writeln('── Seri hat trafiği (${traffic.length}) ──');
    for (final t in traffic) {
      b.writeln(t.toLine());
    }
    return b.toString();
  }
}
