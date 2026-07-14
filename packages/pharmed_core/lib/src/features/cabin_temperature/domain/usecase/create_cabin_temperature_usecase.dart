import 'package:pharmed_core/pharmed_core.dart';

/// Yeni bir kabin sıcaklık kontrol istasyonu kaydı oluşturur.
class CreateCabinTemperatureUseCase {
  const CreateCabinTemperatureUseCase(this._repository);

  final ICabinTemperatureRepository _repository;

  Future<Result<void>> call(CabinTemperature entity) {
    return _repository.createCabinTemperature(entity);
  }
}
