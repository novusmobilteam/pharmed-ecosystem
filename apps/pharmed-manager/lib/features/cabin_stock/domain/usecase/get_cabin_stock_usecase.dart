import '../../../../core/core.dart';

import '../entity/cabin_stock.dart';
import '../repository/i_cabin_stock_repository.dart';

class GetCabinStockUseCase implements UseCase<List<CabinStock>, int> {
  final ICabinStockRepository _repository;

  GetCabinStockUseCase(this._repository);

  @override
  Future<Result<List<CabinStock>>> call(int cabinId) {
    return _repository.getStocks(cabinId);
  }
}
