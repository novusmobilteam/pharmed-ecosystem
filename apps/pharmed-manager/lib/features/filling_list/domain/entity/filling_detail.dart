import '../../../../core/core.dart';
import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../data/model/filling_detail_dto.dart';
import '../../../cabin/domain/entity/drawer_unit.dart';
import '../../../cabin/domain/entity/drawer_cell.dart';
import '../../../cabin_assignment/domain/entity/cabin_assignment.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../../user/user.dart';

// Dolum listesi oluşturulduktan sonra oluşturulan dolum listesinin detayı
// görüntülenmek istendiğinde kullanılan model.
class FillingDetail implements TableData {
  final int? id;
  final int? fillingListId;
  final int? medicineId;
  final Medicine? medicine;
  final DrawerUnit? cabinDrawer;
  final CabinAssignment? cabinAssignment;
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
      medicine: medicine?.toDTO(),
      cabinDrawer: cabinDrawer?.toDTO(),
      cabinAssignment: cabinAssignment?.toDTO(),
      quantity: quantity,
      fillingQuantity: fillingQuantity,
      fillingDate: fillingDate,
      fillingUserId: fillingUserId,
      fillingUser: fillingUser?.toDTO(),
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
  List get content => [
        medicineId,
        medicine?.name,
        medicine?.barcode,
      ];

  @override
  List get rawContent => [
        medicineId,
        medicine?.name,
        medicine?.barcode,
      ];

  @override
  List<String?> get titles => [];
}

extension FillingDetailAdapter on FillingDetail {
  /// Bu fonksiyon, FillingDetail nesnesini alıp, View'ın anlayacağı
  /// eksiksiz bir CabinDrawerQuantity nesnesine dönüştürür.
  CabinAssignment toCompatibleQuantity() {
    final baseQuantity = cabinAssignment ?? CabinAssignment();

    return baseQuantity.copyWith(
      // JSON B'de material üstteydi, onu alta indiriyoruz
      medicine: medicine,
      cabinDrawerDetail: cabinDrawerDetail,
    );
  }
}
