import '../../../../core/core.dart';

import '../../../prescription/domain/entity/prescription.dart';
import '../repository/i_dashboard_repository.dart';

class GetUnappliedPrescriptionsUseCase implements NoParamsUseCase<List<Prescription>> {
  final IDashboardRepository _repository;

  GetUnappliedPrescriptionsUseCase(this._repository);

  @override
  Future<Result<List<Prescription>>> call() {
    return _repository.getUnappliedPrescriptions();
  }
}
