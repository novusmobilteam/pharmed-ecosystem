import '../../../../core/core.dart';

import '../entity/material_type.dart';
import '../repository/i_material_type_repository.dart';

class CreateMaterialTypeUseCase extends UseCase<void, MaterialType> {
  final IMaterialTypeRepository repository;

  CreateMaterialTypeUseCase(this.repository);

  @override
  Future<Result<void>> call(MaterialType type) {
    return repository.createMaterialType(type);
  }
}
