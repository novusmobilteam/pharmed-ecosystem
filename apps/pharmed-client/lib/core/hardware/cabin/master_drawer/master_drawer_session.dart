import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../providers/providers.dart';
import '../../hardware.dart';

final drawerExecutionSessionProvider = Provider<IMasterDrawerSession>((ref) {
  final session = MasterDrawerSession(
    startSession: ref.read(startMasterDrawerSessionUseCaseProvider),
    openCubicLid: ref.read(openCubicLidUseCaseProvider),
    monitorClosure: ref.read(monitorDrawerClosureUseCaseProvider),
    monitorCubicLid: ref.read(monitorCubicLidUseCaseProvider),
    openSerumTray: ref.read(openSerumTrayUseCaseProvider),
    trayLockService: ref.read(trayLockServiceProvider),
    cabinOperationService: ref.read(cabinOperationServiceProvider),
  );
  ref.onDispose(session.dispose);
  return session;
});

abstract class IMasterDrawerSession implements Listenable {
  MasterDrawerStage get stage;

  /// [closeCompletes] true ise çekmece confirmClose ÇAĞRILMADAN kapanırsa
  /// bu beklenmedik kapanış (Failed/unexpectedlyClosed) DEĞİL, işlemin
  /// tamamlanması (Closed) sayılır. Varsayılan false — eski davranış.
  Future<void> start({
    required MedicineAssignment assignment,
    double requestedQuantity = 0.0,
    int? explicitTargetStep,
    bool closeCompletes = false,
  });

  /// Kübik çekmecede TEK bir gözün kapağını açar.
  ///
  /// [awaitLidClose] false (varsayılan): eski davranış — aç komutu `ok`
  /// dönünce hemen Opened, kapak izlenmez.
  /// [awaitLidClose] true: Opened ancak `ac` okununca üretilir; kapak
  /// izlenir, `ac → kp` geçişinde LidClosed üretilir.
  Future<void> openCubicLid(MedicineAssignment cellAssignment, {bool awaitLidClose = false});

  void confirmClose();

  /// Kübik: kullanıcı aktif gözü onayladı — kapağın fiziksel kapanması
  /// beklenir. Yalnızca kapak izlenirken (awaitLidClose) ve Opened'da çalışır.
  void confirmLidClose();

  /// LidFailed sonrası son açılmaya çalışılan alt birimi (kübik göz ya da
  /// serum avadanlığı) aynı modda yeniden açar.
  Future<void> retryCubicLid();

  /// Kapak/avadanlık durum sorgusu koptuğunda (lidSensorLost /
  /// traySensorLost) kullanıcı kapağın kapandığını / avadanlığı yerine
  /// ittiğini elle onaylar. Loglanır, LidClosed üretir.
  void acknowledgeLidClosedManually();

  /// Elektromanyetik kilitli serum rafında TEK bir avadanlığın kilidini açar
  /// ve izler — kübik `openCubicLid(awaitLidClose: true)` ile aynı stage
  /// akışı: OpeningLid → Opened (kilit açıldı) → LidClosed (avadanlık yerine
  /// itildi). Ön koşul: serum kapağı açık (Opened).
  ///
  /// [watchKeypad] true ise kilit açıldıktan sonra kartın Al-Ver tuş değeri
  /// de periyodik okunur — bkz. [trayKeypad].
  Future<void> openSerumTray(SerumTrayAddress address, {bool watchKeypad = false});

  /// Aktif avadanlığın Al-Ver tuş değeri. Yalnızca `watchKeypad: true` ile
  /// açılmış avadanlıkta ve ilk okumadan sonra dolu; avadanlık yerine
  /// itildikten sonra da sıradaki alt birim/kapanışa kadar okunmaya devam eder.
  TrayKeypadReading? get trayKeypad;

  /// Al-Ver tuş değerini periyodu beklemeden hemen okur (izleniyorsa) —
  /// avadanlık itildiği anda karar verilirken son değerin kaçmaması için.
  Future<void> refreshTrayKeypad();

