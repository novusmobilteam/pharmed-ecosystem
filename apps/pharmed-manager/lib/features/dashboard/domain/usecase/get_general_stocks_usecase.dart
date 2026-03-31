import '../../../../core/core.dart';

import '../repository/i_dashboard_repository.dart';

class GetGeneralStocksUseCase implements NoParamsUseCase<List<CabinStock>> {
  final IDashboardRepository _repository;

  GetGeneralStocksUseCase(this._repository);

  @override
  Future<Result<List<CabinStock>>> call() {
    return _repository.getGeneralStocks();
  }
}
