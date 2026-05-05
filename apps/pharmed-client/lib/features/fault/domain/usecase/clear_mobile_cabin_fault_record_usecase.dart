import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final clearMobileCabinFaultRecordProvider = Provider<ClearMobileCabinFaultRecordUseCase>((ref) {
  return ClearMobileCabinFaultRecordUseCase(ref.read(faultRepositoryProvider));
});

class ClearMobileCabinFaultRecordUseCase {
  final IFaultRepository _repository;

  ClearMobileCabinFaultRecordUseCase(this._repository);

  Future<Result<void>> call({required CabinWorkingStatus status, required MobileFault fault, required int slotId}) {
    final response = status == CabinWorkingStatus.maintenance
        ? _repository.clearMobilCabinMaintenanceRecord(fault, slotId)
        : _repository.clearMobilCabinFaultRecord(fault, slotId);

    return response;
  }
}
