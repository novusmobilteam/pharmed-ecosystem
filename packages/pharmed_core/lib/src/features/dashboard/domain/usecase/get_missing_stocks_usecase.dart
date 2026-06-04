import 'package:pharmed_core/pharmed_core.dart';

class GetMissingStocksUseCase {
  final IDashboardRepository _repository;

  GetMissingStocksUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call({bool forceRefresh = false, required String mac}) {
    return _repository.getMissingStocks(forceRefresh: forceRefresh, mac: mac);
  }
}
