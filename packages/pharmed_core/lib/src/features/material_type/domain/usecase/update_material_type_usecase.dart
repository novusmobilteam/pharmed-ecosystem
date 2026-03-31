// [SWREQ-CORE-MATERIALTYPE-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateMaterialTypeUseCase {
  final IMaterialTypeRepository repository;

  UpdateMaterialTypeUseCase(this.repository);

  Future<Result<void>> call(MaterialType type) {
    return repository.updateMaterialType(type);
  }
}
