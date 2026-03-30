import 'package:pharmed_core/pharmed_core.dart';

// [SWREQ-CORE-CABIN-UC-004]
// Sınıf: Class B

class GetCabinsByStationUseCase {
  final ICabinRepository _repository;

  GetCabinsByStationUseCase(this._repository);

  Future<Result<List<Cabin>>> call(int params) {
    return _repository.getCabinsByStation(params);
  }
}
