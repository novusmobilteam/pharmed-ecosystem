import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetUnappliedPrescriptionsUseCase {
  final IPrescriptionRepository _repository;

  GetUnappliedPrescriptionsUseCase(this._repository);

  Future<Result<ApiResponse<List<Prescription>>?>> call() {
    return _repository.getUnappliedPrescriptions();
  }
}
