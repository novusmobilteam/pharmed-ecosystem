import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// PatientMedicineWithdrawItem ↔ PatientMedicineWithdrawItemDTO dönüşümleri.
class PatientMedicineWithdrawItemMapper {
  const PatientMedicineWithdrawItemMapper();

  PatientMedicineWithdrawItem toEntity(PatientMedicineWithdrawItemDTO dto) {
    return PatientMedicineWithdrawItem(
      id: dto.id ?? 0,
      hospitalizationId: dto.hospitalizationId ?? 0,
      patientId: dto.patientId ?? 0,
      compartmentNo: dto.compartmentNo ?? 0,
      medicineName: dto.medicineName ?? '',
      barcode: dto.barcode ?? '',
      time: dto.time ?? DateTime.now(),
      description: dto.description ?? '',
      dosePiece: dto.dosePiece ?? 0,
      applicationDate: dto.applicationDate,
      applicationUser: const UserMapper().toEntityOrNull(dto.applicationUser),
      // İşte o meşhur operasyonu burada yapıyoruz
      assignment: _mapToCabinAssignment(dto),
    );
  }

  /// DTO'daki düzensiz çekmece verisinden donanımın anlayacağı
  /// hiyerarşik CabinAssignment nesnesini oluşturur.
  MedicineAssignment _mapToCabinAssignment(PatientMedicineWithdrawItemDTO dto) {
    // 1. DTO'dan ana çekmece birimini dönüştür (Alt mapper'ı kullanarak)
    final unit = const DrawerUnitMapper().toEntityOrNull(dto.cabinDrawer);

    if (unit == null) {
      return MedicineAssignment.empty(cabinId: 0, cabinDrawerId: 0);
    }

    // 2. Mevcut hiyerarşiyi (Deep Nesting) kontrollü şekilde ayağa kaldır
    final slot = unit.drawerSlot;
    final config = slot?.drawerConfig;
    final type = config?.drawerType;

    // 3. Verileri ayıkla (Fallback değerlerle güvenli hale getir)
    final isKubik = type?.isKubik ?? false;
    final addressRow = slot?.address ?? "0";
    final portNo = unit.compartmentNo ?? 1;
    final orderNo = unit.orderNo ?? 1; // Kübik kapak no
    final capacity = config?.numberOfSteps ?? 1; // Standart adım sayısı

    // 4. Hiyerarşiyi dipten yukarıya doğru yeniden inşa et (Re-build)
    final finalType = DrawerType(id: type?.id ?? 0, name: type?.name ?? "", isKubik: isKubik);

    final finalConfig = DrawerConfig(
      id: config?.id ?? 0,
      numberOfSteps: capacity,
      drawerType: finalType,
      drawerTypeId: finalType.id ?? 0,
    );

    final finalSlot = DrawerSlot(id: slot?.id ?? 0, address: addressRow, drawerConfig: finalConfig);

    final finalUnit = DrawerUnit(id: unit.id ?? 0, compartmentNo: portNo, orderNo: orderNo, drawerSlot: finalSlot);

    return MedicineAssignment(id: dto.id ?? 0, drawerUnit: finalUnit);
  }

  // List dönüşümleri her zamanki gibi...
  List<PatientMedicineWithdrawItem> toEntityList(List<PatientMedicineWithdrawItemDTO> dtos) =>
      dtos.map(toEntity).toList();

  PatientMedicineWithdrawItemDTO toDto(PatientMedicineWithdrawItem entity) {
    // DTO'ya geri dönüş ihtiyacı olursa burada implement edilebilir
    throw UnimplementedError("PatientWithdraw conversion to DTO is not needed yet.");
  }
}
