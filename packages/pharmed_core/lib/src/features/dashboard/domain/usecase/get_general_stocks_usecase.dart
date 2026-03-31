import 'package:pharmed_core/pharmed_core.dart';

class GetGeneralStocksUseCase {
  final IDashboardRepository _repository;

  GetGeneralStocksUseCase(this._repository);

  Future<RepoResult<List<CabinStock>>> call() {
    return _repository.getGeneralStocks();
  }
}
