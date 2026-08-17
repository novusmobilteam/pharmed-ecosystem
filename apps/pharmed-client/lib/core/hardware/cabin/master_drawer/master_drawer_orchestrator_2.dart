// [SWREQ-CLI-CABIN-OP-012] [IEC 62304 §5.5]
// Master kabin çekmece oturumunun yaşam döngüsünü yönetir VE bunu feature
// notifier'lara açan API'yi tek çatı altında sunar. Önceki
// MasterDrawerSessionNotifier + MasterDrawerOrchestrator2 ikilisinin
// yerine geçer — ayrı tutulmalarının nedeni (Riverpod'da orchestrator'ın
// singleton provider'a ref.listen ile bağlanması) artık geçerli değil:
// her kabin ekranı navigation guard sayesinde zaten tekil olarak
// çalışıyor, bu yüzden her feature notifier kendi
// MasterDrawerOrchestrator2'ını (bu sınıfı) kendi instance'ı olarak taşır.
//
// Sorumluluk:
//   - StartMasterDrawerSessionUseCase stream'ini dinler, stage'i tutar
//   - Opened sonrası sensor'ı ayrı subscription ile izler (WaitingForClose → Closed)
//   - confirmClose() ile kullanıcı işlemi onayladığında WaitingForClose'a geçer
//   - openCubicLid() ile kübik çekmecede TEK bir gözün kapağını açar (lid-by-lid)
//   - reopen / stop API'leri sunar
//   - stage geçişlerini (previous, current) bir callback ile dışarı bildirir
//     (bkz. init(onStageChange:) — CabinDrawerQueueMixin.onDrawerStage'e bağlanır)
//
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'master_drawer_stage.dart';

typedef MasterDrawerStageCallback = void Function(MasterDrawerStage? previous, MasterDrawerStage current);

class MasterDrawerOrchestrator extends ChangeNotifier {
  MasterDrawerOrchestrator({
    required StartMasterDrawerSessionUseCase startSession,
    required OpenCubicLidUseCase openCubicLid,
    required MonitorDrawerClosureUseCase monitorClosure,
  }) : _startSession = startSession,
       _openCubicLid = openCubicLid,
       _monitorClosure = monitorClosure;

  final StartMasterDrawerSessionUseCase _startSession;
  final OpenCubicLidUseCase _openCubicLid;
  final MonitorDrawerClosureUseCase _monitorClosure;

  StreamSubscription<DrawerSessionEvent>? _sessionSub;
  StreamSubscription<DrawerSessionEvent>? _sensorSub;

  MedicineAssignment? _lastAssignment;
  double _lastRequestedQuantity = 0.0;
  int? _lastExplicitTargetStep;

  bool _isDisposed = false;

  MasterDrawerStage _stage = const MasterDrawerIdle();
  MasterDrawerStage get stage => _stage;

  MasterDrawerStageCallback? _onStage;

  void _setStage(MasterDrawerStage next) {
    if (_isDisposed) return;
    debugPrint(
      'Stage: ${_stage.runtimeType} → ${next.runtimeType}'
      '${next is MasterDrawerFailed ? " (${next.failure}, ${next.detail})" : ""}',
    );
    final previous = _stage;
    _stage = next;
    _onStage?.call(previous, next);
    notifyListeners();
  }

