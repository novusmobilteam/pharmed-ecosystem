// [SWREQ-CORE-CABIN-UC-005]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetCabinsUseCase {
  final ICabinRepository _repository;

  GetCabinsUseCase(this._repository);

  Future<Result<List<Cabin>>> call() {
    return _repository.getCabins();
  }
}
