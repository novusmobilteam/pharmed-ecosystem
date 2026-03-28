import '../../../../core/core.dart';
import '../model/material_type_dto.dart';
import 'material_type_datasource.dart';

class MaterialTypeLocalDataSource extends BaseLocalDataSource<MaterialTypeDTO, int> implements MaterialTypeDataSource {
  MaterialTypeLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => MaterialTypeDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => MaterialTypeDTO(
            id: id,
            name: d.name,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<MaterialTypeDTO>>>> getMaterialTypes({int? skip, int? take, String? search}) async {
    return fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name', // İsim bazlı arama
    );
  }

  @override
  Future<Result<void>> createMaterialType(MaterialTypeDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> updateMaterialType(MaterialTypeDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteMaterialTypeById(int id) => deleteRequest(id);
}
