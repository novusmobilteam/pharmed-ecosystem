import 'package:pharmed_core/pharmed_core.dart';

import '../repository/i_cabin_fault_repository.dart';
import 'clear_fault_record_usecase.dart';

class CreateFaultRecordUseCase implements UseCase<void, CreateFaultRecordParams> {
  final ICabinFaultRepository _repository;

  CreateFaultRecordUseCase(this._repository);

  @override
  Future<Result<void>> call(CreateFaultRecordParams params) {
    final status = params.status;
    final fault = params.fault;
    final slotId = params.slotId;
    final res = status == CabinWorkingStatus.maintenance
        ? _repository.createMaintenanceRecord(fault, slotId)
        : _repository.createFaultRecord(fault, slotId);
    return res;
  }
}
