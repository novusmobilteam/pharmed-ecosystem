// [SWREQ-CORE-MATERIALTYPE-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateMaterialTypeUseCase {
  final IMaterialTypeRepository repository;

  CreateMaterialTypeUseCase(this.repository);

  Future<Result<void>> call(MaterialType type) {
    return repository.createMaterialType(type);
  }
}
