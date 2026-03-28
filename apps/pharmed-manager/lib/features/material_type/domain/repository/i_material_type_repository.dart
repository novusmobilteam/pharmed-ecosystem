import '../../../../core/core.dart';
import '../entity/material_type.dart';

abstract class IMaterialTypeRepository {
  Future<Result<ApiResponse<List<MaterialType>>>> getMaterialTypes({int? skip, int? take, String? search});
  Future<Result<void>> createMaterialType(MaterialType type);
  Future<Result<void>> updateMaterialType(MaterialType type);
  Future<Result<void>> deleteMaterialType(MaterialType type);
}
