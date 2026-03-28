import '../../../../core/core.dart';

import '../entity/cabin.dart';
import '../repository/i_cabin_repository.dart';

class GetCabinsUseCase implements NoParamsUseCase<List<Cabin>> {
  final ICabinRepository _repository;

  GetCabinsUseCase(this._repository);

  @override
  Future<Result<List<Cabin>>> call() {
    return _repository.getCabins();
  }
}

class GetCabinsByStationUseCase implements UseCase<List<Cabin>, int> {
  final ICabinRepository _repository;

  GetCabinsByStationUseCase(this._repository);

  @override
  Future<Result<List<Cabin>>> call(int params) {
    return _repository.getCabinsByStation(params);
  }
}
