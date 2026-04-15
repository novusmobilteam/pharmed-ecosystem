import 'package:pharmed_core/pharmed_core.dart';

class GetCabinFaultsUseCase {
  final IFaultRepository _repository;

  GetCabinFaultsUseCase(this._repository);

  Future<Result<List<Fault>>> call() {
    return _repository.getCabinFaultRecords();
  }
}
