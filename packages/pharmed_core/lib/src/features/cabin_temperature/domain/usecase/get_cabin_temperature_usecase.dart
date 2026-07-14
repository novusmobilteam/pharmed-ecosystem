import 'package:pharmed_core/pharmed_core.dart';

/// İstasyon bazlı kabin sıcaklık kayıtlarını listeler.
class GetCabinTemperatureUseCase {
  const GetCabinTemperatureUseCase(this._repository);

  final ICabinTemperatureRepository _repository;

  Future<Result<List<CabinTemperature>>> call(int stationId) {
    return _repository.getCabinTemperature(stationId);
  }
}
