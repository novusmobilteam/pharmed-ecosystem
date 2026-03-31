import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IMaterialTypeRepository {
  Future<Result<ApiResponse<List<MaterialType>>>> getMaterialTypes({int? skip, int? take, String? search});
  Future<Result<void>> createMaterialType(MaterialType type);
  Future<Result<void>> updateMaterialType(MaterialType type);
  Future<Result<void>> deleteMaterialType(MaterialType type);
}
