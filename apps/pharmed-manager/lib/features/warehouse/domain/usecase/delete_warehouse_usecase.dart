import '../../../../core/core.dart';

import '../entity/warehouse.dart';
import '../repository/i_warehouse_repository.dart';

class DeleteWarehouseUseCase extends UseCase<void, Warehouse> {
  final IWarehouseRepository _repository;

  DeleteWarehouseUseCase(this._repository);

  @override
  Future<Result<void>> call(Warehouse params) {
    return _repository.deleteWarehouse(params);
  }
}
