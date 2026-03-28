import '../../../../core/core.dart';
import '../repository/i_prescription_repository.dart';

enum PrescriptionActionType {
  approve('Seçili Talepleri Onayla', 'Seçili talepleri onaylama işlemini onaylıyor musunuz?'),
  cancel('Seçili Talepleri İptal Et', "Seçili talepler iptal edilecektir.\nOnaylıyor musunuz?"),
  reject('Seçili Talepleri Reddet', 'Seçili talepler reddilecektir.\nOnaylıyor musunuz?');

  final String title;
  final String message;

  const PrescriptionActionType(this.title, this.message);
}

class SubmitActionParams {
  final PrescriptionActionType actionType;
  final int prescriptionId;
  // Seçili reçete detay objelerinin id'leri
  final List<int> itemIds;

  SubmitActionParams({required this.actionType, required this.prescriptionId, required this.itemIds});
}

/// Reçete detay objelerinin Onayla, Reddet ve İptal Et işlemleri için kullanılan usecase.
class SubmitPrescriptionActionUseCase implements UseCase<void, SubmitActionParams> {
  final IPrescriptionRepository _repository;

  SubmitPrescriptionActionUseCase(this._repository);

  @override
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
    }

    return result;
  }
}
