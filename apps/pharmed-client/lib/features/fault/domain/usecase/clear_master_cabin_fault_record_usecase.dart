import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final clearMasterCabinFaultRecordProvider = Provider<ClearMasterCabinFaultRecordUseCase>((ref) {
  return ClearMasterCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

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
