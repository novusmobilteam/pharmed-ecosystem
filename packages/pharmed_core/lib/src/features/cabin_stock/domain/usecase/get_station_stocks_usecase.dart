// [SWREQ-CORE-STOCK-UC-006]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetStationStocksUseCase {
  final ICabinStockRepository _repository;

  GetStationStocksUseCase(this._repository);

  Future<Result<List<StationStock>>> call(int cabinId) {
    return _repository.getStationStocks(cabinId);
  }
}
