import '../../../../core/core.dart';
import '../entity/warehouse.dart';

abstract class IWarehouseRepository {
  Future<Result<ApiResponse<List<Warehouse>>>> getWarehouses({int? skip, int? take, String? search});
  Future<Result<void>> createWarehouse(Warehouse entity);
  Future<Result<void>> updateWarehouse(Warehouse entity);
  Future<Result<void>> deleteWarehouse(Warehouse entity);
}
