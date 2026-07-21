import 'package:pharmed_core/pharmed_core.dart';

class ScanManagerUseCase {
  const ScanManagerUseCase(this._cabinOps);

  final ICabinOperationService _cabinOps;

  Future<ManagementCard> call({String? targetPort}) async {
    try {
      final manager = await _cabinOps.getOrScanManager(targetPort: targetPort);
      if (manager == null) {
        throw const CabinConnectionException(CabinConnectionFailure.managerNotFound);
      }
      return manager;
    } catch (e) {
      if (e is CabinConnectionException) rethrow;
      throw CabinConnectionException(CabinConnectionFailure.managerConnectFailed, detail: e.toString());
    }
  }
}
