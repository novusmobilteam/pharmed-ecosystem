// [SWREQ-MGR-RX-001] [IEC 62304 §5.5]
// Yeni reçete oluşturma use case'i.
//
// Akış:
//   1. createPrescription → prescriptionId al
//   2. Adet bazlı item'ları expand et (dosePiece > 1 → N ayrı item, her biri dosePiece: 1)
//   3. items'e prescriptionId enjekte et → createPrescriptionDetail
//
// Expand kuralı:
//   - medicine.isMeasureUnit = false (Adet bazlı) VE dosePiece > 1
//     → dosePiece kadar kopya üret, her birinin dosePiece'i = operationStep (genellikle 1.0)
//   - medicine.isMeasureUnit = true (ml, mg vb.) → dokunma, olduğu gibi gönder
//   - times listesi her kopyaya aynen aktarılır
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreatePrescriptionUseCase {
  final IPrescriptionRepository _prescriptionRepository;

  CreatePrescriptionUseCase({required IPrescriptionRepository prescriptionRepository})
    : _prescriptionRepository = prescriptionRepository;

  Future<Result<List<PrescriptionItem>>> call({
    required Prescription prescription,
    required List<PrescriptionItem> items,
  }) async {
    // 1. Reçete oluştur
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

        // 2. Adet bazlı item'ları expand et
        final expanded = _expandItems(items);

        // 3. prescriptionId enjekte et
        final entities = expanded.map((e) => e.copyWith(prescriptionId: prescId)).toList();

        final rDetail = await _prescriptionRepository.createPrescriptionDetail(entities);

        return rDetail.when(ok: (_) => Result.ok(items), error: Result.error);
      },
    );
  }

  /// Adet bazlı item'ları expand eder.
  ///
  /// `isMeasureUnit = false` ve `dosePiece > 1` olan her item,
  /// `dosePiece` kadar ayrı item'a bölünür. Her kopyanın `dosePiece`'i
  /// `operationStep` değerine (genellikle 1.0) set edilir.
  /// `times` listesi tüm kopyalara aynen aktarılır.
  List<PrescriptionItem> _expandItems(List<PrescriptionItem> items) {
    final result = <PrescriptionItem>[];

    for (final item in items) {
      final medicine = item.medicine;
      final dosePiece = item.dosePiece ?? 1;
      final isAdetBased = medicine == null || !_isMeasureUnit(medicine);
      final shouldExpand = isAdetBased && dosePiece > 1;

      if (!shouldExpand) {
        result.add(item);
        continue;
      }

      // dosePiece kadar kopya üret
      final count = dosePiece.round();
      final unitDose = medicine?.operationStep ?? 1.0;

      for (var i = 0; i < count; i++) {
        result.add(item.copyWith(dosePiece: unitDose));
      }
    }

    return result;
  }

  bool _isMeasureUnit(Medicine medicine) {
    final self = medicine;
    if (self is Drug) return self.isMeasureUnit;
    return false; // MedicalConsumable her zaman Adet bazlı
  }
}
