import '../../../../core/core.dart';

import '../entity/cabin_fault.dart';

import '../repository/i_cabin_fault_repository.dart';

class GetCabinFaultsUseCase implements NoParamsUseCase<List<CabinFault>> {
  final ICabinFaultRepository _repository;

  GetCabinFaultsUseCase(this._repository);

  @override
  Future<Result<List<CabinFault>>> call() {
    return _repository.getCabinFaultRecords();
  }
}
