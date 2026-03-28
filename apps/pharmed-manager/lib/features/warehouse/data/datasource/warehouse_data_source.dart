import '../../../../core/core.dart';
import '../model/warehouse_dto.dart';

abstract class WarehouseDataSource {
  Future<Result<ApiResponse<List<WarehouseDTO>>>> getWarehouses({int? skip, int? take, String? search});
  Future<Result<void>> createWarehouse(WarehouseDTO dto);
  Future<Result<void>> updateWarehouse(WarehouseDTO dto);
  Future<Result<void>> deleteWarehouse(int id);
}
