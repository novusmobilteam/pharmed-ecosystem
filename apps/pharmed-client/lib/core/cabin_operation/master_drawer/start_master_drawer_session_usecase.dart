// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// Master kabin çekmece oturumunu başlatır ve aşamaları stream olarak yayınlar.
//
// OpenDrawerUseCase'in callback bazlı yapısını stream'e çevirir.
// MobileDrawerSessionNotifier ile aynı pattern'de kullanılabilir.
//
// Kübik çekmece akışı:
//   Opening → WaitingForPull → (sensor fullyOpen) → OpeningLid →
//   Opened → WaitingForClose → (sensor locked) → Closed
//
// Standart çekmece akışı:
//   Opening → WaitingForPull → (sensor fullyOpen) → Opened →
//   WaitingForClose → (sensor locked) → Closed
//
// Sınıf: Class B

import 'dart:async';

import 'package:pharmed_core/pharmed_core.dart';

import 'master_drawer_stage.dart';

class StartMasterDrawerSessionUseCase {
  StartMasterDrawerSessionUseCase(this._service);

  final ICabinOperationService _service;

  /// [assignment] için çekmece oturumu başlatır.
  ///
  /// [openCubicLid] true ise kübik çekmecelerde kapak açma aşaması eklenir.
  /// İade işlemlerinde false geçilir — sadece çekmece açılır, kapak açılmaz.
  Stream<MasterDrawerStage> call({required MedicineAssignment assignment, bool openCubicLid = true}) async* {
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final isSerum = assignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
    final address = calculateAddressFromAssignment(assignment);
    final portName = assignment.cabin?.comPort?.name;

    // ── 1. Bağlan ─────────────────────────────────────────────────────────
    yield const MasterDrawerOpening(message: 'Cihaz hazırlanıyor...');

    final ManagementCard manager;
    try {
      final found = await _service.getOrScanManager(targetPort: portName);
      if (found == null) {
        yield const MasterDrawerFailed(message: 'Yönetim kartı bulunamadı.');
        return;
      }
      manager = found;
    } catch (e) {
      yield MasterDrawerFailed(message: 'Bağlantı hatası: $e');
      return;
    }

    // ── 2. Kilit aç ───────────────────────────────────────────────────────
    yield const MasterDrawerOpening(message: 'Kilit açılıyor...');

    try {
      if (isSerum) {
        await _service.openMasterSerumDrawer(manager: manager, row: address.row);
      } else if (isKubik) {
        final monitorAddress = DrawerAddress.cubicMaster(address.row);
        await _service.openMasterDrawer(
          manager: manager,
          row: monitorAddress.row,
          port: monitorAddress.port,
          drawer: monitorAddress.index,
        );
      } else {
        await _service.openMasterDrawer(manager: manager, row: address.row, port: address.port, drawer: address.index);
      }
    } catch (e) {
      yield MasterDrawerFailed(message: 'Kilit açılamadı: $e');
      return;
    }

    yield const MasterDrawerWaitingForPull();

    // ── 3. Sensor stream — çekmecenin açılmasını bekle ───────────────────
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

    // WaitingForPull → fullyOpen bekle
    await for (final status in sensorStream) {
      if (status == DrawerPhysicalStatus.fullyOpen || status == DrawerPhysicalStatus.halfOpen) {
        break;
      }
    }

    // ── 4. Kübik: kapak açma ──────────────────────────────────────────────
    if (isKubik && openCubicLid) {
      yield const MasterDrawerOpeningLid();

      try {
        final monitorAddress = DrawerAddress.cubicMaster(address.row);
        // Tüm kapakları aç — lidIndex 0'dan başlar
        final lidCount = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.compartmentCount ?? 16;
        for (int i = 0; i < lidCount; i++) {
          await _service.openMasterCubicDrawer(
            manager: manager,
            row: monitorAddress.row,
            port: monitorAddress.port,
            lidIndex: i,
          );
        }
      } catch (e) {
        yield MasterDrawerFailed(message: 'Kapak açılamadı: $e');
        return;
      }
    }

    // ── 5. Kullanıcı işlem yapabilir ──────────────────────────────────────
    yield const MasterDrawerOpened();

    // ── 6. Kullanıcı dolumu onaylayınca WaitingForClose tetiklenir ────────
    // Bu aşama MasterDrawerSessionNotifier.confirmClose() ile dışarıdan tetiklenir.
    // Use case burada durur — notifier manuel geçiş yapar.
    // Sensor stream notifier tarafında ayrıca dinlenir.
    //
    // Not: Stream burada sonlanır. Notifier Opened sonrası sensor'ı
    // ayrı subscription ile izler, locked gelince Closed'a geçer.
  }
}
