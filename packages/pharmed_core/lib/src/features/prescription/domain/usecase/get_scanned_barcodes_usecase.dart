import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetScannedBarcodesUseCase {
  final IPrescriptionRepository _repository;

  GetScannedBarcodesUseCase(this._repository);

  Future<Result<ApiResponse<List<PrescriptionItem>>?>> call({PagedQueryParams? params, required int stationId}) {
    return _repository.getScannedBarcodes(params: params, stationId: stationId);
  }
}
