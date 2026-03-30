import 'package:pharmed_manager/core/core.dart';

import '../../../cabin_assignment/domain/entity/cabin_assignment.dart';

import '../../data/model/patient_medicine_withdraw_item_dto.dart';

// İlaç alım işleminde hastanın kendi getirmiş olduğu ve sisteme sonradan tanımlanan ilaçlar
// için kullanılan model.
class PatientMedicineWithdrawItem {
  final int id;
  final int hospitalizationId;
  final int patientId;
  final int compartmentNo;
  final String medicineName;
  final String barcode;
  final DateTime time;
  final int dosePiece;
  final String description;
  final DateTime? applicationDate;
  final User? applicationUser;

  final CabinAssignment assignment;

  PatientMedicineWithdrawItem({
    required this.id,
    required this.hospitalizationId,
    required this.patientId,
    required this.compartmentNo,
    required this.medicineName,
    required this.barcode,
    required this.time,
    required this.description,
    required this.dosePiece,
    required this.assignment,
    this.applicationDate,
    this.applicationUser,
  });
}

extension MedicineWithdrawMapper on PatientMedicineWithdrawItemDTO {
  PatientMedicineWithdrawItem toEntity() {
    return PatientMedicineWithdrawItem(
      id: id ?? 0,
      hospitalizationId: hospitalizationId ?? 0,
      patientId: patientId ?? 0,
      compartmentNo: compartmentNo ?? 0,
      medicineName: medicineName ?? '',
      barcode: barcode ?? '',
      time: time ?? DateTime.now(),
      description: description ?? '',
      dosePiece: dosePiece ?? 0,
      assignment: _buildLegacyDrawerObject(),
      applicationDate: applicationDate,
      applicationUser: const UserMapper().toEntityOrNull(applicationUser),
    );
  }

  /// KRİTİK NOKTA: DrawerStatusNotifier'ın beklediği nesneyi manuel oluşturuyoruz.
  CabinAssignment _buildLegacyDrawerObject() {
    // 1. RAW MAP verilerine erişim (Deep Nesting'den kurtarma operasyonu)
    // Quantity veya Stock DTO'larının içindeki raw map'leri kullanıyoruz.
    // Genelde 'Quantity' içindeki 'cabinDrawr' daha genel tanımları içerir.
    final rawDrawer = DrawerUnitMapper().toEntityOrNull(cabinDrawer);
    final rawDesign = rawDrawer?.drawerSlot;
    final rawDetail = rawDesign?.drawerConfig;
    final rawRootDrawer = rawDetail?.drawerType;

    // 2. Gerekli Donanım Verilerini Ayıkla
    final bool isKubik = rawRootDrawer?.isKubik ?? false;
    final String addressRow = rawDesign?.address ?? "0";
    final int portNo = rawDrawer?.compartmentNo ?? 1;
    final int orderNo = rawDrawer?.orderNo ?? 1; // Kübik için kapak no
    final int capacity = rawDetail?.numberOfSteps ?? 1; // Standart için adım sayısı

    // En dipteki 'Drawr' (Tip tanımı)
    final drawerType = DrawerType(id: rawRootDrawer?.id ?? 0, name: rawRootDrawer?.name ?? "", isKubik: isKubik);

    // Detay (Kapasite bilgisi)
    final drawerDetail = DrawerConfig(
      id: rawDetail?.id ?? 0,
      numberOfSteps: capacity,
      drawerType: drawerType,
      drawerTypeId: drawerType.id ?? 0,
    );

    // Tasarım (Adres/Row bilgisi)
    final cabinDesign = DrawerSlot(id: rawDesign?.id ?? 0, address: addressRow, drawerConfig: drawerDetail);

    // Çekmece/Göz (Port ve OrderNo bilgisi)
    final newCabinDrawer = DrawerUnit(
      id: rawDrawer?.id ?? 0,
      compartmentNo: portNo,
      orderNo: orderNo,
      drawerSlot: cabinDesign,
    );

    return CabinAssignment(id: id ?? 0, drawerUnit: newCabinDrawer);
  }
}
