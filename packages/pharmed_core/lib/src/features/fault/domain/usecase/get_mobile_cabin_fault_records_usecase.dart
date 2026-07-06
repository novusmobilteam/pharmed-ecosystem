import 'package:pharmed_core/pharmed_core.dart';

class GetMobileCabinFaultRecordsUseCase {
  final IFaultRepository _repository;

  GetMobileCabinFaultRecordsUseCase(this._repository);

  Future<Result<List<MobileFault>>> call(int cabinId) {
    return _repository.getMobileCabinFaultRecords(cabinId);
  }
}
