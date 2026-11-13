// Master kabin çekmece testleri — client'ın çalışan akışıyla aynı adımlar:
//
//   KÜBİK:  ana kilidi aç → çekmece çekilsin (h3) → [her kapak: kapağı aç →
//           kapak açıldı (ac) → kapak kapandı (kp)] → çekmece kapandı (h0/h4/h5)
//   BİRİM DOZ: [her göz: gözü aç → çekmece çekildi (h3/h2) → çekmece kapandı]
//   SERUM KAPAĞI: kapağı aç → açık (h3/h2, 10 sn) → kapandı (kilitli)
//   MOBİL ÇEKMECE: aç (satır 26 slave) → tam açık (h3, 60 sn) → kapandı (kilitli)
//
// Adresler client'taki `calculateAddressFromAssignment` ile hesaplanır (göz
// kaydı + çekmece tanımı → port/göz; birim dozdaki port ters çevirmesi dahil).
// Kabul kriterleri ve süreler client ile aynıdır:
//   • çekmece açılması 10 sn (kübikte yalnız h3; birim dozda h3 ya da h2)
//   • kübik kapak açılması 5 sn; "kapandı" yalnız ac görüldükten sonraki kp
//   • kapanışlar teknisyeni bekler (süre yok)
// Her bekleyen adımda teknisyen "olmadı" diyebilir ya da sensör görmese de
// "oldu" diyebilir; akış durdurulabilir. Komutlar bitince satır seçimi bırakılır.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'test_status.dart';

/// Akıştaki tek adım.
class FlowStep {
  FlowStep({required this.label, this.failLabel, this.group});

  final String label;

  /// Bekleme adımında "olmadı" düğmesinin metni ("Kapak açılmadı").
  final String? failLabel;

  /// Kapak / göz başlığı (adımları gruplu göstermek için).
  final String? group;

  TestStatus status = TestStatus.pending;
  String? detail;

  /// Beklerken sensörün anlık okuması.
  String? live;
}

enum _Manual { failed, doneWithoutSensor, cancelled }

/// Çalışan akış: adımlar, bekleyen adım ve teknisyen kararları.
class DrawerFlow extends ChangeNotifier {
  DrawerFlow({required this.title});

  final String title;
  final List<FlowStep> steps = [];

  /// Sensör / teknisyen bekleyen adım.
  FlowStep? waiting;

  bool _cancelled = false;
  Completer<_Manual>? _manual;

  bool get cancelled => _cancelled;

  /// Kapak / göz bazında sonuç (rapor ayrıntısı).
  final List<String> outcomes = [];

  void _changed() => notifyListeners();

  /// Teknisyen: beklenen fiziksel olay gerçekleşmedi.
  void reportFailed() => _resolve(_Manual.failed);

  /// Teknisyen: fiziksel olarak oldu ama sensör görmedi.
  void reportDoneWithoutSensor() => _resolve(_Manual.doneWithoutSensor);

  /// Akışı durdurur (bekleyen adım iptal edilir).
  void cancel() {
    _cancelled = true;
    _resolve(_Manual.cancelled);
    _changed();
  }

  void _resolve(_Manual m) {
    final c = _manual;
    if (c != null && !c.isCompleted) c.complete(m);
  }

  FlowStep _add(String label, {String? failLabel, String? group}) {
    final s = FlowStep(label: label, failLabel: failLabel, group: group);
    steps.add(s);
    _changed();
    return s;
  }

  void _set(FlowStep s, TestStatus status, [String? detail]) {
    s.status = status;
    if (detail != null) s.detail = detail;
    if (status != TestStatus.running && identical(waiting, s)) waiting = null;
    _changed();
  }

