import 'package:pharmed_core/pharmed_core.dart';

class GetDrugActivitiesUseCase {
  final IDashboardRepository _repository;

  GetDrugActivitiesUseCase(this._repository);

  Future<Result<List<PrescriptionItemMovement>?>> call({required String mac}) {
    return _repository.getDrugActivities(mac: mac);
  }
}