  /// LidFailed sonrası son açılmaya çalışılan avadanlığı yeniden açar.
  Future<void> retrySerumTray();

  Future<void> reopen();
  Future<void> stop();
}

// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// Master kabin çekmece oturumunun TEK gerçek kaynağı. Uygulama ömrü boyunca
// tek örnek olmalı — masterDrawerSessionProvider ile DI'dan enjekte edilir,
// kendi kendine singleton YARATMAZ (bkz. aşağıdaki provider).
//
// KÜBİK KAPAK İZLEME (awaitLidClose=true):
//   OpeningLid ─(ac)→ Opened ─confirmLidClose→ WaitingForLidClose ─(kp)→ LidClosed
//                        └──────────────(kp, onay yok)──────────────→ LidClosed
//   • "Kapandı" kararı yalnızca ac GÖRÜLDÜKTEN sonra gelen kp ile verilir
//     (aç komutu sonrası solenoid gecikmesiyle okunan kp yok sayılır).
//   • ac süre içinde gelmezse LidFailed(lidNotOpened); izleme sürer, ac
//     gelirse akış kendiliğinden Opened'a döner.
//   • Durum sorgusu koparsa LidFailed(lidSensorLost); kullanıcı
//     acknowledgeLidClosedManually ile devam edebilir.
//
// SERUM AVADANLIK KİLİDİ (openSerumTray) — kübik kapağın birebir eşi:
//   OpeningLid ─(s:01/02)→ Opened ─confirmLidClose→ WaitingForLidClose ─(s:03)→ LidClosed
//                              └────────────(s:03, onay yok)────────────→ LidClosed
//   • k (tümünü kilitle) + o (hedef portu aç) → durum polling ile izlenir.
//   • "Yerine itildi" kararı yalnızca açık (01/02) GÖRÜLDÜKTEN sonra gelen 03 ile.
//   • Hiç çekilmeden onaylanırsa açma iptal edilir (c) → 03 → LidClosed.
//   • 01/02 süre içinde gelmezse LidFailed(trayUnlockFailed); art arda okuma
//     hatasında LidFailed(traySensorLost) — izleme sürer, okuma gelirse devam.
//
// Sınıf: Class B
class MasterDrawerSession extends ChangeNotifier implements IMasterDrawerSession {
  MasterDrawerSession({
    required StartMasterDrawerSessionUseCase startSession,
    required OpenCubicLidUseCase openCubicLid,
    required MonitorDrawerClosureUseCase monitorClosure,
    required MonitorCubicLidUseCase monitorCubicLid,
    required OpenSerumTrayUseCase openSerumTray,
    required ITrayLockService trayLockService,
    required ICabinOperationService cabinOperationService,
  }) : _startSession = startSession,
       _openCubicLidUseCase = openCubicLid,
       _monitorClosure = monitorClosure,
       _monitorCubicLid = monitorCubicLid,
       _openSerumTrayUseCase = openSerumTray,
       _trayLock = trayLockService,
       _cabinOperationService = cabinOperationService;

  final StartMasterDrawerSessionUseCase _startSession;
  final OpenCubicLidUseCase _openCubicLidUseCase;
  final MonitorDrawerClosureUseCase _monitorClosure;
  final MonitorCubicLidUseCase _monitorCubicLid;
  final OpenSerumTrayUseCase _openSerumTrayUseCase;
  final ITrayLockService _trayLock;
  final ICabinOperationService _cabinOperationService;

  StreamSubscription<DrawerSessionEvent>? _sessionSub;
  StreamSubscription<DrawerSessionEvent>? _sensorSub;

  MedicineAssignment? _lastAssignment;
  double _lastRequestedQuantity = 0.0;
  int? _lastExplicitTargetStep;
  bool _lastCloseCompletes = false;

  // ── Kübik kapak izleme durumu ─────────────────────────────────────────────

