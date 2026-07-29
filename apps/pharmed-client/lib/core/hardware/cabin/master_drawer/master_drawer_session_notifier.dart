// [SWREQ-CLI-CABIN-OP-012] [IEC 62304 §5.5]
// Master kabin çekmece oturumunun yaşam döngüsünü yönetir.
//
// Sorumluluk:
//   - StartMasterDrawerSessionUseCase stream'ini dinler, stage'i state'e yansıtır
//   - Opened sonrası sensor'ı ayrı subscription ile izler (WaitingForClose → Closed)
//   - confirmClose() ile kullanıcı dolumu onayladığında WaitingForClose'a geçer
//   - openCubicLid() ile kübik çekmecede TEK bir gözün kapağını açar (lid-by-lid)
//   - reopen / stop API'leri sunar
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../providers/providers.dart';
import 'master_drawer_session_state.dart';
import 'master_drawer_stage.dart';

final masterDrawerSessionProvider = NotifierProvider<MasterDrawerSessionNotifier, MasterDrawerSessionState>(
  MasterDrawerSessionNotifier.new,
);

class MasterDrawerSessionNotifier extends Notifier<MasterDrawerSessionState> {
  StreamSubscription<DrawerSessionEvent>? _sessionSub;
  StreamSubscription<DrawerSessionEvent>? _sensorSub;

  MedicineAssignment? _lastAssignment;
  double _lastRequestedQuantity = 0.0;
  int? _lastExplicitTargetStep;

  StartMasterDrawerSessionUseCase get _startSession => ref.read(startMasterDrawerSessionUseCaseProvider);
  OpenCubicLidUseCase get _openCubicLid => ref.read(openCubicLidUseCaseProvider);
  MonitorDrawerCloseUseCase get _monitorClose => ref.read(monitorDrawerCloseUseCaseProvider);

  @override
  MasterDrawerSessionState build() {
    ref.onDispose(_cancelAll);
    return const MasterDrawerSessionState.initial();
  }

  /// Yeni bir çekmece oturumu başlatır (ana çekmece açılır, kübikte lid açılmaz).
  ///
  /// [requestedQuantity]/[explicitTargetStep]: bkz. StartMasterDrawerSessionUseCase.call.
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
            MedLogger.error(
              unit: 'MasterDrawerSessionNotifier',
              swreq: 'SWREQ-CLI-CABIN-OP-012',
              message: 'Session stream hatası',
              context: {'error': e.toString()},
            );
            state = state.copyWith(
              stage: MasterDrawerFailed(failure: MasterDrawerFailure.managerConnectFailed, detail: e.toString()),
            );
          },
          onDone: () => _sessionSub = null,
        );
  }

  /// Kübik çekmecede TEK bir gözün kapağını açar.
  Future<void> openCubicLid(MedicineAssignment cellAssignment) async {
    try {
      await _openCubicLid(cellAssignment: cellAssignment);
    } on CabinConnectionException catch (e) {
      state = state.copyWith(
        stage: MasterDrawerFailed(
          failure: e.failure == CabinConnectionFailure.managerNotFound
              ? MasterDrawerFailure.managerNotFound
              : MasterDrawerFailure.managerConnectFailed,
          detail: e.detail,
        ),
      );
    } on MasterDrawerException catch (e) {
      state = state.copyWith(
        stage: MasterDrawerFailed(failure: e.failure, detail: e.detail),
      );
    }
  }

  void confirmClose() {
    if (state.stage is! MasterDrawerOpened) return;
    state = state.copyWith(stage: const MasterDrawerWaitingForClose());
    _startCloseMonitoring();
  }

  /// Son assignment VE son requestedQuantity/explicitTargetStep ile oturumu
  /// yeniden başlatır.
  Future<void> reopen() async {
    if (_lastAssignment == null) return;
    await start(
      assignment: _lastAssignment!,
      requestedQuantity: _lastRequestedQuantity,
      explicitTargetStep: _lastExplicitTargetStep,
    );
  }

  Future<void> stop() async {
    await _cancelAll();
    state = const MasterDrawerSessionState.initial();
  }

  void _startCloseMonitoring() {
    _sensorSub?.cancel();

    final assignment = _lastAssignment;
    if (assignment == null) return;

    _sensorSub = _monitorClose(assignment: assignment).listen((event) {
      if (state.stage is! MasterDrawerWaitingForClose) {
        _sensorSub?.cancel();
        return;
      }
      switch (event) {
        case DrawerClosed():
          state = state.copyWith(stage: const MasterDrawerClosed());
          _sensorSub?.cancel();
          _sensorSub = null;
        case DrawerFailed(:final failure, :final detail):
          state = state.copyWith(
            stage: MasterDrawerFailed(failure: failure as MasterDrawerFailure, detail: detail),
          );
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
    state = state.copyWith(stage: stage);
  }
}
