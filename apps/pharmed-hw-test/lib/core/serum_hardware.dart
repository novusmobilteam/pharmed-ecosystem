// Serum kapağı ve avadanlık kilit kartı ile konuşan yardımcılar.
//
//   • Serum kapağı: `T` protokolü, önce yönetim kartında satır seçilir.
//     Master içindeki serum bölmesi port 1'de, serum kabininde kapak N → port N.
//     Açma client ile aynı servis metoduyla yapılır (openMasterSerumDrawer).
//   • Avadanlık kilit kartı: `<iXX:YZ>` protokolü (TrayLockProtocol), satır
//     seçimi gerekmez. Kart ID = raf sırası, port = avadanlığın en sağdaki
//     alanı (SerumTrayAddress kuralı).

import 'package:pharmed_core/pharmed_core.dart';

import 'test_status.dart';

/// Kart cevabının ekranda gösterilecek hali.
class TrayReading {
  const TrayReading(this.status, this.text);

  final TestStatus status;
  final String text;

  static TrayReading of(TrayLockResponse r) => switch (r) {
    TrayLockOk() => const TrayReading(TestStatus.passed, 'Komut kabul edildi'),
    TrayLockStatusResponse(:final status) => switch (status) {
      TrayLockStatus.unlocked => const TrayReading(TestStatus.warning, 'Kilit açık, çekilmedi'),
      TrayLockStatus.pulled => const TrayReading(TestStatus.running, 'Çekildi'),
      TrayLockStatus.pushed => const TrayReading(TestStatus.warning, 'Yerine itildi, close (c) bekleniyor (s:03)'),
      TrayLockStatus.idle => const TrayReading(TestStatus.pending, 'Boşta (s:00)'),
    },
    TrayLockKeypadResponse(:final value) => TrayReading(TestStatus.info, 'Al-Ver tuş değeri: $value'),
    TrayLockErrorResponse(:final failure) => TrayReading(TestStatus.failed, failureText(failure)),
  };

  static String failureText(TrayLockFailure f) => switch (f) {
    TrayLockFailure.invalidDeviceId => 'Geçersiz kart ID (noo1)',
    TrayLockFailure.trayOpen => 'Bir avadanlık çekili — önce yerine itin (noo2)',
    TrayLockFailure.invalidPort => 'Geçersiz port (noo3)',
    TrayLockFailure.busy => 'Kart meşgul — başka port açık (noo4)',
    TrayLockFailure.alreadyPulled => 'Avadanlık zaten çekildi (noo5)',
    TrayLockFailure.unknownCommand => 'Kart komutu tanımadı (noo6)',
    TrayLockFailure.noResponse => 'Kilit kartı cevap vermedi',
    TrayLockFailure.protocolError => 'Tanınmayan cevap',
  };
}

enum TrayFlowStep {
  releaseAll('Tüm kilitleri serbest bırak (x)'),
  openLid('Serum kapağını aç'),
  waitLidOpen('Kapağın açıldığını bekle'),
  lockAll('Tüm kilitleri enerjile (k)'),
  openTray('Hedef avadanlığın kilidini aç (o)'),
  waitTrayReturn('Avadanlığın çekilip yerine itilmesini bekle'),
  closeTray('Portu kapat (c): s:03 → s:00'),
  waitLidClose('Kapağın kapanmasını bekle'),
  releaseAtEnd('Bitiş: tüm kilitleri serbest bırak (x)');

  const TrayFlowStep(this.label);

  final String label;
}

class SerumHardware {
  SerumHardware({required this.serial, required this.ops});

  final ISerialCommunicationService serial;
  final ICabinOperationService ops;

  // ── Avadanlık kilit kartı ───────────────────────────────────────────

  Future<(String?, TrayLockResponse)> tray(
    int deviceId,
    TrayLockAction action, {
    int? port,
    Duration timeout = const Duration(milliseconds: 1000),
  }) async {
    final cmd = TrayLockProtocol.build(deviceId: deviceId, action: action, port: port);
    String? raw;
    try {
      raw = await serial.sendAndReceive(cmd, timeout: timeout);
    } catch (_) {
      raw = null;
    }
    return (raw?.trim(), TrayLockProtocol.parse(raw));
  }

