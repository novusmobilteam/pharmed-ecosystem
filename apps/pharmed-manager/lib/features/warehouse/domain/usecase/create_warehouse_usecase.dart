import '../../../../core/core.dart';

import '../entity/warehouse.dart';
import '../repository/i_warehouse_repository.dart';

class CreateWarehouseUseCase extends UseCase<void, Warehouse> {
  final IWarehouseRepository _repository;

  CreateWarehouseUseCase(this._repository);

  @override
  Future<Result<void>> call(Warehouse params) {
    return _repository.createWarehouse(params);
  }
}
