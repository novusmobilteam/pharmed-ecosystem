// [SWREQ-CORE-STOCK-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetCabinStockUseCase {
  final ICabinStockRepository _repository;

  GetCabinStockUseCase(this._repository);

  Future<Result<List<CabinStock>>> call(int cabinId) {
    return _repository.getStocks(cabinId);
  }
}