  /// Bir sensör akışını bekler. [onEvent] true dönerse adım başarılıdır;
  /// null dönen olay sayılmaz. Süre aşımı ya da iletişim kaybı başarısızlıktır.
  /// Teknisyen kararı ([reportFailed] / [reportDoneWithoutSensor]) beklemeyi bitirir.
  Future<TestStatus> _wait<T>(
    FlowStep step,
    Stream<T> stream, {
    required bool? Function(T event) onEvent,
    required String Function(T event) describe,
    required bool Function(T event) isLost,
    Duration? timeout,
    String? timeoutText,
  }) async {
    if (_cancelled) {
      _set(step, TestStatus.skipped, 'Durduruldu');
      return TestStatus.skipped;
    }
    waiting = step;
    _set(step, TestStatus.running);
    final manual = Completer<_Manual>();
    _manual = manual;
    final done = Completer<TestStatus>();
    String? lastLive;

    void finish(TestStatus status, String detail) {
      if (done.isCompleted) return;
      step.live = null;
      _set(step, status, detail);
      done.complete(status);
    }

    final sub = stream.listen(
      (event) {
        if (done.isCompleted) return;
        lastLive = describe(event);
        step.live = lastLive;
        _changed();
        if (isLost(event)) {
          finish(TestStatus.failed, 'Sensör iletişimi koptu');
          return;
        }
        if (onEvent(event) == true) finish(TestStatus.passed, 'Sensör: $lastLive');
      },
      onError: (Object e) => finish(TestStatus.failed, 'Sensör hatası: $e'),
      onDone: () => finish(TestStatus.failed, 'Sensör okuması bitti'),
    );
    final timer = timeout == null
        ? null
        : Timer(timeout, () => finish(TestStatus.failed, '${timeoutText ?? 'Süre doldu'} (son: ${lastLive ?? 'cevap yok'})'));
    unawaited(
      manual.future.then((m) {
        switch (m) {
          case _Manual.failed:
            finish(TestStatus.failed, 'Teknisyen bildirdi: ${step.failLabel ?? 'olmadı'} (sensör: ${lastLive ?? '-'})');
          case _Manual.doneWithoutSensor:
            finish(TestStatus.warning, 'Teknisyen: fiziksel olarak oldu, sensör görmedi (sensör: ${lastLive ?? '-'})');
          case _Manual.cancelled:
            finish(TestStatus.skipped, 'Durduruldu');
        }
      }),
    );

    final result = await done.future;
    timer?.cancel();
    await sub.cancel();
    _manual = null;
    return result;
  }

  /// Komut adımı: [action] hata fırlatırsa başarısız.
  Future<TestStatus> _command(FlowStep step, Future<String> Function() action) async {
    if (_cancelled) {
      _set(step, TestStatus.skipped, 'Durduruldu');
      return TestStatus.skipped;
    }
    _set(step, TestStatus.running);
    try {
      final detail = await action();
      _set(step, TestStatus.passed, detail);
      return TestStatus.passed;
    } catch (e) {
      _set(step, TestStatus.failed, '$e');
      return TestStatus.failed;
    }
  }

  /// Genel sonuç: başarısız adım varsa başarısız, sensörsüz onay varsa uyarı.
  TestStatus get overall {
    if (steps.any((s) => s.status == TestStatus.failed)) return TestStatus.failed;
    if (_cancelled || steps.any((s) => s.status == TestStatus.skipped)) return TestStatus.skipped;
    if (steps.any((s) => s.status == TestStatus.warning)) return TestStatus.warning;
    return TestStatus.passed;
  }
}

// ── Etiketler ────────────────────────────────────────────────────────────

String drawerStatusText(DrawerPhysicalStatus s) => switch (s) {
  DrawerPhysicalStatus.locked => 'Kilitli / kapalı',
  DrawerPhysicalStatus.waitingPull => 'Kilit açık, çekilmeyi bekliyor',
  DrawerPhysicalStatus.fullyOpen => 'Tam açık',
  DrawerPhysicalStatus.halfOpen => 'Yarı açık',
  DrawerPhysicalStatus.unknown => 'Okunamadı',
  DrawerPhysicalStatus.timeoutError => 'İletişim yok',
};

