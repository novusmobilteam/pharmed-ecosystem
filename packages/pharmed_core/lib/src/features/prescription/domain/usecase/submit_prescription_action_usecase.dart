import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum PrescriptionActionType {
  approve,
  cancel,
  reject,
  rejectAfterApprove;

  String get title => switch (this) {
    PrescriptionActionType.approve => contextlessL10n().prescriptionCore_actionApproveTitle,
    PrescriptionActionType.cancel => contextlessL10n().prescriptionCore_actionCancelTitle,
    PrescriptionActionType.reject => contextlessL10n().prescriptionCore_actionRejectTitle,
    PrescriptionActionType.rejectAfterApprove => contextlessL10n().prescriptionCore_actionRejectAfterApproveTitle,
  };
}

class SubmitActionParams {
  final PrescriptionActionType actionType;
  final int prescriptionId;
  // Seçili reçete detay objelerinin id'leri
  final List<int> itemIds;

  SubmitActionParams({required this.actionType, required this.prescriptionId, required this.itemIds});
}

/// Reçete detay objelerinin Onayla, Reddet ve İptal Et işlemleri için kullanılan usecase.
class SubmitPrescriptionActionUseCase {
  final IPrescriptionRepository _repository;

  SubmitPrescriptionActionUseCase(this._repository);

  Future<Result<void>> call(SubmitActionParams params) async {
    Result result;

    switch (params.actionType) {
      case PrescriptionActionType.approve:
        result = await _repository.approvePrescriptionRequests(params.prescriptionId, params.itemIds);
        break;
      case PrescriptionActionType.cancel:
        result = await _repository.cancelPrescriptionRequests(params.prescriptionId, params.itemIds);
        break;
      case PrescriptionActionType.reject:
        result = await _repository.rejectPrescriptionRequests(params.prescriptionId, params.itemIds);
        break;
      case PrescriptionActionType.rejectAfterApprove:
        result = await _repository.rejectApprovedRequests(params.prescriptionId, params.itemIds);
        break;
    }

    return result;
  }
}
