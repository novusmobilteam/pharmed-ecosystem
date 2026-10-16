// [SWREQ-HW-TRAY-001] [IEC 62304 §5.5]
// Serum kabini avadanlık kilit kartı servisi — mock implementasyon.
//
// Kartın durum makinesini birebir taklit eder (kart başına tek aktif port):
//   IDLE ──o(port)──▶ UNLOCKED ──(çekildi)──▶ PULLED ──(geri itildi)──▶ IDLE
//               ◀──────c(port)──────┘
//   k / x  : PULLED değilse IDLE'a döner, PULLED'da `trayOpen`
//   o      : IDLE değilse `busy`
//   c      : UNLOCKED değilse — PULLED'da `alreadyPulled`, IDLE'da başarılı (no-op)
//
// Fiziksel çekme/geri itme otomatik simüle edilir: açıldıktan [pullDelay]
// sonra PULLED, ondan [returnDelay] sonra IDLE. Test/elle kontrol için
// [simulatePull] ve [simulateReturn] de kullanılabilir.
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

class MockTrayLockService implements ITrayLockService {
  MockTrayLockService({
    this.pullDelay = const Duration(seconds: 2),
    this.returnDelay = const Duration(seconds: 6),
    this.commandDelay = const Duration(milliseconds: 80),
    this.autoSimulate = true,
    this.autoKeypadValue,
  });

  final Duration pullDelay;
  final Duration returnDelay;
  final Duration commandDelay;

  /// false ise çekme/geri itme yalnızca [simulatePull]/[simulateReturn] ile olur.
  final bool autoSimulate;

  /// Verilirse otomatik simülasyonda avadanlık çekilince Al-Ver tuş değeri
  /// bu değere ayarlanır (Al-Ver doğrulamasını mock'ta denemek için). null →
  /// değer yalnızca [simulateKeypad] ile değişir.
  final int? autoKeypadValue;

  final Map<int, _MockCard> _cards = {};

  _MockCard _card(int deviceId) => _cards.putIfAbsent(deviceId, _MockCard.new);

  @override
  Future<void> lockAll({required int deviceId}) async {
    await _delay();
    final card = _card(deviceId);
    if (card.state == TrayLockStatus.pulled) throw const TrayLockException(TrayLockFailure.trayOpen);
    card.reset(locked: true);
    debugPrint('MOCK TRAY[$deviceId]: tüm kilitler enerjilendi');
  }

  @override
  Future<void> unlockAll({required int deviceId}) async {
    await _delay();
    final card = _card(deviceId);
    if (card.state == TrayLockStatus.pulled) throw const TrayLockException(TrayLockFailure.trayOpen);
    card.reset(locked: false);
    debugPrint('MOCK TRAY[$deviceId]: tüm kilitler serbest');
  }

  @override
  Future<void> unlock({required int deviceId, required int port}) async {
    await _delay();
    _checkPort(port);
    final card = _card(deviceId);
    if (card.state != TrayLockStatus.idle) throw const TrayLockException(TrayLockFailure.busy);

    card
      ..state = TrayLockStatus.unlocked
      ..activePort = port;
    debugPrint('MOCK TRAY[$deviceId]: port $port açıldı');

    if (autoSimulate) {
      card.timer?.cancel();
      card.timer = Timer(pullDelay, () {
        simulatePull(deviceId: deviceId);
        final keypad = autoKeypadValue;
        if (keypad != null) simulateKeypad(deviceId: deviceId, port: port, value: keypad);
        card.timer = Timer(returnDelay, () => simulateReturn(deviceId: deviceId));
      });
    }
  }

  @override
  Future<void> cancelUnlock({required int deviceId, required int port}) async {
    await _delay();
    _checkPort(port);
    final card = _card(deviceId);
    if (card.activePort != port) return;
    if (card.state == TrayLockStatus.pulled) throw const TrayLockException(TrayLockFailure.alreadyPulled);
    card.reset(locked: true);
    debugPrint('MOCK TRAY[$deviceId]: port $port iptal edildi');
  }

  @override
  Future<TrayLockStatus> getStatus({required int deviceId, required int port}) async {
    await _delay();
    _checkPort(port);
    final card = _card(deviceId);
    return card.activePort == port ? card.state : TrayLockStatus.idle;
  }

  @override
  Future<int> getKeypadValue({required int deviceId, required int port}) async {
    await _delay();
    _checkPort(port);
    return _card(deviceId).keypad[port] ?? 0;
  }

  @override
  Stream<TrayLockStatus> watchStatus({required int deviceId, required int port, Duration? interval}) async* {
    final period = interval ?? const Duration(milliseconds: 400);
    TrayLockStatus? last;
    while (true) {
      final status = await getStatus(deviceId: deviceId, port: port);
      if (status != last) {
        last = status;
        yield status;
      }
      await Future<void>.delayed(period);
    }
  }

  // ── Simülasyon kontrolleri ──────────────────────────────────────────────

  /// Açık avadanlığın çekildiğini simüle eder (UNLOCKED → PULLED).
  void simulatePull({required int deviceId}) {
    final card = _card(deviceId);
    if (card.state != TrayLockStatus.unlocked) return;
    card.state = TrayLockStatus.pulled;
    debugPrint('MOCK TRAY[$deviceId]: port ${card.activePort} çekildi');
  }

  /// Çekilmiş avadanlığın geri itildiğini simüle eder (PULLED → IDLE).
  void simulateReturn({required int deviceId}) {
    final card = _card(deviceId);
    if (card.state != TrayLockStatus.pulled) return;
    debugPrint('MOCK TRAY[$deviceId]: port ${card.activePort} geri itildi');
    card.reset(locked: true);
  }

  /// Panelden +/- ile girilen değeri simüle eder.
  void simulateKeypad({required int deviceId, required int port, required int value}) {
    _card(deviceId).keypad[port] = value.clamp(0, 99);
  }

  Future<void> _delay() => Future<void>.delayed(commandDelay);

  static void _checkPort(int port) {
    if (port < TrayLockProtocol.minPort || port > TrayLockProtocol.maxPort) {
      throw const TrayLockException(TrayLockFailure.invalidPort);
    }
  }
}

class _MockCard {
  TrayLockStatus state = TrayLockStatus.idle;
  int? activePort;
  bool locked = false;
  Timer? timer;
  final Map<int, int> keypad = {};

  void reset({required bool locked}) {
    timer?.cancel();
    timer = null;
    state = TrayLockStatus.idle;
    activePort = null;
    this.locked = locked;
  }
}
