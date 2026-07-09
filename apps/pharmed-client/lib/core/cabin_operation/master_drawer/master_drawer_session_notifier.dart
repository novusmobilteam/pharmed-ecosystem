// pharmed-client/lib/core/cabin_operation/master_drawer_session_notifier.dart
//
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
// DEĞİŞİKLİK: Kübik lid açma artık burada — start() tüm lid'leri açmaz, sadece
// ana çekmeceyi açar. Lid'ler feature notifier'ın talebiyle tek tek açılır.
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../providers/providers.dart';
import 'master_drawer_stage.dart';
import 'start_master_drawer_session_usecase.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class MasterDrawerSessionState {
  const MasterDrawerSessionState({required this.stage});
  const MasterDrawerSessionState.initial() : stage = const MasterDrawerIdle();

  final MasterDrawerStage stage;

  MasterDrawerSessionState copyWith({MasterDrawerStage? stage}) => MasterDrawerSessionState(stage: stage ?? this.stage);
}

// ── Provider ──────────────────────────────────────────────────────────────────

final masterDrawerSessionProvider = NotifierProvider<MasterDrawerSessionNotifier, MasterDrawerSessionState>(
  MasterDrawerSessionNotifier.new,
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class MasterDrawerSessionNotifier extends Notifier<MasterDrawerSessionState> {
  StreamSubscription<MasterDrawerStage>? _sessionSub;
  StreamSubscription<DrawerPhysicalStatus>? _sensorSub;

  // reopen için son parametreler
  MedicineAssignment? _lastAssignment;

  StartMasterDrawerSessionUseCase get _startSession => ref.read(startMasterDrawerSessionUseCaseProvider);
  ICabinOperationService get _service => ref.read(cabinOperationServiceProvider);

  @override
  MasterDrawerSessionState build() {
    ref.onDispose(_cancelAll);
    return const MasterDrawerSessionState.initial();
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Yeni bir çekmece oturumu başlatır (ana çekmece açılır, kübikte lid açılmaz).
  Future<void> start({required MedicineAssignment assignment}) async {
    await _cancelAll();
    _lastAssignment = assignment;

    _sessionSub = _startSession
        .call(assignment: assignment)
        .listen(
          _handleStage,
          onError: (e, _) {
            MedLogger.error(
              unit: 'MasterDrawerSessionNotifier',
              swreq: 'SWREQ-CLI-CABIN-OP-012',
              message: 'Session stream hatası',
              context: {'error': e.toString()},
            );
            state = state.copyWith(
              stage: MasterDrawerFailed(message: contextlessL10n().common_error_unexpectedWithDetail(e.toString())),
            );
          },
          onDone: () => _sessionSub = null,
        );
  }

  /// Kübik çekmecede TEK bir gözün kapağını açar.
  ///
  /// [cellAssignment] açılacak göze ait atamadır (kendi orderNo/compartmentNo
  /// ile lid adresi hesaplanır). Lid kapanma sensörü donanımda olmadığından
  /// kapanma takip edilmez; akış yazılımsal ilerler.
  Future<void> openCubicLid(MedicineAssignment cellAssignment) async {
    final manager = await _service.getOrScanManager(targetPort: cellAssignment.cabin?.comPort?.name);
    if (manager == null) {
      state = state.copyWith(
        stage: MasterDrawerFailed(message: contextlessL10n().core_cabinConn_managerNotFoundError),
      );
      return;
    }

    final address = calculateAddressFromAssignment(cellAssignment);
    try {
      await _service.openMasterCubicDrawer(
        manager: manager,
        row: address.row,
        port: address.port,
        lidIndex: address.index,
      );
    } catch (e) {
      state = state.copyWith(
        stage: MasterDrawerFailed(message: contextlessL10n().masterDrawer_lidOpenFailedError(e.toString())),
      );
    }
  }

  /// Kullanıcı dolumu tamamladı — çekmece kapanması bekleniyor.
  /// Sadece [MasterDrawerOpened] state'inde çağrılabilir.
  void confirmClose() {
    if (state.stage is! MasterDrawerOpened) return;
    state = state.copyWith(stage: const MasterDrawerWaitingForClose());
    _startCloseMonitoring();
  }

  /// Aynı assignment ile oturumu yeniden başlatır.
  Future<void> reopen() async {
    if (_lastAssignment == null) return;
    await start(assignment: _lastAssignment!);
  }

  /// Oturumu sonlandırır, tüm subscription'ları iptal eder.
  Future<void> stop() async {
    await _cancelAll();
    state = const MasterDrawerSessionState.initial();
  }

  // ── Private ──────────────────────────────────────────────────────────────

  void _handleStage(MasterDrawerStage stage) {
    state = state.copyWith(stage: stage);
  }

  /// [MasterDrawerWaitingForClose] sonrası sensor stream'i başlatır.
  void _startCloseMonitoring() {
    _sensorSub?.cancel();

    final assignment = _lastAssignment;
    if (assignment == null) return;

    final isSerum = assignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final address = calculateAddressFromAssignment(assignment);

    _service.getOrScanManager(targetPort: assignment.cabin?.comPort?.name).then((manager) {
      if (manager == null) {
        state = state.copyWith(
        stage: MasterDrawerFailed(message: contextlessL10n().core_cabinConn_managerNotFoundError),
      );
        return;
      }

      final Stream<DrawerPhysicalStatus> sensorStream;
      if (isSerum) {
        sensorStream = _service.streamMasterSerumDrawerStatus(manager: manager, row: address.row);
      } else if (isKubik) {
        final monitorAddress = DrawerAddress.cubicMaster(address.row);
        sensorStream = _service.streamMasterDrawerStatus(
          manager: manager,
          row: monitorAddress.row,
          port: monitorAddress.port,
          drawer: monitorAddress.index,
        );
      } else {
        sensorStream = _service.streamMasterDrawerStatus(
          manager: manager,
          row: address.row,
          port: address.port,
          drawer: address.index,
        );
      }

      _sensorSub = sensorStream.listen((status) {
        if (state.stage is! MasterDrawerWaitingForClose) {
          _sensorSub?.cancel();
          return;
        }
        if (status == DrawerPhysicalStatus.locked) {
          state = state.copyWith(stage: const MasterDrawerClosed());
          _sensorSub?.cancel();
          _sensorSub = null;
        }
      });
    });
  }

  Future<void> _cancelAll() async {
    await _sessionSub?.cancel();
    await _sensorSub?.cancel();
    _sessionSub = null;
    _sensorSub = null;
  }
}
