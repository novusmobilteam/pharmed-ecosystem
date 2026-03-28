import '../../../../core/core.dart';
import '../model/warehouse_dto.dart';
import 'warehouse_data_source.dart';

class WarehouseLocalDataSource extends BaseLocalDataSource<WarehouseDTO, int> implements WarehouseDataSource {
  WarehouseLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => WarehouseDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => WarehouseDTO(
            id: id,
            code: d.code,
            name: d.name,
            userId: d.userId,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<WarehouseDTO>>>> getWarehouses({int? skip, int? take, String? search}) async {
    return fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name', // İsim bazlı arama
    );
  }

  @override
  Future<Result<void>> createWarehouse(WarehouseDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> updateWarehouse(WarehouseDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteWarehouse(int id) => deleteRequest(id);
}
