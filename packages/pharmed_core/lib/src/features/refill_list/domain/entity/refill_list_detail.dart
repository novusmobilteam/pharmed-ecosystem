// Dolum listesi oluşturulduktan sonra oluşturulan dolum listesinin detayı
// görüntülenmek istendiğinde kullanılan model.
import 'dart:ui';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Dolum listesindeki tek bir kalemin dolum durumu.
enum RefillListItemFillStatus {
  notStarted, // Hiç dolum yapılmadı
  partial, // Kısmen dolduruldu — tekrar seçilebilir
  completed; // Hedef miktara ulaşıldı (veya aşıldı) — seçilemez

  String get label => switch (this) {
    RefillListItemFillStatus.notStarted => contextlessL10n().enumCore_refillListItemFillStatusNotStarted,
    RefillListItemFillStatus.partial => contextlessL10n().enumCore_refillListItemFillStatusPartial,
    RefillListItemFillStatus.completed => contextlessL10n().enumCore_refillListItemFillStatusCompleted,
  };

  MedChipStyle get chipStyle => switch (this) {
    RefillListItemFillStatus.completed => MedChipStyle.success,
    RefillListItemFillStatus.partial => MedChipStyle.warning,
    RefillListItemFillStatus.notStarted => MedChipStyle.neutral,
  };

  Color get color => switch (this) {
    RefillListItemFillStatus.completed => MedColors.green,
    RefillListItemFillStatus.partial => MedColors.amber,
    RefillListItemFillStatus.notStarted => MedColors.text3,
  };
}

class RefillListDetail {
  final int? id;
  final int? fillingListId;
  final int? medicineId;
  final Medicine? medicine;
  final DrawerUnit? cabinDrawer;
  final MedicineAssignment? cabinAssignment;
  final num? quantity;
  final num? fillingQuantity;
  final DateTime? fillingDate;
  final int? fillingUserId;
  final User? fillingUser;
  final bool? isEdit;
  final List<CabinStock>? stocks;
  final List<DrawerCell>? cabinDrawerDetail;

  RefillListDetail({
    this.id,
    this.fillingListId,
    this.medicineId,
    this.medicine,
    this.cabinDrawer,
    this.cabinAssignment,
    this.quantity,
    this.fillingQuantity,
    this.fillingDate,
    this.fillingUserId,
    this.fillingUser,
    this.isEdit,
    this.cabinDrawerDetail,
    this.stocks,
  });

  String get _address {
    if (cabinDrawer != null && cabinDrawer?.drawerSlot != null) {
      if ((int.tryParse(cabinDrawer!.drawerSlot!.address!) ?? 0) < 10) {
        return cabinDrawer!.drawerSlot!.address!.substring(1);
      } else {
        return cabinDrawer!.drawerSlot!.address!;
      }
    } else {
      return '-';
    }
  }

  String get position => '$_address / ${cabinDrawer?.orderNo}';

  /// Planlanan miktar kadar (veya fazlası) doldurulduysa true — bu satır
  /// dolum için artık seçilemez. Kısmi dolumda (örn. 8 planlandı, 5
  /// dolduruldu) false döner, satır kalan miktar için tekrar seçilebilir.
  /// `quantity` ve `fillingQuantity` aynı birimde (backend değeri) gelir.
  bool get isFilled => (fillingQuantity ?? 0) >= (quantity ?? 0);

  RefillListItemFillStatus get fillStatus {
    if (isFilled) return RefillListItemFillStatus.completed;
    if ((fillingQuantity ?? 0) > 0) return RefillListItemFillStatus.partial;
    return RefillListItemFillStatus.notStarted;
  }
}

extension FillingDetailAdapter on RefillListDetail {
  MedicineAssignment toCompatibleQuantity() {
    final base = cabinAssignment ?? MedicineAssignment();
    return base.copyWith(medicine: medicine, cabinDrawerDetail: cabinDrawerDetail, stocks: stocks);
  }

  /// Planlanan dolum miktarı ("24 Adet" / "24 Adet × 100 ml").
  String get plannedQuantityLabel => toCompatibleQuantity().quantityLabel(quantity);

  /// Şu ana kadar YAPILMIŞ dolum miktarı. Hiç dolum yapılmadıysa null —
  /// çağıran taraf bu durumda hücreyi "-" ile gösterir ya da hiç göstermez.
  String? get filledQuantityLabel {
    final filled = fillingQuantity;
    if (filled == null || filled == 0) return null;
    return toCompatibleQuantity().quantityLabel(filled);
  }
}