String lidStatusText(CubicLidStatus s) => switch (s) {
  CubicLidStatus.open => 'Kapak açık (ac)',
  CubicLidStatus.closed => 'Kapak kapalı (kp)',
  CubicLidStatus.unknown => 'Okunamadı',
  CubicLidStatus.timeoutError => 'İletişim yok',
};

/// Test edilecek göz / kapak: adres client hesabıyla bulunur.
class FlowCell {
  const FlowCell({required this.label, required this.address});

  final String label;
  final DrawerAddress address;
}

/// Client'ın atama üzerinden yaptığı adres hesabı: göz kaydı + çekmece tanımı.
DrawerAddress clientAddress({required int row, required DrawerConfig? config, required DrawerUnit cell}) {
  final assignment = MedicineAssignment(
    drawerUnit: DrawerUnit(
      id: cell.id,
      compartmentNo: cell.compartmentNo,
      orderNo: cell.orderNo,
      drawerSlot: DrawerSlot(address: row.toString().padLeft(2, '0'), drawerConfig: config),
    ),
  );
  return calculateAddressFromAssignment(assignment);
}

class DrawerFlowRunner {
  DrawerFlowRunner({required this.ops, required this.serial});

  final ICabinOperationService ops;
  final ISerialCommunicationService serial;

  static const _openTimeout = Duration(seconds: 10);
  static const _lidOpenTimeout = Duration(seconds: 5);

  Future<void> _release(int address) async {
    try {
      await serial.sendAndReceive(
        CommandBuilder.buildManagementCommand(addressIndex: address, row: 0),
        timeout: const Duration(milliseconds: 300),
      );
    } catch (_) {}
  }

  /// Kübik kapakları karttan yoklar (`Z M`, port 1–4 × sıra 00–04): cevap
  /// veren kapaklar. Client tanımında göz kaydı yoksa kullanılır.
  Future<List<FlowCell>> probeCubicLids(int address, int row) async {
    final manager = ManagementCard(addressIndex: address);
    final cells = <FlowCell>[];
    for (var index = 0; index <= 4; index++) {
      for (var port = 1; port <= 4; port++) {
        String? response;
        try {
          response = await ops.sendRawCommand(
            manager: manager,
            targetRow: row,
            commandPayload: CommandBuilder.buildCubicCommand(action: DeviceAction.ping, port: port, row: index),
          );
        } catch (_) {}
        if (response != null && response.contains('ok')) {
          cells.add(
            FlowCell(
              label: 'Kapak port $port · sıra ${index.toString().padLeft(2, '0')}',
              address: DrawerAddress(row: row, port: port, index: index, isCubic: true),
            ),
          );
        }
      }
    }
    await _release(address);
    return cells;
  }

