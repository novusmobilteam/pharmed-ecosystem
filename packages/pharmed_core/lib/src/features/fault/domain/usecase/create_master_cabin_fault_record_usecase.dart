import 'package:pharmed_core/pharmed_core.dart';

class CreateMasterCabinFaultRecordUseCase {
  final IFaultRepository _repository;

  CreateMasterCabinFaultRecordUseCase(this._repository);

  Future<Result<void>> call({required CabinWorkingStatus status, required MasterFault fault, required int cellId}) {
    final response = status == CabinWorkingStatus.maintenance
        ? _repository.createMasterCabinMaintenanceRecord(fault, cellId)
        : _repository.createMasterCabinFaultRecord(fault, cellId);

    return response;
  }
}
