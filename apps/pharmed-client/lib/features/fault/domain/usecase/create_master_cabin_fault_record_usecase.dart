import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final createMasterCabinFaultRecordProvider = Provider<CreateMasterCabinFaultRecordUseCase>((ref) {
  return CreateMasterCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

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
