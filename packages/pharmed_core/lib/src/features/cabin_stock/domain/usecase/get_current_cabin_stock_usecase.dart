import 'package:pharmed_core/pharmed_core.dart';

class GetCurrentCabinStockUseCase {
  final ICabinStockRepository _repository;

  GetCurrentCabinStockUseCase(this._repository);

  Future<Result<List<CabinStock>>> call() => _repository.getCurrentCabinStock();
}
