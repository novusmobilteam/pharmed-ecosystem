// [SWREQ-CORE-WAREHOUSE-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateWarehouseUseCase {
  const CreateWarehouseUseCase(this._repository);

  final IWarehouseRepository _repository;

  Future<Result<void>> call(Warehouse Warehouse) => _repository.createWarehouse(Warehouse);
}
