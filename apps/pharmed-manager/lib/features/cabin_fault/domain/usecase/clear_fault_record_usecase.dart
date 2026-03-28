import '../../../../core/core.dart';
import '../entity/cabin_fault.dart';
import '../repository/i_cabin_fault_repository.dart';

class CreateFaultRecordParams {
  final CabinFault fault;
  final int slotId;
  final CabinWorkingStatus status;

  CreateFaultRecordParams({required this.fault, required this.slotId, required this.status});
}

class ClearFaultRecordUseCase implements UseCase<void, CreateFaultRecordParams> {
  final ICabinFaultRepository _repository;

  ClearFaultRecordUseCase(this._repository);

  @override
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
