import 'package:pharmed_core/pharmed_core.dart';

class GetUnappliedPrescriptionsUseCase {
  final IDashboardRepository _repository;

  GetUnappliedPrescriptionsUseCase(this._repository);

  Future<RepoResult<List<Prescription>>> call() {
    return _repository.getUnappliedPrescriptions();
  }
}
