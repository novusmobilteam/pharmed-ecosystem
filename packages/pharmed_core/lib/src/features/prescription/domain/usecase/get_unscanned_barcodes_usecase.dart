import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetUnscannedBarcodesUseCase {
  final IPrescriptionRepository _repository;

  GetUnscannedBarcodesUseCase(this._repository);

  Future<Result<ApiResponse<List<PrescriptionItem>>?>> call() {
    return _repository.getUnscannedBarcodes();
  }
}
