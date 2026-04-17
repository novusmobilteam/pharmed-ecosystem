import 'package:pharmed_core/pharmed_core.dart';

class GetMasterCabinFaultRecordsUseCase {
  final IFaultRepository _repository;

  GetMasterCabinFaultRecordsUseCase(this._repository);

  Future<Result<List<MasterFault>>> call() {
    return _repository.getMasterCabinFaultRecords();
  }
}
