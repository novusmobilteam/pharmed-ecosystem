// [SWREQ-CLI-CABIN-OP-002] [IEC 62304 §5.5]
// Mobil çekmece oturumunun yaşam döngüsünü VE RFID entegrasyonunu tek
// çatı altında yönetir. Önceki MobileDrawerSessionNotifier +
// MobileDrawerOrchestrator ikilisinin yerine geçer — ayrılıklarının nedeni
// (Riverpod'da orchestrator'ın singleton provider'lara ref.listen ile
// bağlanması) artık geçerli değil, her kabin ekranı navigation guard
// sayesinde zaten tekil çalışıyor.
//
// Sorumluluk:
//   - StartMobileDrawerSessionUseCase'i çalıştırır, stream'i dinler, stage'i tutar
//   - Drawer.Opened anında RFID polling'i otomatik başlatır (RFID bağlantısını
//     gerekirse kurar)
//   - Drawer.Closed/Failed anında RFID polling'i otomatik durdurur
//   - Çekmece fiziksel olarak açıkken sensör polling'ini duraklatır
//   - Stage geçişleri ve EPC okumaları için feature notifier'a callback yapar
//     (bkz. init(onStageChange:, onEpcRead:, onEpcLost:))
//
// Feature notifier'ları (refill, pickup, return, ...) kendi constructor'ında
// bir instance alır (DI ile), init() çağırır, dispose'da temizler.
//
// State manipülasyonu dışarıya YAPILMAZ — feature notifier callback'lerle
// kendi state'ini yönetir; bu sınıf sadece donanım/RFID koordinasyonunu
// üstlenir.
//
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../rfid/rfid_scan_session_notifier.dart';
import '../sensor/cabin_sensor_notifier.dart';
import 'mobile_drawer_stage.dart';

typedef DrawerStageCallback = void Function(MobileDrawerStage? previous, MobileDrawerStage current);
typedef EpcReadCallback = void Function(String epc);
typedef EpcLostCallback = void Function(String epc);

class MobileDrawerOrchestrator extends ChangeNotifier {
  MobileDrawerOrchestrator({
    required StartMobileDrawerSessionUseCase startSession,
    required IRfidService rfid,
    required CabinSensorNotifier cabinSensor,
  }) : _startSession = startSession,
       _rfid = rfid,
       _rfidScanSession = RfidScanSessionNotifier(rfid: rfid),
       _cabinSensor = cabinSensor;