  /// Kübik çekmece: ana kilit → çekme → kapaklar → kapanış.
  Future<TestStatus> runCubic(DrawerFlow flow, {required int address, required int row, required List<FlowCell> lids}) async {
    final manager = ManagementCard(addressIndex: address);
    final master = DrawerAddress.cubicMaster(row);
    try {
      final open = flow._add('Çekmece ana kilidini aç');
      if (await flow._command(open, () async {
            await ops.openMasterDrawer(manager: manager, row: master.row, port: master.port, drawer: master.index);
            return 'Komut kabul edildi (satır ${row.toString().padLeft(2, '0')} · port ${master.port} · göz ${master.index})';
          }) !=
          TestStatus.passed) {
        return flow.overall;
      }

      final pull = flow._add('Çekmeceyi çekin — tam açık (h3) bekleniyor', failLabel: 'Çekmece açılmadı');
      final pulled = await flow._wait<DrawerPhysicalStatus>(
        pull,
        ops.streamMasterDrawerStatus(manager: manager, row: master.row, port: master.port, drawer: master.index),
        onEvent: (s) => s == DrawerPhysicalStatus.fullyOpen,
        describe: drawerStatusText,
        isLost: (s) => s == DrawerPhysicalStatus.timeoutError,
        timeout: _openTimeout,
        timeoutText: 'Çekmece 10 sn içinde tam açılmadı',
      );
      if (pulled == TestStatus.failed || pulled == TestStatus.skipped) {
        await _waitClose(flow, manager, master);
        return flow.overall;
      }

      for (final lid in lids) {
        if (flow.cancelled) break;
        final a = lid.address;
        final openLid = flow._add('Kapağı aç', group: lid.label);
        final cmd = await flow._command(openLid, () async {
          await _openLidWithRetry(manager, a);
          return 'Komut kabul edildi (port ${a.port} · sıra ${a.index.toString().padLeft(2, '0')})';
        });
        if (cmd != TestStatus.passed) {
          flow.outcomes.add('${lid.label}: açma komutu başarısız');
          continue;
        }

        var seenOpen = false;
        final lidOpen = flow._add('Kapak açıldı mı (ac)', failLabel: 'Kapak açılmadı', group: lid.label);
        final opened = await flow._wait<CubicLidStatus>(
          lidOpen,
          ops.streamMasterCubicLidStatus(manager: manager, row: a.row, port: a.port, lidIndex: a.index),
          onEvent: (s) {
            if (s == CubicLidStatus.open) seenOpen = true;
            return s == CubicLidStatus.open;
          },
          describe: lidStatusText,
          isLost: (s) => s == CubicLidStatus.timeoutError,
          timeout: _lidOpenTimeout,
          timeoutText: 'Kapak 5 sn içinde açılmadı',
        );
        if (opened == TestStatus.failed || opened == TestStatus.skipped) {
          flow.outcomes.add('${lid.label}: açılmadı');
          continue;
        }

        final lidClose = flow._add('Kapağı kapatın — kapalı (kp) bekleniyor', failLabel: 'Kapak kapanmadı', group: lid.label);
        final closed = await flow._wait<CubicLidStatus>(
          lidClose,
          ops.streamMasterCubicLidStatus(manager: manager, row: a.row, port: a.port, lidIndex: a.index),
          // Client: "kapandı" yalnız ac görüldükten sonra okunan kp.
          onEvent: (s) {
            if (s == CubicLidStatus.open) seenOpen = true;
            return s == CubicLidStatus.closed && (seenOpen || opened == TestStatus.passed);
          },
          describe: lidStatusText,
          isLost: (s) => s == CubicLidStatus.timeoutError,
        );
        flow.outcomes.add(
          '${lid.label}: ${switch (closed) {
            TestStatus.passed => opened == TestStatus.warning ? 'açıldı (sensör görmedi), kapandı' : 'açıldı, kapandı',
            TestStatus.warning => 'açıldı, kapandı (kapanışı sensör görmedi)',
            TestStatus.skipped => 'durduruldu',
            _ => 'kapanmadı',
          }}',
        );
      }

