// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// Sınıf: Class B

import 'dart:async';
import 'package:pharmed_core/pharmed_core.dart';

class StartMasterDrawerSessionUseCase {
  const StartMasterDrawerSessionUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  /// [requestedQuantity]/[explicitTargetStep]: bkz. calculateAddressFromAssignment.
  /// İkisi de opsiyonel + varsayılan null/0 — mevcut çağıranlar (dolum/sayım/
  /// boşaltma) hiçbir şey geçmediği için davranışları DEĞİŞMEZ, her zaman tam
  /// açılış olur.
  Stream<DrawerSessionEvent> call({
    required MedicineAssignment assignment,
    double requestedQuantity = 0.0,
    int? explicitTargetStep,
  }) async* {
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final isSerum = assignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
    final address = calculateAddressFromAssignment(
      assignment,
      requestedQuantity: requestedQuantity,
      explicitTargetStep: explicitTargetStep,
    );
    final portName = assignment.cabin?.comPort?.name;

    yield const DrawerOpeningWithStep(step: MasterDrawerOpeningStep.devicePreparing);

    final ManagementCard manager;
    try {
      manager = await _scanManager(targetPort: portName);
    } on CabinConnectionException catch (e) {
      yield DrawerFailed(
        failure: e.failure == CabinConnectionFailure.managerNotFound
            ? MasterDrawerFailure.managerNotFound
            : MasterDrawerFailure.managerConnectFailed,
        detail: e.detail,
      );
      return;
    }

    yield const DrawerOpeningWithStep(step: MasterDrawerOpeningStep.lockOpening);

    try {
      if (isSerum) {
        await _cabinOps.openMasterSerumDrawer(manager: manager, row: address.row);
      } else if (isKubik) {
        final monitorAddress = DrawerAddress.cubicMaster(address.row);
        await _cabinOps.openMasterDrawer(
          manager: manager,
          row: monitorAddress.row,
          port: monitorAddress.port,
          drawer: monitorAddress.index,
        );
      } else {
        await _cabinOps.openMasterDrawer(manager: manager, row: address.row, port: address.port, drawer: address.index);
      }
    } catch (e) {
      yield DrawerFailed(failure: MasterDrawerFailure.lockOpenFailed, detail: e.toString());
      return;
    }

    yield const DrawerWaitingForPull();

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
      if (status == DrawerPhysicalStatus.fullyOpen || status == DrawerPhysicalStatus.halfOpen) {
        break;
      }
    }

    yield const DrawerOpened();
  }
}
