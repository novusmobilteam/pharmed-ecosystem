import 'package:pharmed_core/pharmed_core.dart';

class GetDailyJobListUseCase {
  final IPrescriptionRepository _repository;

  GetDailyJobListUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call(int hospitalizationId) {
    return _repository.getDailyJobList(hospitalizationId);
  }
}
