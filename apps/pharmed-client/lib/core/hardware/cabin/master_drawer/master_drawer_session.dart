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

  /// LidFailed sonrası son açılmaya çalışılan gözü aynı modda yeniden açar.
  Future<void> retryCubicLid();

  /// Kapak durum sorgusu koptuğunda (lidSensorLost) kullanıcı kapağın
  /// kapalı olduğunu elle onaylar. Loglanır, LidClosed üretir.
  void acknowledgeLidClosedManually();

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
// Sınıf: Class B
class MasterDrawerSession extends ChangeNotifier implements IMasterDrawerSession {
  MasterDrawerSession({
    required StartMasterDrawerSessionUseCase startSession,
    required OpenCubicLidUseCase openCubicLid,
    required MonitorDrawerClosureUseCase monitorClosure,
    required MonitorCubicLidUseCase monitorCubicLid,
    required ICabinOperationService cabinOperationService,
  }) : _startSession = startSession,
       _openCubicLidUseCase = openCubicLid,
       _monitorClosure = monitorClosure,
       _monitorCubicLid = monitorCubicLid,
       _cabinOperationService = cabinOperationService;

  final StartMasterDrawerSessionUseCase _startSession;
  final OpenCubicLidUseCase _openCubicLidUseCase;
  final MonitorDrawerClosureUseCase _monitorClosure;
  final MonitorCubicLidUseCase _monitorCubicLid;
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

  /// Kullanıcı bu göz için "Tamamla" dedi mi (confirmLidClose).
  bool _lidCloseConfirmed = false;

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
          onError: (e, _) {
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
    _lastLidAssignment = cellAssignment;
    _lastLidAwaitClose = awaitLidClose;

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
    if (_lidSub == null || _stage is! MasterDrawerOpened) return;
    _lidCloseConfirmed = true;
    _setStage(const MasterDrawerWaitingForLidClose());
    _cabinOperationService.triggerManualLidClose();
  }

  @override
  Future<void> retryCubicLid() async {
    final cell = _lastLidAssignment;
    if (cell == null || _stage is! MasterDrawerLidFailed) return;
    await openCubicLid(cell, awaitLidClose: _lastLidAwaitClose);
  }

  @override
  void acknowledgeLidClosedManually() {
    final stage = _stage;
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
