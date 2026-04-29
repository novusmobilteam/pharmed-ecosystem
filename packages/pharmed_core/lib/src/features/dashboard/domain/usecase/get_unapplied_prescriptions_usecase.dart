import 'package:pharmed_core/pharmed_core.dart';

class GetDashboardUnappliedPrescriptionsUseCase {
  final IDashboardRepository _repository;

  GetDashboardUnappliedPrescriptionsUseCase(this._repository);

  Future<RepoResult<List<Prescription>>> call() {
    return _repository.getUnappliedPrescriptions();
  }
}
