// [SWREQ-CORE-MATERIALTYPE-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteMaterialTypeUseCase {
  final IMaterialTypeRepository repository;

  DeleteMaterialTypeUseCase(this.repository);

  Future<Result<void>> call(MaterialType type) {
    return repository.deleteMaterialType(type);
  }
}
