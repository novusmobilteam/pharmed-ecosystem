import 'package:pharmed_core/pharmed_core.dart';

class GetUpcomingTreatmensUseCase {
  final IDashboardRepository _repository;

  GetUpcomingTreatmensUseCase(this._repository);

  Future<RepoResult<List<PrescriptionItem>>> call({bool forceRefresh = false}) {
    return _repository.getUpcomingTreatments(forceRefresh: forceRefresh);
  }
}
