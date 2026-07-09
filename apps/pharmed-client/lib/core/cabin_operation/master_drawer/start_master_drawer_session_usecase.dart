// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// Master kabin çekmece oturumunu başlatır ve aşamaları stream olarak yayınlar.
//
// DEĞİŞİKLİK (ilaç-merkezli dolum): Kübik çekmecede artık TÜM lid'ler otomatik
// açılmaz. Ana çekmece açılır ve Opened yayınlanır; lid açma kontrolü feature
// notifier'a (MasterRefillNotifier) devredilmiştir — notifier hedef gözlerin
// lid'lerini openMasterCubicDrawer ile tek tek açar (lid-by-lid alt-kuyruk).
//
// Bu sayede:
//   - sadece dolum yapılacak gözlerin kapakları açılır
//   - her göz ayrı doldurulup ayrı API isteğiyle kaydedilir
//
// Kübik çekmece akışı (bu use case):
//   Opening → WaitingForPull → (sensor fullyOpen) → Opened
//   (lid açma notifier tarafında yapılır)
//
// Standart çekmece akışı:
//   Opening → WaitingForPull → (sensor fullyOpen) → Opened →
//   WaitingForClose → (sensor locked) → Closed
//
// Sınıf: Class B

import 'dart:async';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'master_drawer_stage.dart';

class StartMasterDrawerSessionUseCase {
  StartMasterDrawerSessionUseCase(this._service);

  final ICabinOperationService _service;

  /// [assignment] için çekmece oturumu başlatır.
  ///
  /// Kübik çekmecelerde kapak (lid) açma BU use case'te YAPILMAZ; ana çekmece
  /// açılır ve Opened yayınlanır. Lid açma feature notifier'ın sorumluluğundadır.
  Stream<MasterDrawerStage> call({required MedicineAssignment assignment}) async* {
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final isSerum = assignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
    final address = calculateAddressFromAssignment(assignment);
    final portName = assignment.cabin?.comPort?.name;

    // ── 1. Bağlan ─────────────────────────────────────────────────────────
    yield MasterDrawerOpening(message: contextlessL10n().common_action_devicePreparing);

    final ManagementCard manager;
    try {
      final found = await _service.getOrScanManager(targetPort: portName);
      if (found == null) {
        yield MasterDrawerFailed(message: contextlessL10n().core_cabinConn_managerNotFoundError);
        return;
      }
      manager = found;
    } catch (e) {
      yield MasterDrawerFailed(message: contextlessL10n().common_error_connectionErrorWithDetail(e.toString()));
      return;
    }

    // ── 2. Kilit aç ───────────────────────────────────────────────────────
    yield MasterDrawerOpening(message: contextlessL10n().common_action_lockOpening);

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
      yield MasterDrawerFailed(message: contextlessL10n().common_error_lockOpenFailedWithDetail(e.toString()));
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

    // ── 4. Kullanıcı işlem yapabilir ──────────────────────────────────────
    // Kübikte lid açma notifier tarafında lid-by-lid yapılır.
    yield const MasterDrawerOpened();

    // ── 5. Kullanıcı dolumu onaylayınca WaitingForClose tetiklenir ────────
    // confirmClose() ile dışarıdan; sensor stream notifier tarafında izlenir.
  }
}
