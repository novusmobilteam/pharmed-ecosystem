// [SWREQ-CLI-MREFILL-013] [IEC 62304 §5.5]
// RefillFillTarget'ları backend'e gönderilecek RefillMedicineParams listesine
// çevirir. Mantık eski CabinInventoryNotifier.submit ile birebir aynıdır.
//
// KÜBİK:
//   - tek input. cabinDrawerDetailId = cabinDrawerDetail.first.id
//   - shelfNo = drawerUnit.orderNo, compartmentNo = drawerUnit.compartmentNo
//   - refill + isMeasureUnit Drug → quantity = toFillingBackendValue(adet)
//
// BİRİM DOZ:
//   - numberOfSteps kadar input. cabinDrawerDetailId = cabinDrawerDetail[i].id
//   - shelfNo = drawerUnit.compartmentNo, compartmentNo = cabinDrawerDetail[i].stepNo
//   - boş göz (fill=0 && count=0) → miad fallback (2099-12-31), aksi halde
//     per-cell veya single miad
//
// Yalnızca dolum/sayım anlamlı satırlar gönderilir (boş göz fallback ile).
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class RefillJobParamsMapper {
  static final DateTime _emptyMiadFallback = DateTime(2099, 12, 31);

  /// Bir job'ın tüm hedeflerini params listesine çevirir.
  static List<RefillMedicineParams> toParams(RefillDrawerJob job) {
    final params = <RefillMedicineParams>[];
    for (final target in job.targets) {
      params.addAll(_targetToParams(target));
    }
    return params;
  }

  /// Tek bir hedefin params'ını üretir (kübik lid bazlı kayıt için).
  static List<RefillMedicineParams> toParamsForTarget(RefillFillTarget target) => _targetToParams(target);

  static List<RefillMedicineParams> _targetToParams(RefillFillTarget target) {
    final assignment = target.assignment;
    final medicine = assignment.medicine;
    final unit = assignment.drawerUnit;
    final matId = medicine?.id ?? 0;

    // refill + ölçü-birimli Drug → adet girilir, backend'e adet×doz (ml) gider.
    final bool isMeasureUnitInput = medicine is Drug && medicine.isMeasureUnit;

    if (target.isKubik) {
      if (target.cubicFilling <= 0) return const [];

      final detailId = assignment.cabinDrawerDetail?.firstOrNull?.id ?? 0;
      final rawFill = target.cubicFilling;
      final quantity = isMeasureUnitInput ? medicine.toFillingBackendValue(rawFill).toDouble() : rawFill;

      return [
        RefillMedicineParams(
          materialId: matId,
          cabinDrawerDetailId: detailId,
          quantity: quantity,
          countQuantity: target.cubicCount,
          miadDate: target.cubicMiad,
          shelfNo: unit?.orderNo ?? 1,
          compartmentNo: unit?.compartmentNo ?? 0,
        ),
      ];
    }

    // Birim doz: her göz ayrı param.
    final result = <RefillMedicineParams>[];
    for (int i = 0; i < target.numberOfSteps; i++) {
      final step = target.steps[i];
      final detailId = assignment.cabinDrawerDetail != null && i < assignment.cabinDrawerDetail!.length
          ? (assignment.cabinDrawerDetail![i].id ?? 0)
          : 0;

      final quantity = isMeasureUnitInput
          ? medicine.toFillingBackendValue(step.fillingQuantity ?? 0).toDouble()
          : step.fillingQuantity;

      // Boş göz (fill=0 && count=0) → fallback miad; aksi halde per-cell/single.
      final DateTime? miadDate;
      if ((step.fillingQuantity ?? 0) == 0 && (step.countQuantity ?? 0) == 0) {
        miadDate = _emptyMiadFallback;
      } else {
        miadDate = step.miadDate ?? target.singleMiad;
      }

      result.add(
        RefillMedicineParams(
          materialId: matId,
          cabinDrawerDetailId: detailId,
          quantity: quantity ?? 0,
          countQuantity: step.countQuantity ?? 0,
          miadDate: miadDate,
          // Birim dozda eski kod: shelfNo = drawerUnit.compartmentNo,
          // compartmentNo = cabinDrawerDetail[i].stepNo
          shelfNo: unit?.compartmentNo ?? 0,
          compartmentNo: assignment.cabinDrawerDetail != null && i < assignment.cabinDrawerDetail!.length
              ? (assignment.cabinDrawerDetail![i].stepNo ?? 0)
              : 0,
        ),
      );
    }
    return result;
  }
}
