import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetCompletedPharmacyRefundsUseCase {
  final IRefundRepository _repository;

  GetCompletedPharmacyRefundsUseCase(this._repository);

  Future<Result<ApiResponse<List<Refund>>?>> call(PagedQueryParams params, {required int stationId}) =>
      _repository.getCompletedPharmacyRefunds(
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