  /// Host, orchestrator'ı kullanmadan önce bunu ÇAĞIRMALIDIR (genelde
  /// kendi constructor'ında) — stage callback'i buradan bağlanır.
  /// CabinDrawerQueueMixin kullanan notifier'lar:
  ///   _orchestrator.init(onStageChange: onDrawerStage);
  void init({MasterDrawerStageCallback? onStageChange}) {
    _onStage = onStageChange;
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_cancelAll());
    _onStage = null;
    super.dispose();
  }

  /// Yeni bir çekmece oturumu başlatır (ana çekmece açılır, kübikte lid açılmaz).
  Future<void> open({
    required MedicineAssignment assignment,
    double requestedQuantity = 0.0,
    int? explicitTargetStep,
  }) async {
    await _cancelAll();
    if (_isDisposed) return;
    _lastAssignment = assignment;
    _lastRequestedQuantity = requestedQuantity;
    _lastExplicitTargetStep = explicitTargetStep;

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

  Future<void> stop() async {
    await _cancelAll();
    if (_isDisposed) return;
    _setStage(const MasterDrawerIdle());
  }

  /// Kullanıcı işlemi tamamladı — mevcut (Opened'dan beri zaten çalışan)
  /// sensör takibi artık "resmi" kapanışı bekliyor sayılır.
  void confirmClose() {
    if (_stage is! MasterDrawerOpened) return;
    _setStage(const MasterDrawerWaitingForClose());
  }

  /// Son assignment VE son requestedQuantity/explicitTargetStep ile
  /// oturumu yeniden başlatır.
  Future<void> reopen() async {
    final assignment = _lastAssignment;
    if (assignment == null) return;
    await open(
      assignment: assignment,
      requestedQuantity: _lastRequestedQuantity,
      explicitTargetStep: _lastExplicitTargetStep,
    );
  }

  /// Kübik çekmecede TEK bir gözün kapağını açar.
  Future<void> openCubicLid(MedicineAssignment cellAssignment) async {
    _setStage(const MasterDrawerOpeningLid());
    try {
      await _openCubicLid(cellAssignment: cellAssignment);
      if (_isDisposed) return;
      _setStage(const MasterDrawerOpened());
    } on CabinConnectionException catch (e) {
      if (_isDisposed) return;
      _setStage(
        MasterDrawerFailed(
          failure: e.failure == CabinConnectionFailure.managerNotFound
              ? MasterDrawerFailure.managerNotFound
              : MasterDrawerFailure.managerConnectFailed,
          detail: e.detail,
        ),
      );
    } on MasterDrawerException catch (e) {
      if (_isDisposed) return;
      _setStage(MasterDrawerLidFailed(failure: e.failure, detail: e.detail));
    }
  }

  /// Ana çekmece fiziksel olarak tam açıldığı (Opened) andan itibaren
  /// çekmecenin kapanışını SÜREKLİ izler — confirmClose() çağrılıp
  /// çağrılmadığına bakılmaksızın. Aynı subscription iki farklı anlama gelir:
  ///   - confirmClose() ÇAĞRILMADAN "locked" gelirse → BEKLENMEDİK kapanış,
  ///     terminal MasterDrawerFailed(unexpectedlyClosed).
  ///   - confirmClose() ÇAĞRILDIKTAN SONRA "locked" gelirse → BEKLENEN
  ///     kapanış, MasterDrawerClosed.
  void _startPassiveCloseWatch() {
    _sensorSub?.cancel();
    final assignment = _lastAssignment;
    if (assignment == null) return;

    _sensorSub = _monitorClosure(assignment: assignment).listen((event) {
      switch (event) {
        case DrawerClosed():
          if (_stage is MasterDrawerWaitingForClose) {
            _setStage(const MasterDrawerClosed());
          } else {
            _setStage(const MasterDrawerFailed(failure: MasterDrawerFailure.unexpectedlyClosed));
          }
          _sensorSub?.cancel();
          _sensorSub = null;
        case DrawerFailed(:final failure, :final detail):
          _setStage(MasterDrawerFailed(failure: failure as MasterDrawerFailure, detail: detail));
          _sensorSub?.cancel();
          _sensorSub = null;
        default:
          break;
      }
    });
  }

  Future<void> _cancelAll() async {
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

    // Ana çekmece ilk kez fiziksel olarak tam açıldığında pasif izlemeyi
    // başlat. openCubicLid'in ürettiği Opened event'leri BU akıştan
    // GELMEZ, bu callback yalnızca gerçek ana çekmece açılışında tetiklenir.
    if (event is DrawerOpened) {
      _startPassiveCloseWatch();
    }
  }
}
