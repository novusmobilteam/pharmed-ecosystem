import 'package:pharmed_core/pharmed_core.dart';

class GetUpcomingTreatmentsUseCase {
  final IDashboardRepository _repository;

  GetUpcomingTreatmentsUseCase(this._repository);

  Future<Result<List<UpcomingTreatment>>> call({bool forceRefresh = false, required String mac}) {
    return _repository.getUpcomingTreatments(forceRefresh: forceRefresh, mac: mac);
  }
}
