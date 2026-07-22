// [SWREQ-CLI-MCENSUS-006] [IEC 62304 §5.5]
// RefillFillTarget'ları backend'e gönderilecek MasterCensusParams listesine
// çevirir — RefillJobParamsMapper ile aynı mantık, tek fark: fillingQuantity
// yok (sayımda dolum miktarı girilmiyor), quantity = sayım miktarının kendisi.
//
// MasterCensusParams gerçek DTO'dur (pharmed_core), CompleteMasterCensusUseCase
// ile birlikte kullanılır.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class CensusJobParamsMapper {
  static final DateTime _emptyMiadFallback = DateTime(2099, 12, 31);

  static List<MasterCensusParams> toParams(CensusDrawerJob job) {
    final params = <MasterCensusParams>[];
    for (final target in job.targets) {
      params.addAll(_targetToParams(target));
    }
    return params;
  }

  static List<MasterCensusParams> toParamsForTarget(CensusTarget target) => _targetToParams(target);

  static List<MasterCensusParams> _targetToParams(CensusTarget target) {
    final assignment = target.assignment;
    final medicine = assignment.medicine;
    final unit = assignment.drawerUnit;
    final matId = medicine?.id ?? 0;

    final bool isMeasureUnitInput = medicine is Drug && medicine.isMeasureUnit;

    if (target.isKubik) {
      if (target.cubicCount <= 0) return const [];

      final detailId = assignment.cabinDrawerDetail?.firstOrNull?.id ?? 0;
      final rawCount = target.cubicCount;
      final quantity = isMeasureUnitInput ? medicine.toFillingBackendValue(rawCount).toDouble() : rawCount;

      return [
        MasterCensusParams(matId, detailId, quantity, target.cubicMiad, unit?.orderNo ?? 1, unit?.compartmentNo ?? 0),
      ];
    }

    final result = <MasterCensusParams>[];
    for (int i = 0; i < target.numberOfSteps; i++) {
      final step = target.steps[i];
      final detailId = assignment.cabinDrawerDetail != null && i < assignment.cabinDrawerDetail!.length
          ? (assignment.cabinDrawerDetail![i].id ?? 0)
          : 0;

      final quantity = isMeasureUnitInput
          ? medicine.toFillingBackendValue(step.countQuantity ?? 0).toDouble()
          : (step.countQuantity ?? 0);

      final DateTime? miadDate = (step.countQuantity ?? 0) == 0 ? _emptyMiadFallback : step.miadDate;

      result.add(
        MasterCensusParams(
          matId,
          detailId,
          quantity,
          miadDate,
          unit?.compartmentNo ?? 0,
          assignment.cabinDrawerDetail != null && i < assignment.cabinDrawerDetail!.length
              ? (assignment.cabinDrawerDetail![i].stepNo ?? 0)
              : 0,
        ),
      );
    }
    return result;
  }
}
