import 'package:pharmed_core/pharmed_core.dart';

class CreateMobileCabinFaultRecordUseCase {
  final IFaultRepository _repository;

  CreateMobileCabinFaultRecordUseCase(this._repository);

  Future<Result<void>> call({required CabinWorkingStatus status, required MobileFault fault, required int slotId}) {
    final response = status == CabinWorkingStatus.maintenance
        ? _repository.createMobilCabinMaintenanceRecord(fault, slotId)
        : _repository.createMobilCabinFaultRecord(fault, slotId);

    return response;
  }
}
