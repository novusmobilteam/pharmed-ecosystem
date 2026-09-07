// domain/refill_list_params_mapper.dart
//
// CabinOperationParamsMapper.toParamsForTarget'ın liste-bazlı akış
// karşılığı. Hücre geometrisi (shelfNo/compartmentNo/detailId) ve miad
// fallback mantığı BİREBİR AYNI (CabinOperationCellGeometry /
// CabinOperationMiadFallback yeniden kullanılıyor) — tek fark çıktı DTO'su
// (FillingListRefillParams) ve her satıra target.refillListDetailId'nin
// "id" olarak eklenmesi: backend /fiilingDetail/fill endpoint'i kaydı bu
// id ile eşleştiriyor. Bir hedef (kübikte tek lid, birim dozda tüm göz
// yığını) TEK bir RefillListDetail satırından geldiği için, o hedeften
// üretilen TÜM satırlar (birim dozda birden fazla göz olsa bile) aynı id'yi
// taşır.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class RefillListParamsMapper {
  static List<CabinRefillParams> toParamsForTarget(CabinOperationTarget target, CabinOperationParamsOps ops) {
    final detailId = target.refillListDetailId;
    if (detailId == null) return const []; // güvenlik: liste akışı dışında hiç çağrılmamalı

    final assignment = target.assignment;
    final medicine = assignment.medicine;
    final bool isMeasureUnitInput = medicine is Drug && medicine.isMeasureUnit;

    double convertedCount(double raw) =>
        (ops.convertCountQuantity && isMeasureUnitInput) ? medicine.toFillingBackendValue(raw).toDouble() : raw;

    double convertedQuantity(double raw) =>
        (ops.convertQuantityField && isMeasureUnitInput) ? medicine.toFillingBackendValue(raw).toDouble() : raw;

    if (target.isKubik) {
      if (!target.hasEntry) return const [];

      final geo = CabinOperationCellGeometry.forKubik(assignment);

      return [
        FillingListRefillParams(
          id: detailId,
          cabinDrawerDetailId: geo.detailId,
          quantity: convertedQuantity(target.cubicSecondary),
          censusQuantity: convertedCount(target.cubicCount),
          miadDate: target.cubicMiad ?? CabinOperationMiadFallback.empty,
        ),
      ];
    }

    final result = <CabinRefillParams>[];
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
        FillingListRefillParams(
          id: detailId,
          cabinDrawerDetailId: geo.detailId,
          quantity: convertedQuantity(step.secondaryQuantity ?? 0),
          censusQuantity: convertedCount(step.countQuantity ?? 0),
          miadDate: miadDate,
        ),
      );
    }
    return result;
  }
}
