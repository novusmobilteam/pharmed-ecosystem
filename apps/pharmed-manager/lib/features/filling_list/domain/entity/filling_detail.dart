import '../../../../core/core.dart';
import '../../data/model/filling_detail_dto.dart';

// Dolum listesi oluşturulduktan sonra oluşturulan dolum listesinin detayı
// görüntülenmek istendiğinde kullanılan model.
class FillingDetail implements TableData {
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

  FillingDetail({
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

  FillingDetailDTO toDTO() {
    return FillingDetailDTO(
      id: id,
      fillingListId: fillingListId,
      medicineId: medicineId,
      medicine: MedicineMapper().toDtoOrNull(medicine),
      cabinDrawer: DrawerUnitMapper().toDtoOrNull(cabinDrawer),
      //cabinAssignment: cabinAssignment?.toDTO(),
      quantity: quantity,
      fillingQuantity: fillingQuantity,
      fillingDate: fillingDate,
      fillingUserId: fillingUserId,
      fillingUser: const UserMapper().toDtoOrNull(fillingUser),
      isEdit: isEdit,
    );
  }

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

  @override
  List get content => [medicineId, medicine?.name, medicine?.barcode];

  @override
  List get rawContent => [medicineId, medicine?.name, medicine?.barcode];

  @override
  List<String?> get titles => [];
}

extension FillingDetailAdapter on FillingDetail {
  /// Bu fonksiyon, FillingDetail nesnesini alıp, View'ın anlayacağı
  /// eksiksiz bir CabinDrawerQuantity nesnesine dönüştürür.
  MedicineAssignment toCompatibleQuantity() {
    final baseQuantity = cabinAssignment ?? MedicineAssignment();

    return baseQuantity.copyWith(
      // JSON B'de material üstteydi, onu alta indiriyoruz
      medicine: medicine,
      cabinDrawerDetail: cabinDrawerDetail,
    );
  }
}
