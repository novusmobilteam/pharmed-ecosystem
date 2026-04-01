// [SWREQ-CORE-STOCK-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetCurrentCabinStockUseCase {
  final ICabinStockRepository _repository;

  GetCurrentCabinStockUseCase(this._repository);

  Future<RepoResult<List<CabinStock>>> call() => _repository.getCurrentCabinStock();
}
