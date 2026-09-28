import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_session.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_stage.dart';
import 'package:pharmed_core/pharmed_core.dart';

// [SWREQ-CLI-DRAWER-EXEC-MIXIN-001] [IEC 62304 §5.5]
// Master kabin çekmece oturumuna (global tekil IMasterDrawerSession) bağlanan
// feature notifier'lar için ortak altyapı — KUYRUK KAVRAMINDAN HABERSİZ, sadece
// tek bir fiziksel oturumun (aç/kapa/lid) ham mekaniğini sarar.
//
// Kullanan sınıf:
///  - `drawerSession` getter'ını sağlamalı (Provider'dan / testte fake ile enjekte edilir)
///  - attachDrawerSession() çağrısını constructor'da yapmalı
///  - detachDrawerSession() çağrısını kendi dispose()'unda yapmalı
///  - ilgilendiği hook'ları override etmeli (hepsi varsayılan no-op)
//
// Sınıf: Class B
mixin MasterDrawerExecutionMixin on ChangeNotifier {
  IMasterDrawerSession get drawerSession;

  MasterDrawerStage? _lastStage;
  bool _attached = false;

  MasterDrawerStage get drawerStage => drawerSession.stage;
  bool get isDrawerActive => drawerStage.isActive;

  void attachDrawerSession() {
    if (_attached) return;
    _attached = true;
    _lastStage = drawerSession.stage;
    drawerSession.addListener(_handleStageChange);
  }

  void detachDrawerSession() {
    drawerSession.removeListener(_handleStageChange);
    _attached = false;
  }

  void _handleStageChange() {
    final previous = _lastStage;
    final current = drawerSession.stage;
    _lastStage = current;

    switch (current) {
      case MasterDrawerOpened():
        // SADECE ana çekmece yeni fiziksel olarak açıldıysa tetiklenir.
        // openCubicLid'in kendi Opened event'i previous=OpeningLid (ya da
        // LidFailed — lidNotOpened'dan kurtulma) ile gelir — burada TEKRAR
        // işlenirse "aynı gözü sonsuza kadar yeniden aç" döngüsüne yol açar.
        if (previous is MasterDrawerWaitingForPull) onDrawerOpened();
      case MasterDrawerLidClosed():
        onLidClosed();
      case MasterDrawerClosed():
        onDrawerClosed();
      case MasterDrawerLidFailed(:final failure, :final detail):
        onLidRejected(failure, detail);
      case MasterDrawerFailed(:final failure, :final detail):
        onDrawerFailed(failure, detail);
      default:
        break;
    }

    onStageChanged(previous, current);
    notifyListeners();
  }

  /// Ana çekmece fiziksel olarak (yeniden değil, İLK KEZ) açıldı.
  void onDrawerOpened() {}

  /// Aktif kübik kapak fiziksel olarak kapandı (ac → kp) ya da kullanıcı
  /// sensör koptuğunda kapanışı elle onayladı. Yalnızca kapak
  /// `awaitLidClose: true` ile açıldıysa tetiklenir.
  void onLidClosed() {}

  /// Aktif çekmece/port fiziksel olarak kapandı.
  void onDrawerClosed() {}

  /// Kübik lid açma/izleme hatası — bağlantı sağlam, sadece bu göz.
  void onLidRejected(MasterDrawerFailure failure, String? detail) {}

  /// Terminal donanım hatası — bağlantı koptu ya da beklenmedik kapanış.
  void onDrawerFailed(MasterDrawerFailure failure, String? detail) {}

  Future<void> openDrawer({
    required MedicineAssignment assignment,
    double requestedQuantity = 0.0,
    int? explicitTargetStep,
    bool closeCompletes = false,
  }) => drawerSession.start(
    assignment: assignment,
    requestedQuantity: requestedQuantity,
    explicitTargetStep: explicitTargetStep,
    closeCompletes: closeCompletes,
  );

  /// [awaitLidClose] true ise session kapağı izler: Opened ancak `ac`
  /// okununca gelir, `ac → kp` geçişinde [onLidClosed] tetiklenir.
  Future<void> openCubicLid(MedicineAssignment cellAssignment, {bool awaitLidClose = false}) =>
      drawerSession.openCubicLid(cellAssignment, awaitLidClose: awaitLidClose);

  /// Kullanıcı işlemi onayladı — fiziksel kapanış bekleniyor. Adı bilerek
  /// `closeDrawer` değil `confirmDrawerClose`: donanıma "kapat" komutu
  /// GÖNDERMİYORUZ, kullanıcının onayını bildirip mevcut sensör izlemesinin
  /// artık "beklenen kapanış" yorumuna geçmesini sağlıyoruz (bkz.
  /// MasterDrawerSession.confirmClose dokümantasyonu).
  void confirmDrawerClose() => drawerSession.confirmClose();

  /// Kübik: kullanıcı aktif gözü onayladı — kapağın fiziksel kapanması
  /// bekleniyor. [confirmDrawerClose] ile aynı mantık, göz seviyesinde.
  void confirmLidClose() => drawerSession.confirmLidClose();

  /// LidFailed sonrası aynı gözün kapağını yeniden açmayı dener.
  Future<void> retryCubicLid() => drawerSession.retryCubicLid();

  /// Kapak durum sorgusu koptuğunda (lidSensorLost) kullanıcı kapağın
  /// kapalı olduğunu elle onaylar — session loglar ve LidClosed üretir.
  void acknowledgeLidClosedManually() => drawerSession.acknowledgeLidClosedManually();

  Future<void> reopenDrawer() => drawerSession.reopen();

  Future<void> stopDrawer() => drawerSession.stop();

  /// Her stage değişiminde (belirli hook'lardan SONRA) çağrılır.
  void onStageChanged(MasterDrawerStage? previous, MasterDrawerStage current) {}
}
