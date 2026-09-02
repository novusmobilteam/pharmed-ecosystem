import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetUnscannedBarcodesUseCase {
  final IPrescriptionRepository _repository;

  GetUnscannedBarcodesUseCase(this._repository);

  Future<Result<ApiResponse<List<PrescriptionItem>>?>> call({PagedQueryParams? params}) {
    return _repository.getUnscannedBarcodes(params: params);
  }
}

class GetUnscannedBarcodesWithStationIdUseCase {
  final IPrescriptionRepository _repository;

  GetUnscannedBarcodesWithStationIdUseCase(this._repository);

  Future<Result<ApiResponse<List<PrescriptionItem>>?>> call({PagedQueryParams? params, required int stationId}) {
    return _repository.getUnscannedBarcodesWithStationId(params: params, stationId: stationId);
  }
}