      await _waitClose(flow, manager, master);
      return flow.overall;
    } finally {
      await _release(address);
    }
  }

  /// Birim doz çekmece: her göz için aç → çekildi → kapandı.
  Future<TestStatus> runUnitDose(
    DrawerFlow flow, {
    required int address,
    required int row,
    required List<FlowCell> cells,
  }) async {
    final manager = ManagementCard(addressIndex: address);
    try {
      for (final cell in cells) {
        if (flow.cancelled) break;
        final a = cell.address;
        final open = flow._add('Gözü aç', group: cell.label);
        final cmd = await flow._command(open, () async {
          await ops.openMasterDrawer(manager: manager, row: a.row, port: a.port, drawer: a.index);
          return 'Komut kabul edildi (port ${a.port} · adım ${a.index})';
        });
        if (cmd != TestStatus.passed) {
          flow.outcomes.add('${cell.label}: açma komutu başarısız');
          continue;
        }
        final pull = flow._add('Çekmeceyi çekin — açık (h3/h2) bekleniyor', failLabel: 'Çekmece açılmadı', group: cell.label);
        final pulled = await flow._wait<DrawerPhysicalStatus>(
          pull,
          ops.streamMasterDrawerStatus(manager: manager, row: a.row, port: a.port, drawer: a.index),
          onEvent: (s) => s == DrawerPhysicalStatus.fullyOpen || s == DrawerPhysicalStatus.halfOpen,
          describe: drawerStatusText,
          isLost: (s) => s == DrawerPhysicalStatus.timeoutError,
          timeout: _openTimeout,
          timeoutText: 'Çekmece 10 sn içinde açılmadı',
        );
        final close = flow._add('Çekmeceyi kapatın — kilitli bekleniyor', failLabel: 'Çekmece kapanmadı', group: cell.label);
        final closed = await flow._wait<DrawerPhysicalStatus>(
          close,
          ops.streamMasterDrawerStatus(manager: manager, row: a.row, port: a.port, drawer: a.index),
          onEvent: (s) => s == DrawerPhysicalStatus.locked,
          describe: drawerStatusText,
          isLost: (s) => s == DrawerPhysicalStatus.timeoutError,
        );
        flow.outcomes.add(
          '${cell.label}: açılış ${_word(pulled)}, kapanış ${_word(closed)}',
        );
      }
      return flow.overall;
    } finally {
      await _release(address);
    }
  }

  /// Serum kapağı / bölmesi: client'ın standart çekmece kuralı (h3 ya da h2).
  Future<TestStatus> runSerumLid(DrawerFlow flow, {required int address, required int row, required int port}) async {
    final manager = ManagementCard(addressIndex: address);
    try {
      final open = flow._add('Serum kapağını aç');
      if (await flow._command(open, () async {
            await ops.openMasterSerumDrawer(manager: manager, row: row, port: port);
            return 'Komut kabul edildi (satır ${row.toString().padLeft(2, '0')} · port $port)';
          }) !=
          TestStatus.passed) {
        return flow.overall;
      }
      final opened = flow._add('Kapak açıldı mı — açık (h3/h2) bekleniyor', failLabel: 'Kapak açılmadı');
      await flow._wait<DrawerPhysicalStatus>(
        opened,
        ops.streamMasterSerumDrawerStatus(manager: manager, row: row, port: port),
        onEvent: (s) => s == DrawerPhysicalStatus.fullyOpen || s == DrawerPhysicalStatus.halfOpen,
        describe: drawerStatusText,
        isLost: (s) => s == DrawerPhysicalStatus.timeoutError,
        timeout: _openTimeout,
        timeoutText: 'Kapak 10 sn içinde açılmadı',
      );
      final wasCancelled = flow.cancelled;
      if (wasCancelled) flow._cancelled = false;
      final close = flow._add('Kapağı kapatın — kilitli bekleniyor', failLabel: 'Kapak kapanmadı');
      await flow._wait<DrawerPhysicalStatus>(
        close,
        ops.streamMasterSerumDrawerStatus(manager: manager, row: row, port: port),
        onEvent: (s) => s == DrawerPhysicalStatus.locked,
        describe: drawerStatusText,
        isLost: (s) => s == DrawerPhysicalStatus.timeoutError,
      );
      if (wasCancelled) flow._cancelled = true;
      return flow.overall;
    } finally {
      await _release(address);
    }
  }

  /// Mobil çekmece: client'ın StartMobileDrawerSessionUseCase kuralı
  /// (tam açık 60 sn içinde, sonra kilitli).
  Future<TestStatus> runMobileDrawer(DrawerFlow flow, {required int address, required int port}) async {
    final manager = ManagementCard(addressIndex: address);
    try {
      final open = flow._add('Çekmeceyi aç');
      if (await flow._command(open, () async {
            await ops.openMobileDrawer(manager: manager, port: port);
            return 'Komut kabul edildi (satır 26 · port $port)';
          }) !=
          TestStatus.passed) {
        return flow.overall;
      }
      final opened = flow._add('Çekmeceyi çekin — tam açık (h3) bekleniyor', failLabel: 'Çekmece açılmadı');
      await flow._wait<DrawerPhysicalStatus>(
        opened,
        ops.streamMobileDrawerStatus(manager: manager, port: port),
        onEvent: (s) => s == DrawerPhysicalStatus.fullyOpen,
        describe: drawerStatusText,
        isLost: (s) => s == DrawerPhysicalStatus.timeoutError,
        timeout: const Duration(seconds: 60),
        timeoutText: 'Çekmece 60 sn içinde açılmadı',
      );
      final wasCancelled = flow.cancelled;
      if (wasCancelled) flow._cancelled = false;
      final close = flow._add('Çekmeceyi kapatın — kilitli bekleniyor', failLabel: 'Çekmece kapanmadı');
      await flow._wait<DrawerPhysicalStatus>(
        close,
        ops.streamMobileDrawerStatus(manager: manager, port: port),
        onEvent: (s) => s == DrawerPhysicalStatus.locked,
        describe: drawerStatusText,
        isLost: (s) => s == DrawerPhysicalStatus.timeoutError,
      );
      if (wasCancelled) flow._cancelled = true;
      return flow.overall;
    } finally {
      await _release(address);
    }
  }

  static String _word(TestStatus s) => switch (s) {
    TestStatus.passed => 'tamam',
    TestStatus.warning => 'oldu (sensör görmedi)',
    TestStatus.skipped => 'durduruldu',
    _ => 'olmadı',
  };

  Future<void> _waitClose(DrawerFlow flow, ManagementCard manager, DrawerAddress master) async {
    // Durdurulmuş olsa da çekmecenin kapandığını görmek istenir.
    final wasCancelled = flow.cancelled;
    if (wasCancelled) flow._cancelled = false;
    final close = flow._add('Çekmeceyi kapatın — kilitli bekleniyor', failLabel: 'Çekmece kapanmadı');
    await flow._wait<DrawerPhysicalStatus>(
      close,
      ops.streamMasterDrawerStatus(manager: manager, row: master.row, port: master.port, drawer: master.index),
      onEvent: (s) => s == DrawerPhysicalStatus.locked,
      describe: drawerStatusText,
      isLost: (s) => s == DrawerPhysicalStatus.timeoutError,
    );
    if (wasCancelled) flow._cancelled = true;
  }

  /// Client'taki tekrar deneme kuralları (OpenCubicLidUseCase):
  /// ht → 1 tekrar (500 ms), hz → 2 tekrar, diğer → 1 tekrar (200 ms).
  Future<void> _openLidWithRetry(ManagementCard manager, DrawerAddress a) async {
    for (var attempt = 0; ; attempt++) {
      try {
        await ops.openMasterCubicDrawer(manager: manager, row: a.row, port: a.port, lidIndex: a.index);
        return;
      } on CubicLidException catch (e) {
        final maxRetries = switch (e.failure) {
          CubicLidFailure.drawerNotOpen => 1,
          CubicLidFailure.slaveNoResponse => 2,
          CubicLidFailure.protocolError || CubicLidFailure.noResponse => 1,
        };
        if (attempt >= maxRetries) {
          final reason = switch (e.failure) {
            CubicLidFailure.drawerNotOpen => 'çekmece tam açık değil (ht)',
            CubicLidFailure.slaveNoResponse => 'kübik kart cevap vermedi (hz)',
            CubicLidFailure.protocolError => 'tanınmayan cevap',
            CubicLidFailure.noResponse => 'cevap yok',
          };
          throw Exception('Kapak açılamadı: $reason${e.detail != null ? ' — ${e.detail!.trim()}' : ''}');
        }
        await Future<void>.delayed(
          e.failure == CubicLidFailure.drawerNotOpen ? const Duration(milliseconds: 500) : const Duration(milliseconds: 200),
        );
      }
    }
  }
}
