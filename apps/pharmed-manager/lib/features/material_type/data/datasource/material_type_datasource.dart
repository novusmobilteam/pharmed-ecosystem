import '../../../../core/core.dart';
import '../model/material_type_dto.dart';

abstract class MaterialTypeDataSource {
  Future<Result<ApiResponse<List<MaterialTypeDTO>>>> getMaterialTypes({int? skip, int? take, String? search});
  Future<Result<void>> createMaterialType(MaterialTypeDTO dto);
  Future<Result<void>> updateMaterialType(MaterialTypeDTO dto);
  Future<Result<void>> deleteMaterialTypeById(int id);
}
