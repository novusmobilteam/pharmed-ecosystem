// [SWREQ-CORE-CABINOP-008] [IEC 62304 §5.5]
//
// Dolum/sayım/boşaltma hedeflerini backend'in tek satırlık kayıt formatına
// çevirir. Kübikte tek satır, birim dozda göz sayısı kadar satır üretilir.
// Hangi miktar alanının gönderileceği [CabinOperationMode]'dan gelir;
// alanı olmayan miktarın key'i JSON'a HİÇ eklenmez.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

class CabinOperationMedicineParams {
  const CabinOperationMedicineParams({
    required this.materialId,
    required this.cabinDrawerDetailId,
    required this.miadDate,
    required this.shelfNo,
    required this.compartmentNo,
    this.countQuantity,
    this.quantity,
  });

  final int materialId;
  final int cabinDrawerDetailId;

  /// null → sayım alanı yok (boşaltma).
  final double? countQuantity;

  /// null → ikincil miktar yok (sayım).
  final double? quantity;

  final DateTime? miadDate;
  final int shelfNo;
  final int compartmentNo;

  Map<String, dynamic> toJson() => {
    "materialId": materialId,
    "cabinDrawrDetailId": cabinDrawerDetailId,
    if (countQuantity != null) "censusQuantity": countQuantity,
    if (quantity != null) "quantity": quantity,
    "miadDate": miadDate?.toIso8601String(),
    "shelfNo": shelfNo,
    "corpartmentNo": compartmentNo,
  };
}

/// Bir hedefin backend'e gidecek tek bir göz satırı — DTO'dan bağımsız.
/// Dolum/sayım/boşaltma ve dolum listesi mapper'ları bunu kendi DTO'larına çevirir.
typedef CabinOperationCellRow = ({
  int detailId,
  int shelfNo,
  int compartmentNo,
  double? countQuantity,
  double? quantity,
  DateTime? miadDate,
});

abstract final class CabinOperationParamsMapper {
  static List<CabinOperationMedicineParams> toParams(CabinOperationDrawerJob job) => [
    for (final target in job.targets) ...toParamsForTarget(target),
  ];

  static List<CabinOperationMedicineParams> toParamsForTarget(CabinOperationTarget target) {
    final materialId = target.assignment.medicine?.id ?? 0;
    return [
      for (final r in cellRows(target))
        CabinOperationMedicineParams(
          materialId: materialId,
          cabinDrawerDetailId: r.detailId,
          countQuantity: r.countQuantity,
          quantity: r.quantity,
          miadDate: r.miadDate,
          shelfNo: r.shelfNo,
          compartmentNo: r.compartmentNo,
        ),
    ];
  }

  /// Hedefin göz satırları: kübikte (girdi varsa) tek satır, birim dozda göz
  /// sayısı kadar satır. Adres, miktar alanları ve SKT kuralı tek yerde.
  static List<CabinOperationCellRow> cellRows(CabinOperationTarget target) {
    final mode = target.mode;
    final assignment = target.assignment;
    final unit = assignment.drawerUnit;

    CabinOperationCellRow row(
      int detailId,
      int shelfNo,
      int compartmentNo,
      double count,
      double secondary,
      DateTime? miad,
    ) => (
      detailId: detailId,
      shelfNo: shelfNo,
      compartmentNo: compartmentNo,
      countQuantity: mode.hasCountField ? count : null,
      quantity: mode.hasSecondaryField ? secondary : null,
      miadDate: miad,
    );

    if (target.isKubik) {
      if (!target.hasEntry) return const [];
      return [
        row(
          assignment.cabinDrawerDetail?.firstOrNull?.id ?? 0,
          unit?.orderNo ?? 1,
          unit?.compartmentNo ?? 0,
          target.cubicCount ?? 0,
          target.cubicSecondary,
          target.cubicMiad,
        ),
      ];
    }

    final cells = assignment.cabinDrawerDetail ?? const <DrawerCell>[];
    return [
      for (var i = 0; i < target.steps.length; i++)
        () {
          final step = target.steps[i];
          // Göz kaydı pozisyonla değil stepNo ile bulunur — backend sırasız gönderiyor.
          final cell = cells.firstWhereOrNull((c) => c.stepNo == i + 1);
          final isEmpty = (step.countQuantity ?? 0) == 0 && (step.secondaryQuantity ?? 0) == 0;
          return row(
            cell?.id ?? 0,
            unit?.compartmentNo ?? 0,
            cell?.stepNo ?? i + 1,
            step.countQuantity ?? 0,
            step.secondaryQuantity ?? 0,
            // Backend SKT'yi zorunlu tutuyor — boş göze işaret tarihi gider.
            isEmpty ? kEmptyCellMiad : (step.miadDate ?? target.singleMiad),
          );
        }(),
    ];
  }
}
