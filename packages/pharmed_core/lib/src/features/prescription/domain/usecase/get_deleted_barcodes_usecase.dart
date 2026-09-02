import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetDeletedBarcodesUseCase {
  final IPrescriptionRepository _repository;

  GetDeletedBarcodesUseCase(this._repository);

  Future<Result<ApiResponse<List<PrescriptionItem>>?>> call({PagedQueryParams? params, required int stationId}) {
    return _repository.getDeletedBarcodes(params: params, stationId: stationId);
  }
}
