import '../../../../core/core.dart';

import '../entity/material_type.dart';
import '../repository/i_material_type_repository.dart';

class UpdateMaterialTypeUseCase extends UseCase<void, MaterialType> {
  final IMaterialTypeRepository repository;

  UpdateMaterialTypeUseCase(this.repository);

  @override
  Future<Result<void>> call(MaterialType type) {
    return repository.updateMaterialType(type);
  }
}
