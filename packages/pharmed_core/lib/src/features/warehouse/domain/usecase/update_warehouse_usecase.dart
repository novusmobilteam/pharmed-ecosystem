// [SWREQ-CORE-WAREHOUSE-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateWarehouseUseCase {
  const UpdateWarehouseUseCase(this._repository);

  final IWarehouseRepository _repository;

  Future<Result<void>> call(Warehouse Warehouse) => _repository.updateWarehouse(Warehouse);
}
