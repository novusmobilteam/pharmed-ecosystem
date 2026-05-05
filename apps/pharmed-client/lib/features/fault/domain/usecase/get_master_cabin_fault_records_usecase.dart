import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final getMasterCabinFaultRecordsProvider = Provider<GetMasterCabinFaultRecordsUseCase>((ref) {
  return GetMasterCabinFaultRecordsUseCase(ref.read(faultRepositoryProvider));
});

class GetMasterCabinFaultRecordsUseCase {
  final IFaultRepository _repository;

  GetMasterCabinFaultRecordsUseCase(this._repository);

  Future<Result<List<MasterFault>>> call() {
    return _repository.getMasterCabinFaultRecords();
  }
}
