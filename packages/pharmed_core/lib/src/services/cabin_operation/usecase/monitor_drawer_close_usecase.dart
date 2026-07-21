// [SWREQ-CLI-CABIN-OP-012] [IEC 62304 §5.5]
// Çekmece kapanmasını sensor stream üzerinden izler.
// WaitingForClose → Closed geçişini tespit edince DrawerClosed yayınlar.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MonitorDrawerCloseUseCase {
  const MonitorDrawerCloseUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  /// [assignment] için çekmece kapanma stream'ini başlatır.
  /// Kapanma tespit edilince [DrawerClosed] yayınlanır, stream sonlanır.
  /// Manager edinilemezse [DrawerFailed] yayınlanır.
  Stream<DrawerSessionEvent> call({required MedicineAssignment assignment}) async* {
    final isSerum = assignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final address = calculateAddressFromAssignment(assignment);

    final ManagementCard manager;
    try {
      manager = await _scanManager(targetPort: assignment.cabin?.comPort?.name);
    } on CabinConnectionException catch (e) {
      yield DrawerFailed(
        failure: e.failure == CabinConnectionFailure.managerNotFound
            ? MasterDrawerFailure.managerNotFound
            : MasterDrawerFailure.managerConnectFailed,
        detail: e.detail,
      );
      return;
    }

    final Stream<DrawerPhysicalStatus> sensorStream;
    if (isSerum) {
      sensorStream = _cabinOps.streamMasterSerumDrawerStatus(manager: manager, row: address.row);
    } else if (isKubik) {
      final monitorAddress = DrawerAddress.cubicMaster(address.row);
      sensorStream = _cabinOps.streamMasterDrawerStatus(
        manager: manager,
        row: monitorAddress.row,
        port: monitorAddress.port,
        drawer: monitorAddress.index,
      );
    } else {
      sensorStream = _cabinOps.streamMasterDrawerStatus(
        manager: manager,
        row: address.row,
        port: address.port,
        drawer: address.index,
      );
    }

    await for (final status in sensorStream) {
      if (status == DrawerPhysicalStatus.locked) {
        yield const DrawerClosed();
        return;
      }
    }
  }
}
