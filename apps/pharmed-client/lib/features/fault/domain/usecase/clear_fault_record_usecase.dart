import 'package:pharmed_core/pharmed_core.dart';

class CreateFaultRecordParams {
  final Fault fault;
  final int slotId;
  final CabinWorkingStatus status;

  CreateFaultRecordParams({required this.fault, required this.slotId, required this.status});
}

class ClearFaultRecordUseCase {
  final IFaultRepository _repository;

  ClearFaultRecordUseCase(this._repository);

  Future<Result<void>> call(CreateFaultRecordParams params) {
    final status = params.status;
    final fault = params.fault;
    final slotId = params.slotId;
    final res = status == CabinWorkingStatus.maintenance
        ? _repository.clearMaintenanceRecord(fault, slotId)
        : _repository.clearFaultRecord(fault, slotId);
    return res;
  }
}