  final StartMobileDrawerSessionUseCase _startSession;
  final IRfidService _rfid;
  final CabinSensorNotifier _cabinSensor;
  final RfidScanSessionNotifier _rfidScanSession;

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_cleanup());
    _rfidScanSession.dispose();
    super.dispose();
  }

  // ── State ────────────────────────────────────────────────────────

  MobileDrawerStage _stage = const MobileDrawerIdle();
  MobileDrawerStage get stage => _stage;

  StreamSubscription<DrawerSessionEvent>? _sub;
  StreamSubscription<String>? _epcSub;
  StreamSubscription<String>? _epcLostSub;

  DrawerStageCallback? _onStage;
  EpcReadCallback? _onEpc;
  EpcLostCallback? _onEpcLost;

  int? _lastDrawerPort;
  int? _lastSlotId;

  // Auth inactivity timer'ı bizim tarafımızdan pause edildi mi? — pause/
  // resume simetrisini kendi scope'umuzda sıkı tutmak için flag.
  // GEÇİCİ OLARAK DEVRE DIŞI (orijinal koddaki gibi) — AuthNotifier artık
  // ChangeNotifier, istenirse constructor'a eklenip yeniden açılabilir.
  // bool _authPaused = false;
  bool _sensorPaused = false;

  bool _initialized = false;
  bool _isConnecting = false;
  static bool _globalConnecting = false;

  // ── init / dispose ──────────────────────────────────────────────

  /// Listener'ları başlatır. Feature notifier constructor'ında çağırmalı.
  void init({DrawerStageCallback? onStageChange, EpcReadCallback? onEpcRead, EpcLostCallback? onEpcLost}) {
    if (_initialized) {
      MedLogger.warn(
        unit: 'MobileDrawerOrchestrator',
        swreq: 'SWREQ-CLI-CABIN-OP-005',
        message: 'init() zaten çağrılmış, yeniden başlatma atlandı',
      );
      return;
    }
    _initialized = true;

    _onStage = onStageChange;
    _onEpc = onEpcRead;
    _onEpcLost = onEpcLost;

    _epcSub = _rfidScanSession.epcStream.listen(_handleEpcRead);
    _epcLostSub = _rfidScanSession.epcLostStream.listen(_handleEpcLost);
  }

  Future<void> _cleanup() async {
    await _sub?.cancel();
    await _epcSub?.cancel();
    await _epcLostSub?.cancel();

    // RFID oturumunu kapat — bir sonraki feature (dolum→alım geçişi) temiz
    // başlasın. Aksi halde inventory açık kalır, yeni feature Opened'da
    // erken/çift inventory yaşar.
    await _rfidScanSession.stop();
    if (_rfid.isConnected) {
      await _rfid.disconnect();
    }

    _releaseSensorPauseIfHeld();

    _onStage = null;
    _epcSub = null;
    _epcLostSub = null;
    _onEpc = null;
    _onEpcLost = null;
    _initialized = false;
    _isConnecting = false;
    _globalConnecting = false; // static guard'ı da temizle — geçişte kalıntı kalmasın
  }

  // ── API ──────────────────────────────────────────────────────────

  /// Verilen [slot] için yeni bir çekmece oturumu başlatır. Port numarası
  /// [slots] listesindeki sıraya göre çözülür (MobileSlotVisual.portOf).
  /// RFID polling otomatik olarak Opened anında başlar.
  Future<void> open({required List<MobileSlotVisual> slots, required MobileSlotVisual slot}) async {
    MedLogger.info(unit: 'MobileDrawerOrchestrator', swreq: 'SWREQ-CLI-CABIN-OP-002', message: 'open() çağrıldı');
    final port = MobileSlotVisual.portOf(slots, slot);
    await _start(drawerPort: port, slotId: slot.slotId);
  }

  /// Aynı slot/port için oturumu yeniden başlatır (Closed/Failed sonrası).
  Future<void> reopen() async {
    if (_lastDrawerPort == null || _lastSlotId == null) return;
    await _start(drawerPort: _lastDrawerPort!, slotId: _lastSlotId!);
  }

  /// Çekmece ve RFID oturumlarını sıfırlar. Banner kaybolur.
  Future<void> stop() async {
    await _rfidScanSession.stop();
    if (_isDisposed) return;
    await Future.delayed(const Duration(milliseconds: 150));
    if (_isDisposed) return;
    if (_rfid.isConnected) {
      await _rfid.disconnect();
    }
    if (_isDisposed) return;

    await _sub?.cancel();
    _sub = null;
    _lastDrawerPort = null;
    _lastSlotId = null;
    _releaseSensorPauseIfHeld();
    _stage = const MobileDrawerIdle();
    _notify();
  }

  /// Baseline snapshot — RFID inventory aktifken çağrılır. Biriken EPC'leri
  /// döner. Çekmece açıldıktan sonra _handleStageChange RFID'yi başlatır;
  /// feature notifier onStageChange callback'inde MobileDrawerOpened
  /// gördüğünde bu metodu çağırarak baseline alır.
  Future<Set<String>> snapshot({Duration window = const Duration(milliseconds: 1500)}) {
    return _rfidScanSession.snapshot();
  }

  // ── Internal — çekmece oturumu ──────────────────────────────────

  Future<void> _start({required int drawerPort, required int slotId}) async {
    await _sub?.cancel();
    if (_isDisposed) return;
    _releaseSensorPauseIfHeld();

    _lastDrawerPort = drawerPort;
    _lastSlotId = slotId;

    _sub = _startSession
        .call(drawerPort: drawerPort)
        .listen(
          (event) => _onEvent(event, slotId: slotId),
          onError: (e, _) {
            MedLogger.error(
              unit: 'MobileDrawerOrchestrator',
              swreq: 'SWREQ-CLI-CABIN-OP-002',
              message: 'Stream hatası',
              context: {'error': e.toString()},
            );
            _onEvent(
              DrawerFailed(failure: MobileDrawerFailure.statusReadError, detail: e.toString()),
              slotId: slotId,
            );
          },
          onDone: () => _sub = null,
        );
  }

  void _onEvent(DrawerSessionEvent event, {required int slotId}) {
    final stage = _toStage(event, slotId: slotId);
    _applyStage(stage);
  }

  MobileDrawerStage _toStage(DrawerSessionEvent event, {required int slotId}) {
    final port = _lastDrawerPort ?? 0;
    return switch (event) {
      DrawerOpening() => MobileDrawerOpening(port: port, slotId: slotId),
      DrawerOpeningWithStep() => MobileDrawerOpening(port: port, slotId: slotId),
      DrawerWaitingForPull() => MobileDrawerOpening(port: port, slotId: slotId),
      DrawerOpened() => MobileDrawerOpened(port: port, slotId: slotId),
      DrawerClosed() => MobileDrawerClosed(port: port, slotId: slotId),
      DrawerFailed(:final failure, :final detail) => MobileDrawerFailed(
        failure: failure as MobileDrawerFailure,
        detail: detail,
        port: port,
        slotId: slotId,
      ),
    };
  }

  void _applyStage(MobileDrawerStage next) {
    final previous = _stage;
    final wasOpen = _isPhysicallyOpen(previous);
    final isOpen = _isPhysicallyOpen(next);

    _stage = next;

    if (!wasOpen && isOpen) {
      _acquireSensorPause();
    } else if (wasOpen && !isOpen) {
      _releaseSensorPauseIfHeld();
    }

    // RFID koordinasyonu — orijinal composition helper'daki
    // _handleStageChange mantığı.
    if (next is MobileDrawerOpened && previous is! MobileDrawerOpened) {
      if (!_isConnecting) {
        _isConnecting = true;
        unawaited(
          _onDrawerOpened().whenComplete(() {
            _isConnecting = false;
            _notify();
            _onStage?.call(previous, next);
          }),
        );
      }
      return; // Opened için _onStage'i aşağıda TEKRAR çağırma
    } else if (next is MobileDrawerClosed || next is MobileDrawerFailed) {
      _onDrawerClosed();
    }

    _notify();
    _onStage?.call(previous, next);
  }

  bool _isPhysicallyOpen(MobileDrawerStage s) => s is MobileDrawerOpening || s is MobileDrawerOpened;

  // ── Internal — sensör pause/resume ──────────────────────────────

  void _acquireSensorPause() {
    if (_sensorPaused) return;
    _cabinSensor.pause();
    _sensorPaused = true;
  }

  void _releaseSensorPauseIfHeld() {
    if (!_sensorPaused) return;
    _cabinSensor.resume();
    _sensorPaused = false;
  }

  // ── Internal — RFID koordinasyonu ───────────────────────────────

  Future<void> _onDrawerOpened() async {
    await _ensureRfidConnected();
    if (_isDisposed) return;
    _rfidScanSession.start();
  }

  void _onDrawerClosed() {
    unawaited(_rfidScanSession.stop());
  }

  void _handleEpcRead(String epc) => _onEpc?.call(epc);
  void _handleEpcLost(String epc) => _onEpcLost?.call(epc);

  Future<void> _ensureRfidConnected() async {
    // Zaten bağlıysa hiçbir şey yapma — reconnect döngüsünü kır.
    if (_rfid.isConnected) {
      MedLogger.info(
        unit: 'MobileDrawerOrchestrator',
        swreq: 'SWREQ-CLI-CABIN-OP-005',
        message: 'RFID zaten bağlı, reconnect atlandı',
      );
      return;
    }

    while (_globalConnecting) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_isDisposed) return;
    }

    // Bekleme bitince başka bir çağrı bağlamış olabilir — tekrar kontrol et.
    if (_rfid.isConnected) return;

    _globalConnecting = true;
    try {
      await _rfidScanSession.stop();
      if (_isDisposed) return;
      await Future.delayed(const Duration(milliseconds: 150));
      if (_isDisposed) return;

      MedLogger.info(
        unit: 'MobileDrawerOrchestrator',
        swreq: 'SWREQ-CLI-CABIN-OP-005',
        message: 'RFID connect başlatılıyor',
      );

      final result = await _rfid.connect('192.168.1.190', 6000);
      result.when(
        ok: (_) => MedLogger.info(
          unit: 'MobileDrawerOrchestrator',
          swreq: 'SWREQ-CLI-CABIN-OP-005',
          message: 'RFID connect başarılı',
        ),
        error: (e) => MedLogger.error(
          unit: 'MobileDrawerOrchestrator',
          swreq: 'SWREQ-CLI-CABIN-OP-005',
          message: 'RFID connect başarısız',
          context: {'error': e.message},
        ),
      );
    } finally {
      _globalConnecting = false;
    }
  }
}
