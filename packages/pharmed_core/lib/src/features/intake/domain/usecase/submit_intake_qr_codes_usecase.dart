import 'package:pharmed_core/pharmed_core.dart';

class SubmitIntakeQrCodesParams {
  const SubmitIntakeQrCodesParams({required this.details});

  final List<IntakeQrCodeDetail> details;

  Map<String, dynamic> toJson() => {'detail': details.map((d) => d.toJson()).toList()};
}

class IntakeQrCodeDetail {
  const IntakeQrCodeDetail({required this.prescriptionDetailId, required this.qrCode});

  final int prescriptionDetailId;
  final List<String> qrCode;

  Map<String, dynamic> toJson() => {'prescriptionDetailId': prescriptionDetailId, 'qrCode': qrCode};
}

class SubmitIntakeQrCodesUseCase {
  const SubmitIntakeQrCodesUseCase(this._repository);

  final IIntakeRepository _repository;

  Future<Result<void>> call(SubmitIntakeQrCodesParams params) => _repository.submitIntakeQrCodes(params);
}