  /// Kilit kartı hatta mı: port 1 durumu sorulur, cevap gelmesi yeterli.
  Future<bool> trayCardPresent(int deviceId) async {
    final (_, res) = await tray(deviceId, TrayLockAction.status, port: 1, timeout: const Duration(milliseconds: 500));
    return !(res is TrayLockErrorResponse && res.failure == TrayLockFailure.noResponse);
  }

  // ── Serum kapağı ────────────────────────────────────────────────────

  Future<bool> selectRow(int address, int row) async {
    try {
      final r = await serial.sendAndReceive(
        CommandBuilder.buildManagementCommand(addressIndex: address, row: row),
        timeout: const Duration(milliseconds: 800),
      );
      return r != null && r.contains('ok');
    } catch (_) {
      return false;
    }
  }

  /// Satır seçimini bırakır (satır 00).
  Future<void> release(int address) => selectRow(address, 0);

  /// Kapağın ham durumu (`h3`, `h0` …) ya da null.
  Future<String?> lidStatus(int address, int row, int port) async {
    if (!await selectRow(address, row)) return null;
    try {
      final raw = await serial.sendAndReceive(
        CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: port, drawer: 0),
        timeout: const Duration(milliseconds: 400),
      );
      return raw == null ? null : RegExp(r'\.([^,]*),').firstMatch(raw)?.group(1);
    } catch (_) {
      return null;
    }
  }

  /// Client'taki açma yolu. Hata durumunda fırlatır.
  Future<void> openLid(int address, int row, int port) =>
      ops.openMasterSerumDrawer(manager: ManagementCard(addressIndex: address), row: row, port: port);

  static bool lidIsOpen(String? s) => s == 'h1' || s == 'h2' || s == 'h3' || s == 'h6';
  static bool lidIsClosed(String? s) => s == 'h0' || s == 'h4' || s == 'h5';

  static String lidStatusText(String? s) {
    if (s == null) return 'Cevap yok';
    if (lidIsOpen(s)) return 'Açık ($s)';
    if (lidIsClosed(s)) return 'Kapalı ($s)';
    return 'Bilinmeyen durum ($s)';
  }

  // ── Avadanlık akış testi ────────────────────────────────────────────

  /// Olması gereken çalışma: `x` → kapak aç → `k` → `o` → avadanlık çekilip
  /// yerine itilir → kapak kapanır → `x`. Bitişte (yarıda kalsa da) kilitler
  /// serbest bırakılır ve satır seçimi bırakılır.
  Future<bool> runTrayFlow({
    required int address,
    required int row,
    required int lidPort,
    required int deviceId,
    required int trayPort,
    required void Function(TrayFlowStep step, TestStatus status, String detail) onStep,
    required bool Function() isCancelled,
    void Function(TrayReading reading)? onLive,
  }) async {
    Future<bool> step(TrayFlowStep s, Future<(bool, String)> Function() body) async {
      if (isCancelled()) return false;
      onStep(s, TestStatus.running, '');
      final (ok, detail) = await body();
      onStep(s, ok ? TestStatus.passed : TestStatus.failed, detail);
      return ok;
    }

    Future<(bool, String)> trayCmd(TrayLockAction a, {int? p}) async {
      final (raw, res) = await tray(deviceId, a, port: p);
      return (res is TrayLockOk, '${raw ?? '(cevap yok)'} → ${TrayReading.of(res).text}');
    }

    Future<bool> waitUntil(Future<bool> Function() condition, Duration timeout) async {
      final end = DateTime.now().add(timeout);
      while (DateTime.now().isBefore(end)) {
        if (isCancelled()) return false;
        if (await condition()) return true;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      return false;
    }

    TrayLockStatus? lastTrayStatus;
    var ok =
        await step(TrayFlowStep.releaseAll, () => trayCmd(TrayLockAction.unlockAll)) &&
        await step(TrayFlowStep.openLid, () async {
          try {
            await openLid(address, row, lidPort);
            return (true, 'Açma komutu kabul edildi');
          } catch (e) {
            // Kapak zaten açıksa kart `.no` döner — durumu sorgula.
            final status = await lidStatus(address, row, lidPort);
            if (lidIsOpen(status)) return (true, 'Kapak zaten açıktı ($status)');
            return (false, 'HATA: $e');
          }
        }) &&
        await step(TrayFlowStep.waitLidOpen, () async {
          String? last;
          final opened = await waitUntil(() async {
            last = await lidStatus(address, row, lidPort);
            return lidIsOpen(last);
          }, const Duration(seconds: 15));
          return (opened, 'Son kapak durumu: ${lidStatusText(last)}');
        }) &&
        await step(TrayFlowStep.lockAll, () => trayCmd(TrayLockAction.lockAll)) &&
        await step(TrayFlowStep.openTray, () => trayCmd(TrayLockAction.open, p: trayPort)) &&
        await step(TrayFlowStep.waitTrayReturn, () async {
          var seenActive = false;
          var seenPulled = false;
          var last = '-';
          // #277: yeni firmware'de yerine itme s:03 (close bekleniyor); s:00
          // (boşta) yalnızca kart kendiliğinden kapandıysa görülür.
          final returned = await waitUntil(() async {
            final (_, res) = await tray(deviceId, TrayLockAction.status, port: trayPort);
            final reading = TrayReading.of(res);
            last = reading.text;
            onLive?.call(reading);
            if (res case TrayLockStatusResponse(:final status)) {
              if (status == TrayLockStatus.unlocked || status == TrayLockStatus.pulled) seenActive = true;
              if (status == TrayLockStatus.pulled) seenPulled = true;
              lastTrayStatus = status;
              return seenActive && (status == TrayLockStatus.pushed || status == TrayLockStatus.idle);
            }
            return false;
          }, const Duration(seconds: 90));
          if (returned) {
            final how = lastTrayStatus == TrayLockStatus.pushed ? ' (s:03)' : ' — kart kendiliğinden boşa döndü (s:00)';
            return (
              true,
              seenPulled ? 'Avadanlık çekildi ve yerine itildi$how' : 'Kart çekmeyi görmeden döndü$how',
            );
          }
          // #257: "yerine itilmedi" yalnızca gerçekten çekildiyse doğrudur.
          final why = isCancelled() ? 'Durduruldu' : 'Zaman aşımı (90 sn)';
          final detail = seenPulled
              ? 'Avadanlık çekildi ama yerine itilmedi'
              : seenActive
              ? 'Kart kilidi açık bildirdi ama avadanlık hiç çekilmedi — kilit fiziksel olarak açılmamış olabilir '
                    '(Gelişmiş araçlar → Tek port teşhisi)'
              : 'Kart kilidi açmadı';
          return (false, '$why: $detail — son: $last');
        }) &&
        await step(TrayFlowStep.closeTray, () async {
          // #277: s:03'te CLOSE (c) ile port kapatılır → s:00.
          if (lastTrayStatus == TrayLockStatus.idle) return (true, 'Kart zaten boşta (s:00) — close gerekmedi');
          final (closed, closeDetail) = await trayCmd(TrayLockAction.cancel, p: trayPort);
          if (!closed) return (false, 'Close kabul edilmedi: $closeDetail');
          var last = '-';
          final idle = await waitUntil(() async {
            final (_, res) = await tray(deviceId, TrayLockAction.status, port: trayPort);
            final reading = TrayReading.of(res);
            last = reading.text;
            onLive?.call(reading);
            return res is TrayLockStatusResponse && res.status == TrayLockStatus.idle;
          }, const Duration(seconds: 5));
          return (idle, idle ? 'Port kapatıldı: $closeDetail → s:00' : 'Close sonrası s:00 görülmedi — son: $last');
        }) &&
        await step(TrayFlowStep.waitLidClose, () async {
          String? last;
          final closed = await waitUntil(() async {
            last = await lidStatus(address, row, lidPort);
            return lidIsClosed(last);
          }, const Duration(seconds: 90));
          return (closed, 'Son kapak durumu: ${lidStatusText(last)}');
        });

    // Bitiş adımı iptal edilse de çalışır.
    onStep(TrayFlowStep.releaseAtEnd, TestStatus.running, '');
    final (released, detail) = await trayCmd(TrayLockAction.unlockAll);
    onStep(TrayFlowStep.releaseAtEnd, released ? TestStatus.passed : TestStatus.failed, detail);
    ok = ok && released;
    await release(address);
    return ok;
  }
}
