import '../../../../core/core.dart';

import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../repository/i_dashboard_repository.dart';

class GetCriticalStocksUseCase implements UseCase<List<CabinStock>, bool> {
  final IDashboardRepository _repository;

  GetCriticalStocksUseCase(this._repository);

  @override
  Future<Result<List<CabinStock>>> call(bool isClient) {
    return _repository.getCriticalStocks(isClient: isClient);
  }
}
