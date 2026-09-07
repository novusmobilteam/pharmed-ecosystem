// Dolum listesi oluşturulduktan sonra oluşturulan dolum listesinin detayı
// görüntülenmek istendiğinde kullanılan model.
import 'package:pharmed_core/pharmed_core.dart';

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

  bool get isFilled => (quantity ?? 0) == (fillingQuantity ?? 0);
}

extension FillingDetailAdapter on RefillListDetail {
  MedicineAssignment toCompatibleQuantity() {
    final baseQuantity = cabinAssignment ?? MedicineAssignment();
    return baseQuantity.copyWith(medicine: medicine, cabinDrawerDetail: cabinDrawerDetail);
  }

  String plannedQuantityLabel(context) {
    return toCompatibleQuantity().quantityWithDoseLabel(context, quantity);
  }

  /// Bu kayıt için şu ana kadar YAPILMIŞ dolum miktarını (varsa) aynı
  /// adet/doz formatında gösterir. fillingQuantity null/0 ise null döner —
  /// çağıran taraf bu durumda ilgili kolonu/hücreyi hiç göstermemeli.
  String? filledQuantityLabel(context) {
    final filled = fillingQuantity;
    if (filled == null || filled == 0) return null;
    return toCompatibleQuantity().quantityWithDoseLabel(context, filled);
  }
}
