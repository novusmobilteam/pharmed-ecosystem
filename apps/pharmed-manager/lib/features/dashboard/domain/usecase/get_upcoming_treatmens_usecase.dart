import '../../../../core/core.dart';

import '../../../prescription/domain/entity/prescription_item.dart';
import '../repository/i_dashboard_repository.dart';

class GetUpcomingTreatmensUseCase implements NoParamsUseCase<List<PrescriptionItem>> {
  final IDashboardRepository _repository;

  GetUpcomingTreatmensUseCase(this._repository);

  @override
  Future<Result<List<PrescriptionItem>>> call() {
    return _repository.getUpcomingTreatments();
  }
}
