import '../../../../core/core.dart';
import '../model/warehouse_dto.dart';
import 'warehouse_data_source.dart';

class WarehouseRemoteDataSource extends BaseRemoteDataSource implements WarehouseDataSource {
  final String _basePath = '/Warehouse';

  WarehouseRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<WarehouseDTO>>>> getWarehouses({int? skip, int? take, String? search}) async {
    final res = await fetchRequest(
      path: _basePath,
      // skip: skip,
      // take: take,
      // searchText: search,
      // searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(WarehouseDTO.fromJson),
      successLog: 'Warehouses fetched',
      emptyLog: 'No warehouses',
    );

    return res.when(
      ok: (data) => Result.ok(
        data ?? const ApiResponse(data: [], totalCount: 0),
      ),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createWarehouse(WarehouseDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Warehouse created',
    );
  }

  @override
  Future<Result<void>> updateWarehouse(WarehouseDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Warehouse updated',
    );
  }

  @override
  Future<Result<void>> deleteWarehouse(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Warehouse deleted',
    );
  }
}
