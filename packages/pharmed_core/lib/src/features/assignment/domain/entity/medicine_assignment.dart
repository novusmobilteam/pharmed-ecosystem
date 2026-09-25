import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

/// Bir ilacın kabindeki bir göze ataması.
///
/// Tüm miktarlar (min/max/kritik, stok, dolum) ADET cinsindendir ve backend'e
/// olduğu gibi gönderilir. Ölçü birimli ilaçlarda ml yalnızca gösterimde
/// türetilir: "4 Adet × 100 ml".
class MedicineAssignment {
  final int? id;
  final int? cabinDrawerId;
  final num minQuantity;
  final num criticalQuantity;
  final num maxQuantity;
  final num quantity;
  final num? fillingQuantity;
  final Cabin? cabin;
  final Medicine? medicine;
  final DrawerUnit? drawerUnit;
  final List<DrawerCell>? cabinDrawerDetail;
  final List<CabinStock>? stocks;

  MedicineAssignment({
    this.id,
    this.cabinDrawerId,
    this.minQuantity = 0.0,
    this.criticalQuantity = 0.0,
    this.maxQuantity = 0.0,
    this.quantity = 0.0,
    this.cabin,
    this.medicine,
    this.drawerUnit,
    this.cabinDrawerDetail,
    this.stocks,
    this.fillingQuantity,
  });

  /// Gözdeki toplam stok (adet).
  double get totalQuantity =>
      (stocks ?? const <CabinStock>[]).fold(0.0, (sum, s) => sum + (s.quantity ?? 0).toDouble());

  bool get isKubikType => drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? true;

  // ── Gösterim ─────────────────────────────────────────────────────────

  /// Adet miktarını ilacın birimine göre etiketler. Ölçü birimli ilaçta
  /// "4 Adet × 100 ml", diğerlerinde "4 Adet". Tüm ekranlarda aynı format.
  String quantityLabel(num? pieces) {
    final count = (pieces ?? 0).toDouble().formatFractional;
    final med = medicine;
    if (med is Drug && med.isMeasureUnit && med.fillingMultiplier > 1) {
      return contextlessL10n().common_quantityWithMeasure(
        count,
        med.fillingMultiplier.formatFractional,
        med.doseUnit?.name ?? 'ml',
      );
    }
    return contextlessL10n().common_quantityPieces(count);
  }

  String get minQuantityLabel => quantityLabel(minQuantity);
  String get maxQuantityLabel => quantityLabel(maxQuantity);
  String get critQuantityLabel => quantityLabel(criticalQuantity);
  String get totalQuantityLabel => quantityLabel(totalQuantity);

  // MedicineAssignment

  /// Mevcut stok / maksimum kapasite — birim bir kez, sonda.
  /// "4/36 Adet" ya da "4/36 Adet × 100 ml".
  String get stockRatioLabel {
    final current = totalQuantity.formatFractional;
    final max = maxQuantity.toDouble().formatFractional;
    final med = medicine;
    if (med is Drug && med.isMeasureUnit && med.fillingMultiplier > 1) {
      return contextlessL10n().common_quantityRatioWithMeasure(
        current,
        max,
        med.fillingMultiplier.formatFractional,
        med.doseUnit?.name ?? 'ml',
      );
    }
    return contextlessL10n().common_quantityRatioPieces(current, max);
  }

  MedicineAssignment copyWith({
    int? id,
    int? cabinDrawerId,
    num? minQuantity,
    num? criticalQuantity,
    num? maxQuantity,
    num? quantity,
    num? fillingQuantity,
    Cabin? cabin,
    Medicine? medicine,
    DrawerUnit? drawerUnit,
    List<DrawerCell>? cabinDrawerDetail,
    List<CabinStock>? stocks,
  }) {
    return MedicineAssignment(
      id: id ?? this.id,
      cabinDrawerId: cabinDrawerId ?? this.cabinDrawerId,
      minQuantity: minQuantity ?? this.minQuantity,
      criticalQuantity: criticalQuantity ?? this.criticalQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      quantity: quantity ?? this.quantity,
      cabin: cabin ?? this.cabin,
      medicine: medicine ?? this.medicine,
      drawerUnit: drawerUnit ?? this.drawerUnit,
      cabinDrawerDetail: cabinDrawerDetail ?? this.cabinDrawerDetail,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
      stocks: stocks ?? this.stocks,
    );
  }

  factory MedicineAssignment.empty({required int cabinDrawerId}) => MedicineAssignment(cabinDrawerId: cabinDrawerId);
}
