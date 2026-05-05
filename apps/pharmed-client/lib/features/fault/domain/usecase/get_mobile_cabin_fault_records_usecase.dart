import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final getMobileCabinFaultRecordsProvider = Provider<GetMobileCabinFaultRecordsUseCase>((ref) {
  return GetMobileCabinFaultRecordsUseCase(ref.read(faultRepositoryProvider));
});

class GetMobileCabinFaultRecordsUseCase {
  final IFaultRepository _repository;

  GetMobileCabinFaultRecordsUseCase(this._repository);

  Future<Result<List<MobileFault>>> call() {
    return _repository.getMobileCabinFaultRecords();
  }
}