  /// ac bu süre içinde okunmazsa LidFailed(lidNotOpened).
  static const _lidOpenTimeout = Duration(seconds: 5);

  StreamSubscription<CubicLidStatus>? _lidSub;
  Timer? _lidOpenTimer;

  MedicineAssignment? _lastLidAssignment;
  bool _lastLidAwaitClose = false;

  /// Bu göz için ac en az bir kez görüldü mü (kenar tespiti).
  bool _lidSeenOpen = false;

  /// Kullanıcı bu göz/avadanlık için "Tamamla" dedi mi (confirmLidClose).
  bool _lidCloseConfirmed = false;

  // ── Serum avadanlık izleme durumu ─────────────────────────────────────────

  /// Kilit açıldıktan sonra 01/02 bu süre içinde okunmazsa LidFailed(trayUnlockFailed).
  static const _trayUnlockTimeout = Duration(seconds: 5);

  /// Art arda bu kadar okuma hatasında LidFailed(traySensorLost).
  static const _trayMaxReadErrors = 3;

  StreamSubscription<TrayLockStatus>? _traySub;
  Timer? _trayUnlockTimer;
  SerumTrayAddress? _lastTrayAddress;
  TrayLockStatus? _lastTrayStatus;

  /// Bu avadanlık için açık (01/02) en az bir kez görüldü mü (kenar tespiti).
  bool _traySeenActive = false;
  int _trayReadErrors = 0;

  /// Son açılmaya çalışılan alt birim serum avadanlığı mı (retry yönlendirmesi).
  bool _lastSubUnitIsTray = false;

  // ── Al-Ver tuş değeri ─────────────────────────────────────────────────────

  static const _keypadPollInterval = Duration(milliseconds: 700);

  Timer? _keypadTimer;
  bool _keypadReadInFlight = false;
  bool _lastWatchKeypad = false;

  TrayKeypadReading? _trayKeypad;
  @override
  TrayKeypadReading? get trayKeypad => _trayKeypad;

  MasterDrawerStage _stage = const MasterDrawerIdle();
  @override
  MasterDrawerStage get stage => _stage;

  void _setStage(MasterDrawerStage stage) {
    _stage = stage;
    notifyListeners();
  }

  @override
  Future<void> start({
    required MedicineAssignment assignment,
    double requestedQuantity = 0.0,
    int? explicitTargetStep,
    bool closeCompletes = false,
  }) async {
    await _cancelAll();
    _lastAssignment = assignment;
    _lastRequestedQuantity = requestedQuantity;
    _lastExplicitTargetStep = explicitTargetStep;
    _lastCloseCompletes = closeCompletes;

    _sessionSub = _startSession
        .call(assignment: assignment, requestedQuantity: requestedQuantity, explicitTargetStep: explicitTargetStep)
        .listen(
          _onEvent,
          onError: (Object e, StackTrace st) {
            // Beklenmeyen istisna — kullanıcıya bağlantı hatası olarak yansır,
            // gerçek sebep yalnızca bu logda görünür.
            MedLogger.error(
              unit: 'MasterDrawerSession',
              swreq: 'SWREQ-CLI-CABIN-OP-011',
              message: 'Çekmece açma akışı beklenmeyen bir hatayla sonlandı',
              context: {'assignmentId': assignment.id, 'cabinDrawerDetailId': assignment.cabinDrawerDetailId},
              error: e,
              stackTrace: st,
            );
            _setStage(MasterDrawerFailed(failure: MasterDrawerFailure.managerConnectFailed, detail: e.toString()));
          },
          onDone: () => _sessionSub = null,
        );
  }

  @override
  Future<void> stop() async {
    await _cancelAll();
    _setStage(const MasterDrawerIdle());
  }

