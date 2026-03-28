import '../../../../core/core.dart';
import '../../domain/entity/warehouse.dart';
import '../../domain/repository/i_warehouse_repository.dart';
import '../datasource/warehouse_data_source.dart';

class WarehouseRepository implements IWarehouseRepository {
  final WarehouseDataSource _ds;

  WarehouseRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Warehouse>>>> getWarehouses({int? skip, int? take, String? search}) async {
    final res = await _ds.getWarehouses(search: search, skip: skip, take: take);
    return res.when(
      ok: (response) {
        List<Warehouse> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }

        return Result.ok(ApiResponse<List<Warehouse>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createWarehouse(Warehouse entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createWarehouse(dto);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateWarehouse(Warehouse entity) async {
    final dto = entity.toDTO();
    final res = await _ds.updateWarehouse(dto);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteWarehouse(Warehouse item) async {
    final id = item.id;
    if (id == null) {
      return Result.error(CustomException(message: 'deleteWarehouse: id is null'));
    }
    final res = await _ds.deleteWarehouse(id);
    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }
}
