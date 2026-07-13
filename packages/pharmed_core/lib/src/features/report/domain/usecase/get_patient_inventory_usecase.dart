// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetPatientInventoryUseCase {
  final IReportRepository _repository;

  GetPatientInventoryUseCase(this._repository);

  Future<Result<ApiResponse<List<PrescriptionItem>>?>> call(PagedQueryParams params, {required int patientId}) =>
      _repository.getPatientInventory(
        patientId: patientId,
        params: params.copyWith(
          searchFields: [
            'material.barcode',
            'material.code',
            'material.name',
            'doctor',
            'approvalUser.name',
            'approvalUser.surname',
            'applicationUser.name',
            'applicationUser.surname',
          ],
        ),
      );
}
