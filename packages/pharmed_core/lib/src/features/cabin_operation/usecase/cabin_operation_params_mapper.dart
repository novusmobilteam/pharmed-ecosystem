// [SWREQ-CORE-CABINOP-012] [IEC 62304 §5.5]
//
// Bir kabin işleminin (dolum/sayım/boşaltma) hedeflerini, backend'e
// gönderilecek tek satırlık kayıt listesine çevirir. Kübik çekmecede tek
// satır, birim doz çekmecede göz sayısı kadar satır üretir.
//
// Hangi alanların çevrileceği/gönderileceği CabinOperationParamsOps'tan
// gelir; hücre geometrisi (shelfNo/compartmentNo/detailId)
// CabinOperationCellGeometry'den, boş göz miad fallback'i
// CabinOperationMiadFallback'ten okunur — bu sınıf yalnızca bu parçaları
// doğru sırayla birleştirir.
//
// Boş hedefler (kübikte girdi yoksa) hiç satır üretmez — backend'e
// anlamsız/boş kayıt isteği gitmez.
//
// Kullanım: `CabinOperationParamsMapper.toParams(job, refillParamsOps)` bir
// job'ın TÜM hedeflerini döner; `toParamsForTarget` tek bir hedefi (kübik
// lid bazlı kayıt sırasında kullanılır).
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class CabinOperationParamsMapper {
  static List<CabinOperationMedicineParams> toParams(CabinOperationDrawerJob job, CabinOperationParamsOps ops) {
    final params = <CabinOperationMedicineParams>[];
    for (final target in job.targets) {
      params.addAll(toParamsForTarget(target, ops));
    }
    return params;
  }

  static List<CabinOperationMedicineParams> toParamsForTarget(
    CabinOperationTarget target,
    CabinOperationParamsOps ops,
  ) {
    final assignment = target.assignment;
    final medicine = assignment.medicine;
    final matId = medicine?.id ?? 0;
    final bool isMeasureUnitInput = medicine is Drug && medicine.isMeasureUnit;

    double convertedCount(double raw) =>
        (ops.convertCountQuantity && isMeasureUnitInput) ? medicine.toFillingBackendValue(raw).toDouble() : raw;

    double? convertedQuantity(double raw) {
      if (!ops.sendQuantityField) return null;
      return (ops.convertQuantityField && isMeasureUnitInput) ? medicine.toFillingBackendValue(raw).toDouble() : raw;
    }

    if (target.isKubik) {
      if (!target.hasEntry) return const [];

      final geo = CabinOperationCellGeometry.forKubik(assignment);

      return [
        CabinOperationMedicineParams(
          materialId: matId,
          cabinDrawerDetailId: geo.detailId,
          countQuantity: convertedCount(target.cubicCount),
          quantity: convertedQuantity(target.cubicSecondary),
          miadDate: target.cubicMiad,
          shelfNo: geo.shelfNo,
          compartmentNo: geo.compartmentNo,
        ),
      ];
    }

    final result = <CabinOperationMedicineParams>[];
    for (int i = 0; i < target.numberOfSteps; i++) {
      final step = target.steps[i];
      final geo = CabinOperationCellGeometry.forStep(assignment, i);

      final isEmptyEntry = target.config.hasSecondaryField
          ? (step.secondaryQuantity ?? 0) == 0 && (step.countQuantity ?? 0) == 0
          : (step.countQuantity ?? 0) == 0;

      final miadDate = CabinOperationMiadFallback.resolve(
        isEmptyEntry: isEmptyEntry,
        perCellMiad: step.miadDate,
        singleMiadFallback: target.singleMiad,
      );

      result.add(
        CabinOperationMedicineParams(
          materialId: matId,
          cabinDrawerDetailId: geo.detailId,
          countQuantity: convertedCount(step.countQuantity ?? 0),
          quantity: convertedQuantity(step.secondaryQuantity ?? 0),
          miadDate: miadDate,
          shelfNo: geo.shelfNo,
          compartmentNo: geo.compartmentNo,
        ),
      );
    }
    return result;
  }
}

// Bir hücrenin backend'e gönderilecek SKT (miad) tarihini belirler. Kural:
// hücrede hiç girdi yoksa (boş göz) uzak bir tarihe (2099-12-31) düşülür —
// backend'in miad alanını zorunlu tutması nedeniyle, anlamsız/boş bir göz
// için de geçerli bir tarih gitmesi gerekir. Girdi varsa önce o hücrenin
// kendi (per-cell) miad'ı kullanılır; o da girilmemişse tek-SKT
// (`singleMiad`) fallback'ine bakılır.
//
// Kullanım: `CabinOperationParamsMapper`, her göz için bu fonksiyonu çağırıp
// dönen tarihi doğrudan kayıt DTO'suna yerleştirir.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

abstract final class CabinOperationMiadFallback {
  /// Boş göz için gönderilen sabit tarih.
  static final DateTime empty = DateTime(2099, 12, 31);

  static DateTime? resolve({
    required bool isEmptyEntry,
    required DateTime? perCellMiad,
    required DateTime? singleMiadFallback,
  }) {
    if (isEmptyEntry) return empty;
    return perCellMiad ?? singleMiadFallback;
  }
}
