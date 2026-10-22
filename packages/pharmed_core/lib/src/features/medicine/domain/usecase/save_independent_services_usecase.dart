// [SWREQ-CORE-MEDICINE-UC-008]
// Sınıf: Class B
//
// Serbest ilacın alınabileceği servisleri kaydeder.
// PUT /Material/independentServices — id'li eleman güncellenir, id'siz eklenir,
// listede olmayan mevcut kayıtlar silinir; boş liste tümünü kaldırır.

import 'package:pharmed_core/pharmed_core.dart';

class SaveIndependentServicesUseCase {
  final IMedicineRepository _repository;

  SaveIndependentServicesUseCase(this._repository);

  Future<Result<void>> call({required int materialId, required List<IndependentMaterialService> services}) {
    return _repository.saveIndependentServices(materialId, services);
  }
}
