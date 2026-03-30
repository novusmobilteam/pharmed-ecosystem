// [SWREQ-CORE-WAREHOUSE-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteWarehouseUseCase {
  const DeleteWarehouseUseCase(this._repository);

  final IWarehouseRepository _repository;

  Future<Result<void>> call(Warehouse warehouse) => _repository.deleteWarehouse(warehouse);
}
