import '../../../../../core/core.dart';

import '../../data/repository/prescription_repository.dart';
import '../entity/prescription.dart';
import '../entity/prescription_other_request.dart';

class CreatePrescriptionWithOtherRequestUseCase {
  final PrescriptionRepository _prescriptionRepository;

  CreatePrescriptionWithOtherRequestUseCase({required PrescriptionRepository prescriptionRepository})
      : _prescriptionRepository = prescriptionRepository;

  /// Akış:
  /// 1) createPrescription -> id al
  /// 2) otherRequest'e prescriptionId enjekte et -> createOtherRequest
  Future<Result<PrescriptionOtherRequest>> call({
    required Prescription prescription,
    required PrescriptionOtherRequest otherRequest,
  }) async {
    final rCreate = await _prescriptionRepository.createPrescription(prescription);
    return rCreate.when(
      error: Result.error,
      ok: (created) async {
        final prescId = created.id;
        if (prescId == null) {
          return Result.error(CustomException(message: 'createPrescription: id missing'));
        }

        final reqWithId = otherRequest.copyWith(prescriptionId: prescId);
        final rOther = await _prescriptionRepository.createOtherRequest(reqWithId);
        return rOther.when(
          ok: Result.ok,
          error: Result.error,
        );
      },
    );
  }
}
