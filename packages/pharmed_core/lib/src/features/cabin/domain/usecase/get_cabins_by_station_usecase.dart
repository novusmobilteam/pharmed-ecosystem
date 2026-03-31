import 'package:pharmed_core/pharmed_core.dart';

// [SWREQ-CORE-CABIN-003] [IEC 62304 §5.5]
// Belirli bir istasyona bağlı kabinleri listeler.
// Sınıf: Class B

class GetCabinsByStationUseCase {
  GetCabinsByStationUseCase(this._repository);
  final ICabinRepository _repository;

  Future<RepoResult<List<Cabin>>> call(int stationId) => _repository.getCabinsByStation(stationId);
}
