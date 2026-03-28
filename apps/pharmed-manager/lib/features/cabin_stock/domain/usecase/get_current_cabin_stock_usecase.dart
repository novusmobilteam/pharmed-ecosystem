import '../../../../core/core.dart';

import '../entity/cabin_stock.dart';
import '../repository/i_cabin_stock_repository.dart';

class GetCurrentCabinStockUseCase implements NoParamsUseCase<List<CabinStock>> {
  final ICabinStockRepository _repository;
  GetCurrentCabinStockUseCase(this._repository);

  @override
  Future<Result<List<CabinStock>>> call() => _repository.getCurrentCabinStock();
}