  @override
  void confirmClose() {
    // LidClosed: son gözün kapağı kapandı. LidFailed: son göz açılamadığı
    // için atlandı — iki durumda da çekmece kapanışı istenebilir.
    if (_stage is! MasterDrawerOpened && _stage is! MasterDrawerLidClosed && _stage is! MasterDrawerLidFailed) {
      return;
    }

    // Çekmece kapanışı beklenirken kapak izlemesi çalışmaya devam ederse,
    // kullanıcının kapağı kapatması WaitingForClose'u LidClosed ile ezer.
    _cancelLidWatch();
    _cancelTrayWatch();
    _cancelKeypadWatch();

    _setStage(const MasterDrawerWaitingForClose());
    _cabinOperationService.triggerManualClose();
  }

  @override
  Future<void> reopen() async {
    final assignment = _lastAssignment;
    if (assignment == null) return;
    await start(
      assignment: assignment,
      requestedQuantity: _lastRequestedQuantity,
      explicitTargetStep: _lastExplicitTargetStep,
      closeCompletes: _lastCloseCompletes,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // KÜBİK KAPAK
  // ════════════════════════════════════════════════════════════════

  @override
  Future<void> openCubicLid(MedicineAssignment cellAssignment, {bool awaitLidClose = false}) async {
    _cancelLidWatch();
    _cancelTrayWatch();
    _cancelKeypadWatch();
    _lastLidAssignment = cellAssignment;
    _lastLidAwaitClose = awaitLidClose;
    _lastSubUnitIsTray = false;

    _setStage(const MasterDrawerOpeningLid());
    try {
      // Otomatik tekrar denemeler use case içinde — buraya sadece son hata düşer.
      await _openCubicLidUseCase(cellAssignment: cellAssignment);
    } on CabinConnectionException catch (e) {
      _setStage(
        MasterDrawerFailed(
          failure: e.failure == CabinConnectionFailure.managerNotFound
              ? MasterDrawerFailure.managerNotFound
              : MasterDrawerFailure.managerConnectFailed,
          detail: e.detail,
        ),
      );
      return;
    } on MasterDrawerException catch (e) {
      _setStage(MasterDrawerLidFailed(failure: e.failure, detail: e.detail));
      return;
    }

    if (!awaitLidClose) {
      _setStage(const MasterDrawerOpened());
      return;
    }
    _startLidWatch(cellAssignment);
  }

  @override
  void confirmLidClose() {
    if (_traySub != null) {
      _confirmTrayClose();
      return;
    }
    if (_lidSub == null || _stage is! MasterDrawerOpened) return;
    _lidCloseConfirmed = true;
    _setStage(const MasterDrawerWaitingForLidClose());
    _cabinOperationService.triggerManualLidClose();
  }

  @override
  Future<void> retryCubicLid() async {
    if (_lastSubUnitIsTray) return retrySerumTray();
    final cell = _lastLidAssignment;
    if (cell == null || _stage is! MasterDrawerLidFailed) return;
    await openCubicLid(cell, awaitLidClose: _lastLidAwaitClose);
  }

  @override
  void acknowledgeLidClosedManually() {
    final stage = _stage;
    if (stage is MasterDrawerLidFailed && stage.failure == MasterDrawerFailure.traySensorLost) {
      MedLogger.warn(
        unit: 'MasterDrawerSession',
        swreq: 'SWREQ-HW-TRAY-002',
        message: 'Serum avadanlığının yerine itildiği sensör olmadan kullanıcı onayıyla kabul edildi',
        context: {'address': _lastTrayAddress.toString(), 'lastStatus': _lastTrayStatus?.name},
      );
      _onTrayReturned();
      return;
    }
    if (stage is! MasterDrawerLidFailed || stage.failure != MasterDrawerFailure.lidSensorLost) return;

    MedLogger.warn(
      unit: 'MasterDrawerSession',
      swreq: 'SWREQ-CLI-CABIN-OP-011',
      message: 'Kübik kapak kapanışı sensör olmadan kullanıcı onayıyla kabul edildi',
      context: {
        'lidAssignmentId': _lastLidAssignment?.id,
        'lidSeenOpen': _lidSeenOpen,
        'lidCloseConfirmed': _lidCloseConfirmed,
      },
    );
    _onLidPhysicallyClosed();
  }

  void _startLidWatch(MedicineAssignment cellAssignment) {
    _lidSeenOpen = false;
    _lidCloseConfirmed = false;

    _lidOpenTimer = Timer(_lidOpenTimeout, () {
      if (_lidSeenOpen || _stage is! MasterDrawerOpeningLid) return;
      _setStage(const MasterDrawerLidFailed(failure: MasterDrawerFailure.lidNotOpened));
    });

    _lidSub = _monitorCubicLid(cellAssignment: cellAssignment).listen(_onLidStatus);
  }

  void _onLidStatus(CubicLidStatus status) {
    switch (status) {
      case CubicLidStatus.open:
        if (!_lidSeenOpen) {
          // İlk ac — kapak gerçekten açıldı (lidNotOpened'dan kurtulma dahil).
          _lidSeenOpen = true;
          _lidOpenTimer?.cancel();
          _lidOpenTimer = null;
          _setStage(const MasterDrawerOpened());
        } else if (_stage is MasterDrawerLidFailed) {
          // Sensör geri geldi, kapak hâlâ açık — kaldığımız yere dön.
          _setStage(_lidCloseConfirmed ? const MasterDrawerWaitingForLidClose() : const MasterDrawerOpened());
        }

      case CubicLidStatus.closed:
        // ac görülmeden okunan kp: açılış sonrası mekanik gecikme ya da
        // kapak henüz hiç açılmadı — kapanış sayılmaz.
        if (!_lidSeenOpen) return;
        _onLidPhysicallyClosed();

      case CubicLidStatus.timeoutError:
        if (_stage is MasterDrawerLidFailed) return; // zaten hata gösteriliyor
        _setStage(const MasterDrawerLidFailed(failure: MasterDrawerFailure.lidSensorLost));

      case CubicLidStatus.unknown:
        // Tekil okuma hatası — servis art arda hatada timeoutError üretir.
        break;
    }
  }

  void _onLidPhysicallyClosed() {
    _cancelLidWatch();
    _setStage(const MasterDrawerLidClosed());
  }

  void _cancelLidWatch() {
    _lidOpenTimer?.cancel();
    _lidOpenTimer = null;
    unawaited(_lidSub?.cancel());
    _lidSub = null;
  }

  // ════════════════════════════════════════════════════════════════
  // SERUM AVADANLIK KİLİDİ
  // ════════════════════════════════════════════════════════════════

  @override
  Future<void> openSerumTray(SerumTrayAddress address, {bool watchKeypad = false}) async {
    _cancelLidWatch();
    _cancelTrayWatch();
    _cancelKeypadWatch();
    _lastTrayAddress = address;
    _lastSubUnitIsTray = true;
    _lastWatchKeypad = watchKeypad;

    _setStage(const MasterDrawerOpeningLid());
    try {
      // Otomatik tekrar denemeler use case içinde — buraya sadece son hata düşer.
      await _openSerumTrayUseCase(address: address);
    } on MasterDrawerException catch (e) {
      _setStage(MasterDrawerLidFailed(failure: e.failure, detail: e.detail));
      return;
    }
    _startTrayWatch(address);
    if (watchKeypad) _startKeypadWatch(address);
  }

  @override
  Future<void> retrySerumTray() async {
    final address = _lastTrayAddress;
    if (address == null || _stage is! MasterDrawerLidFailed) return;
    await openSerumTray(address, watchKeypad: _lastWatchKeypad);
  }

  /// Kilit açıldıktan sonra Al-Ver tuş değerini periyodik okur. İlk okuma
  /// referanstır (kart değeri sıfırlamaz — bkz. TrayKeypadReading).
  void _startKeypadWatch(SerumTrayAddress address) {
    _trayKeypad = null;
    _keypadTimer = Timer.periodic(_keypadPollInterval, (_) => unawaited(_readKeypad(address)));
    unawaited(_readKeypad(address));
  }

  @override
  Future<void> refreshTrayKeypad() async {
    final address = _lastTrayAddress;
    if (address == null || _keypadTimer == null) return;
    await _readKeypad(address, force: true);
  }

  Future<void> _readKeypad(SerumTrayAddress address, {bool force = false}) async {
    if (_keypadReadInFlight && !force) return;
    _keypadReadInFlight = true;
    try {
      final value = await _trayLock.getKeypadValue(deviceId: address.deviceId, port: address.port);
      if (_keypadTimer == null || _lastTrayAddress != address) return; // izleme bu arada bitti
      final previous = _trayKeypad;
      final next = previous == null
          ? TrayKeypadReading(value: value, baseline: value, hasChanged: false)
          : previous.withValue(value);
      if (next != previous) {
        _trayKeypad = next;
        notifyListeners();
      }
    } catch (e) {
      // Tekil okuma hatası — sonraki periyotta tekrar denenir, son değer korunur.
      MedLogger.info(
        unit: 'MasterDrawerSession',
        swreq: 'SWREQ-HW-TRAY-003',
        message: 'Al-Ver tuş değeri okunamadı',
        context: {'address': address.toString(), 'error': e.toString()},
      );
    } finally {
      _keypadReadInFlight = false;
    }
  }

  void _cancelKeypadWatch() {
    _keypadTimer?.cancel();
    _keypadTimer = null;
    if (_trayKeypad != null) {
      _trayKeypad = null;
      notifyListeners();
    }
  }

  void _startTrayWatch(SerumTrayAddress address) {
    _traySeenActive = false;
    _lidCloseConfirmed = false;
    _trayReadErrors = 0;
    _lastTrayStatus = null;

    _trayUnlockTimer = Timer(_trayUnlockTimeout, () {
      if (_traySeenActive || _stage is! MasterDrawerOpeningLid) return;
      _setStage(const MasterDrawerLidFailed(failure: MasterDrawerFailure.trayUnlockFailed));
    });

    _traySub = _trayLock
        .watchStatus(deviceId: address.deviceId, port: address.port)
        .listen(_onTrayStatus, onError: (Object _) => _onTrayReadError());
  }

  void _onTrayStatus(TrayLockStatus status) {
    _trayReadErrors = 0;
    _lastTrayStatus = status;

    switch (status) {
      case TrayLockStatus.unlocked:
      case TrayLockStatus.pulled:
        if (!_traySeenActive) {
          // İlk 01/02 — kilit gerçekten açıldı.
          _traySeenActive = true;
          _trayUnlockTimer?.cancel();
          _trayUnlockTimer = null;
          _setStage(_lidCloseConfirmed ? const MasterDrawerWaitingForLidClose() : const MasterDrawerOpened());
        } else if (_stage is MasterDrawerLidFailed) {
          // Okuma geri geldi, avadanlık hâlâ açık — kaldığımız yere dön.
          _setStage(_lidCloseConfirmed ? const MasterDrawerWaitingForLidClose() : const MasterDrawerOpened());
        }

      case TrayLockStatus.idle:
        // Açık görülmeden okunan 03: kilit henüz açılmadı — yerine itme sayılmaz.
        if (!_traySeenActive) return;
        _onTrayReturned();
    }
  }

  void _onTrayReadError() {
    _trayReadErrors++;
    if (_trayReadErrors < _trayMaxReadErrors) return;
    if (_stage is MasterDrawerLidFailed) return; // zaten hata gösteriliyor
    _setStage(const MasterDrawerLidFailed(failure: MasterDrawerFailure.traySensorLost));
  }

  /// Kullanıcı aktif avadanlığı onayladı. Hiç çekilmediyse açma iptal edilir
  /// (kilit kapanır → 03 → LidClosed); çekildiyse yerine itilmesi beklenir.
  void _confirmTrayClose() {
    if (_stage is! MasterDrawerOpened) return;
    _lidCloseConfirmed = true;
    _setStage(const MasterDrawerWaitingForLidClose());

    final address = _lastTrayAddress;
    if (address == null || _lastTrayStatus != TrayLockStatus.unlocked) return;
    unawaited(_cancelNeverPulledTray(address));
  }

  Future<void> _cancelNeverPulledTray(SerumTrayAddress address) async {
    try {
      await _trayLock.cancelUnlock(deviceId: address.deviceId, port: address.port);
    } on TrayLockException catch (e) {
      // alreadyPulled: kullanıcı tam bu arada çekti — yerine itilmesi beklenir.
      MedLogger.info(
        unit: 'MasterDrawerSession',
        swreq: 'SWREQ-HW-TRAY-002',
        message: 'Çekilmemiş avadanlık iptal edilemedi — izleme sürüyor',
        context: {'address': address.toString(), 'failure': e.failure.name},
      );
    }
  }

  void _onTrayReturned() {
    _cancelTrayWatch();
    _setStage(const MasterDrawerLidClosed());
  }

  void _cancelTrayWatch() {
    _trayUnlockTimer?.cancel();
    _trayUnlockTimer = null;
    unawaited(_traySub?.cancel());
    _traySub = null;
  }

  // ════════════════════════════════════════════════════════════════
  // ANA ÇEKMECE SENSÖRÜ
  // ════════════════════════════════════════════════════════════════

  void _startPassiveCloseWatch() {
    _sensorSub?.cancel();
    final assignment = _lastAssignment;
    if (assignment == null) return;

    _sensorSub = _monitorClosure(assignment: assignment).listen((event) {
      switch (event) {
        case DrawerClosed():
          // Çekmece kapandıysa kapak da kapanmıştır — kapak izlemesini bırak.
          _cancelLidWatch();
          _cancelTrayWatch();
          _cancelKeypadWatch();
          final wasExpected = _stage is MasterDrawerWaitingForClose;
          if (!wasExpected && _lastCloseCompletes) {
            MedLogger.info(
              unit: 'MasterDrawerSession',
              swreq: 'SWREQ-CLI-CABIN-OP-011',
              message: 'Çekmece onay beklenmeden kapandı — tamamlama olarak kabul edildi',
              context: {'stage': _stage.toString()},
            );
          }
          _setStage(
            wasExpected || _lastCloseCompletes
                ? const MasterDrawerClosed()
                : const MasterDrawerFailed(failure: MasterDrawerFailure.unexpectedlyClosed),
          );
          _sensorSub?.cancel();
          _sensorSub = null;
        case DrawerFailed(:final failure, :final detail):
          _cancelLidWatch();
          _cancelTrayWatch();
          _setStage(MasterDrawerFailed(failure: failure as MasterDrawerFailure, detail: detail));
          _sensorSub?.cancel();
          _sensorSub = null;
        default:
          break;
      }
    });
  }

  Future<void> _cancelAll() async {
    _cancelLidWatch();
    _cancelTrayWatch();
    _cancelKeypadWatch();
    await _sessionSub?.cancel();
    await _sensorSub?.cancel();
    _sessionSub = null;
    _sensorSub = null;
  }

  void _onEvent(DrawerSessionEvent event) {
    final stage = switch (event) {
      DrawerOpeningWithStep(:final step) => MasterDrawerOpening(step: step),
      DrawerWaitingForPull() => const MasterDrawerWaitingForPull(),
      DrawerOpened() => const MasterDrawerOpened(),
      DrawerClosed() => const MasterDrawerClosed(),
      DrawerFailed(:final failure, :final detail) => MasterDrawerFailed(
        failure: failure as MasterDrawerFailure,
        detail: detail,
      ),
      DrawerOpening() => const MasterDrawerOpening(step: MasterDrawerOpeningStep.devicePreparing),
    };
    _setStage(stage);

    if (event is DrawerOpened) {
      _startPassiveCloseWatch();
    }
  }

  @override
  void dispose() {
    unawaited(_cancelAll());
    super.dispose();
  }
}
