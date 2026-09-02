import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetDrawerRefundsUseCase {
  final IRefundRepository _repository;

  GetDrawerRefundsUseCase(this._repository);

  Future<Result<ApiResponse<List<Refund>>?>> call(PagedQueryParams params, {required int stationId}) {
    return _repository.getDrawerRefunds(
      stationId: stationId,
      params: params.copyWith(
        searchFields: [
          'user',
          'prescriptionDetail.prescription.patientHospitalization.patient.name',
          'prescriptionDetail.prescription.patientHospitalization.patient.surname',
          'material.name',
          'description',
        ],
      ),
    );
  }
}
