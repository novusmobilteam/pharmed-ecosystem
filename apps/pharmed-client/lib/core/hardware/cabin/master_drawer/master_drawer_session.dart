import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../providers/providers.dart';
import '../../hardware.dart';

final drawerExecutionSessionProvider = Provider<IMasterDrawerSession>((ref) {
  final session = MasterDrawerSession(
    startSession: ref.read(startMasterDrawerSessionUseCaseProvider),
    openCubicLid: ref.read(openCubicLidUseCaseProvider),
    monitorClosure: ref.read(monitorDrawerClosureUseCaseProvider),
    cabinOperationService: ref.read(cabinOperationServiceProvider),
  );
  ref.onDispose(session.dispose);
  return session;
});

abstract class IMasterDrawerSession implements Listenable {
  MasterDrawerStage get stage;

  Future<void> start({required MedicineAssignment assignment, double requestedQuantity = 0.0, int? explicitTargetStep});

  Future<void> openCubicLid(MedicineAssignment cellAssignment);
  void confirmClose();
  Future<void> reopen();
  Future<void> stop();
}

// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// Master kabin çekmece oturumunun TEK gerçek kaynağı. Uygulama ömrü boyunca
// tek örnek olmalı — masterDrawerSessionProvider ile DI'dan enjekte edilir,
// kendi kendine singleton YARATMAZ (bkz. aşağıdaki provider).
//
// Sınıf: Class B
class MasterDrawerSession extends ChangeNotifier implements IMasterDrawerSession {
  MasterDrawerSession({
    required StartMasterDrawerSessionUseCase startSession,
    required OpenCubicLidUseCase openCubicLid,
    required MonitorDrawerClosureUseCase monitorClosure,
    required ICabinOperationService cabinOperationService,
  }) : _startSession = startSession,
       _openCubicLidUseCase = openCubicLid,
       _monitorClosure = monitorClosure,
       _cabinOperationService = cabinOperationService;

  final StartMasterDrawerSessionUseCase _startSession;
  final OpenCubicLidUseCase _openCubicLidUseCase;
  final MonitorDrawerClosureUseCase _monitorClosure;
  final ICabinOperationService _cabinOperationService;

  StreamSubscription<DrawerSessionEvent>? _sessionSub;
  StreamSubscription<DrawerSessionEvent>? _sensorSub;

  MedicineAssignment? _lastAssignment;
  double _lastRequestedQuantity = 0.0;
  int? _lastExplicitTargetStep;

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
  }) async {
    await _cancelAll();
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

  @override
  Future<void> stop() async {
    await _cancelAll();
    _setStage(const MasterDrawerIdle());
  }

  @override
  void confirmClose() {
    if (_stage is! MasterDrawerOpened) return;
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
    );
  }

  @override
  Future<void> openCubicLid(MedicineAssignment cellAssignment) async {
    _setStage(const MasterDrawerOpeningLid());
    try {
      await _openCubicLidUseCase(cellAssignment: cellAssignment);
      _setStage(const MasterDrawerOpened());
    } on CabinConnectionException catch (e) {
      _setStage(
        MasterDrawerFailed(
          failure: e.failure == CabinConnectionFailure.managerNotFound
              ? MasterDrawerFailure.managerNotFound
              : MasterDrawerFailure.managerConnectFailed,
          detail: e.detail,
        ),
      );
    } on MasterDrawerException catch (e) {
      _setStage(MasterDrawerLidFailed(failure: e.failure, detail: e.detail));
    }
  }

  void _startPassiveCloseWatch() {
    _sensorSub?.cancel();
    final assignment = _lastAssignment;
    if (assignment == null) return;

    _sensorSub = _monitorClosure(assignment: assignment).listen((event) {
      switch (event) {
        case DrawerClosed():
          _setStage(
            _stage is MasterDrawerWaitingForClose
                ? const MasterDrawerClosed()
                : const MasterDrawerFailed(failure: MasterDrawerFailure.unexpectedlyClosed),
          );
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
