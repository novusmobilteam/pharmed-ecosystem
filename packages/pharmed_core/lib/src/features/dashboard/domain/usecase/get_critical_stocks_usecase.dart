import 'package:pharmed_core/pharmed_core.dart';

class GetCriticalStocksUseCase {
  final IDashboardRepository _repository;

  GetCriticalStocksUseCase(this._repository);

  Future<RepoResult<List<CabinStock>>> call(bool isClient, {bool forceRefresh = false}) {
    return _repository.getCriticalStocks(isClient: isClient, forceRefresh: forceRefresh);
  }
}
