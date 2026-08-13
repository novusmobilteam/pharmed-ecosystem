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
  MonitorDrawerClosureUseCase get _monitorClosure => ref.read(monitorDrawerClosureUseCaseProvider);

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
            state = state.copyWith(
              stage: MasterDrawerFailed(failure: MasterDrawerFailure.managerConnectFailed, detail: e.toString()),
            );
          },
          onDone: () => _sessionSub = null,
        );
  }

  Future<void> stop() async {
    await _cancelAll();
    state = const MasterDrawerSessionState.initial();
  }

  /// Kullanıcı işlemi tamamladı — mevcut (Opened'dan beri zaten çalışan)
  /// sensör takibi artık "resmi" kapanışı bekliyor sayılır. Yeni bir
  /// subscription BAŞLATILMAZ — _startPassiveCloseWatch'ın Opened anında
  /// kurduğu subscription buradan itibaren WaitingForClose yorumuna geçer.
  void confirmClose() {
    if (state.stage is! MasterDrawerOpened) return;
    state = state.copyWith(stage: const MasterDrawerWaitingForClose());
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

  /// Kübik çekmecede TEK bir gözün kapağını açar.
  Future<void> openCubicLid(MedicineAssignment cellAssignment) async {
    state = state.copyWith(stage: const MasterDrawerOpeningLid());
    try {
      await _openCubicLid(cellAssignment: cellAssignment);
      state = state.copyWith(stage: const MasterDrawerOpened());
    } on CabinConnectionException catch (e) {
      // Yönetim kartına HİÇ ulaşılamadı - bu, tek bir kapağın sorunu değil,
      // bağlantının kendisi kopmuş demektir. Oturumun devamı anlamsız,
      // terminal Failed'a düşüyoruz (çekmece durumu artık bilinmiyor).
      state = state.copyWith(
        stage: MasterDrawerFailed(
          failure: e.failure == CabinConnectionFailure.managerNotFound
              ? MasterDrawerFailure.managerNotFound
              : MasterDrawerFailure.managerConnectFailed,
          detail: e.detail,
        ),
      );
    } on MasterDrawerException catch (e) {
      // Bağlantı sağlamdı, SADECE bu kapağın açma komutu reddedildi (örn.
      // "ht"). Çekmece fiziksel olarak hâlâ açık - oturum aktif kalır,
      // kullanıcı aynı/başka bir gözü tekrar deneyebilir.
      state = state.copyWith(
        stage: MasterDrawerLidFailed(failure: e.failure, detail: e.detail),
      );
    }
  }

  /// Ana çekmece fiziksel olarak tam açıldığı (Opened) andan itibaren
  /// çekmecenin kapanışını SÜREKLİ izler — confirmClose() çağrılıp
  /// çağrılmadığına bakılmaksızın. Aynı subscription iki farklı anlama
  /// gelir:
  ///   - confirmClose() ÇAĞRILMADAN "locked" gelirse → kullanıcı işlemi
  ///     onaylamadan çekmeceyi fiziksel olarak kapattı → BEKLENMEDİK,
  ///     terminal MasterDrawerFailed(unexpectedlyClosed).
  ///   - confirmClose() ÇAĞRILDIKTAN SONRA (stage=WaitingForClose iken)
  ///     "locked" gelirse → BEKLENEN kapanış → MasterDrawerClosed.
  /// OpeningLid/LidFailed geçişleri sırasında bu subscription KESİLMEZ —
  /// kübik gözler arası geçişte de beklenmedik kapanma tespit edilir.
  void _startPassiveCloseWatch() {
    _sensorSub?.cancel();

    final assignment = _lastAssignment;
    if (assignment == null) return;

    _sensorSub = _monitorClosure(assignment: assignment).listen((event) {
      switch (event) {
        case DrawerClosed():
          if (state.stage is MasterDrawerWaitingForClose) {
            state = state.copyWith(stage: const MasterDrawerClosed());
          } else {
            state = state.copyWith(stage: const MasterDrawerFailed(failure: MasterDrawerFailure.unexpectedlyClosed));
          }
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

    // Ana çekmece ilk kez fiziksel olarak tam açıldığında pasif izlemeyi
    // başlat. openCubicLid'in ürettiği Opened event'leri BU akıştan
    // GELMEZ (StartMasterDrawerSessionUseCase'in stream'i değil,
    // openCubicLid kendi state güncellemesini doğrudan yapıyor) - yani
    // bu callback yalnızca gerçek ana çekmece açılışında tetiklenir,
    // her kapak açılışında YENİDEN BAŞLATILMAZ (zaten gerek de yok,
    // subscription hâlâ canlı).
    if (event is DrawerOpened) {
      _startPassiveCloseWatch();
    }
  }
}
