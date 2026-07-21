// [SWREQ-CLI-CABIN-OP-012] [IEC 62304 §5.5]
// Kübik çekmecede tek bir gözün kapağını açar.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class OpenCubicLidUseCase {
  const OpenCubicLidUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  /// Throws [CabinConnectionException] manager edinilemezse.
  /// Throws [MasterDrawerException] lid açma başarısız olursa.
  Future<void> call({required MedicineAssignment cellAssignment}) async {
    final manager = await _scanManager(targetPort: cellAssignment.cabin?.comPort?.name);

    final address = calculateAddressFromAssignment(cellAssignment);
    try {
      await _cabinOps.openMasterCubicDrawer(
        manager: manager,
        row: address.row,
        port: address.port,
        lidIndex: address.index,
      );
    } catch (e) {
      throw MasterDrawerException(MasterDrawerFailure.lidOpenFailed, detail: e.toString());
    }
  }
}

class MasterDrawerException implements Exception {
  const MasterDrawerException(this.failure, {this.detail});

  final MasterDrawerFailure failure;
  final String? detail;
}
