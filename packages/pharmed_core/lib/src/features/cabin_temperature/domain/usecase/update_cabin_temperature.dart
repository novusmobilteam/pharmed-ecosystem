import 'package:pharmed_core/pharmed_core.dart';

/// Mevcut bir sıcaklık/nem limit detayını günceller.
class UpdateCabinTemperatureUseCase {
  const UpdateCabinTemperatureUseCase(this._repository);

  final ICabinTemperatureRepository _repository;

  Future<Result<void>> call(CabinTemperature entity) {
    return _repository.updateCabinTemperature(entity);
  }
}
