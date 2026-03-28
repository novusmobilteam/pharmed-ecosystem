import '../../../../core/core.dart';

import '../entity/station_stock.dart';
import '../repository/i_cabin_stock_repository.dart';

class GetStationStocksUseCase implements UseCase<List<StationStock>, int> {
  final ICabinStockRepository _repository;

  GetStationStocksUseCase(this._repository);

  @override
  Future<Result<List<StationStock>>> call(int cabinId) {
    return _repository.getStationStocks(cabinId);
  }
}
