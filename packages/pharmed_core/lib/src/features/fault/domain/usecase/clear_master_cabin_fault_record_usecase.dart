import 'package:pharmed_core/pharmed_core.dart';

class ClearMasterCabinFaultRecordUseCase {
  final IFaultRepository _repository;

  ClearMasterCabinFaultRecordUseCase(this._repository);

  Future<Result<void>> call({required CabinWorkingStatus status, required MasterFault fault, required int cellId}) {
    final response = status == CabinWorkingStatus.maintenance
        ? _repository.clearMasterCabinMaintenanceRecord(fault, cellId)
        : _repository.clearMasterCabinFaultRecord(fault, cellId);

    return response;
  }
}
