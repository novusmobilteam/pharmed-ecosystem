// [SWREQ-CORE-STATION-UC-006]
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';

class GetCurrentStationUseCase {
  final IStationRepository _repository;

  GetCurrentStationUseCase(this._repository);

  Future<Result<Station?>> call() {
    return _repository.getCurrentStation();
  }
}
