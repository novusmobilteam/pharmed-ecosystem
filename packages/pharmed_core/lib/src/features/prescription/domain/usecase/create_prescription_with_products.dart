import 'package:pharmed_core/pharmed_core.dart';

class CreatePrescriptionWithProductsUseCase {
  final IPrescriptionRepository _prescriptionRepository;

  CreatePrescriptionWithProductsUseCase({required IPrescriptionRepository prescriptionRepository})
    : _prescriptionRepository = prescriptionRepository;

  /// Akış:
  /// 1) createPrescription -> id al
  /// 2) items’e prescriptionId enjekte et -> createPrescriptionDetail
  Future<Result<List<PrescriptionItem>>> call({
    required Prescription prescription,
    required List<PrescriptionItem> items,
  }) async {
    // 1) Reçete oluştur
    final rCreate = await _prescriptionRepository.createPrescription(
      prescription.copyWith(prescriptionDate: DateTime.now()),
    );
    return rCreate.when(
      error: Result.error,
      ok: (created) async {
        final prescId = created?.id;

        if (prescId == null) {
          return Result.error(
            CustomException(message: 'Reçete oluşturulurken bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.'),
          );
        }

        final entities = items.map((e) => e.copyWith(prescriptionId: prescId)).toList();
        final rDetail = await _prescriptionRepository.createPrescriptionDetail(entities);

        return rDetail.when(ok: (_) => Result.ok(items), error: Result.error);
      },
    );
  }
}
