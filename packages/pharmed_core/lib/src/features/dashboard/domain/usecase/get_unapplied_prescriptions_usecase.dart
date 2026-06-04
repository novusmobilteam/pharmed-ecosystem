import 'package:pharmed_core/pharmed_core.dart';

class GetDashboardUnappliedPrescriptionsUseCase {
  final IDashboardRepository _repository;

  GetDashboardUnappliedPrescriptionsUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call() {
    return _repository.getUnappliedPrescriptions();
  }
}
