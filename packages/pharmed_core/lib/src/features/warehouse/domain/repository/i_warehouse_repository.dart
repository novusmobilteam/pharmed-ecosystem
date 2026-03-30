import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_core/src/features/warehouse/domain/model/warehouse.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IWarehouseRepository {
  Future<Result<ApiResponse<List<Warehouse>>>> getWarehouses({int? skip, int? take, String? search});
  Future<Result<void>> createWarehouse(Warehouse entity);
  Future<Result<void>> updateWarehouse(Warehouse entity);
  Future<Result<void>> deleteWarehouse(Warehouse entity);
}
