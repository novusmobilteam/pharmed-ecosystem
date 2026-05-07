import 'package:pharmed_core/pharmed_core.dart';

class GetMobileCabinFaultRecordsUseCase {
  final IFaultRepository _repository;

  GetMobileCabinFaultRecordsUseCase(this._repository);

  Future<Result<List<MobileFault>>> call() {
    return _repository.getMobileCabinFaultRecords();
  }
}
