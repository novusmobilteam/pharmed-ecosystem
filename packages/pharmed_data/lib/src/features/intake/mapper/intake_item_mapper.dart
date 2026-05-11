import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// MedicineWithdrawItem ↔ MedicineWithdrawItemDTO dönüşümleri.
class IntakeItemMapper {
  const IntakeItemMapper();

  MedicineIntakeItem toEntity(MedicineIntakeItemDto dto) {
    return MedicineIntakeItem(
      id: dto.id ?? 0,
      prescriptionId: dto.prescriptionId ?? 0,
      medicineName: MedicineMapper().toEntityOrNull(dto.medicine)?.name ?? 'Bilinmeyen İlaç',
      medicineBarcode: MedicineMapper().toEntityOrNull(dto.medicine)?.barcode ?? '',
      dosePiece: dto.dosePiece ?? 0,
      firstDoseEmergency: dto.firstDoseEmergency ?? false,
      askDoctor: dto.askDoctor ?? false,
      inCaseOfNecessity: dto.inCaseOfNecessity ?? false,
      time: _parseTime(dto.time),
      applicationDate: dto.applicationDate,

      // Alt Mapper'lar
      hospitalization: const HospitalizationMapper().toEntityOrNull(dto.hospitalization),
      medicine: const MedicineMapper().toEntityOrNull(dto.medicine),
      approvalUser: const UserMapper().toEntityOrNull(dto.approvalUser),
      applicationUser: const UserMapper().toEntityOrNull(dto.applicationUser),

      // Kabinet ve Çekmece Bilgileri
      cabinAssignment: dto.cabinAssignment != null
          ? const MedicineAssignmentMapper().toEntity(dto.cabinAssignment!)
          : MedicineAssignment.empty(cabinId: 0, cabinDrawerId: 0),

      stock: dto.cabinDrawerStock != null ? const CabinStockMapper().toEntity(dto.cabinDrawerStock!) : null,
    );
  }

  MedicineIntakeItemDto toDto(MedicineIntakeItem entity) {
    return MedicineIntakeItemDto(
      id: entity.id,
      prescriptionId: entity.prescriptionId,
      dosePiece: entity.dosePiece,
      firstDoseEmergency: entity.firstDoseEmergency,
      askDoctor: entity.askDoctor,
      inCaseOfNecessity: entity.inCaseOfNecessity,
      applicationDate: entity.applicationDate,
      time: entity.time?.toIso8601String(),

      // Alt DTO Dönüşümleri
      hospitalization: const HospitalizationMapper().toDtoOrNull(entity.hospitalization),
      medicine: const MedicineMapper().toDtoOrNull(entity.medicine),
      approvalUser: const UserMapper().toDtoOrNull(entity.approvalUser),
      applicationUser: const UserMapper().toDtoOrNull(entity.applicationUser),
      cabinAssignment: const MedicineAssignmentMapper().toDtoOrNull(entity.cabinAssignment),
      cabinDrawerStock: const CabinStockMapper().toDtoOrNull(entity.stock),
    );
  }

  /// String gelen zaman bilgisini (Örn: "14:30") DateTime'a çevirir.
  DateTime? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      // Sadece saat formatı geliyorsa bugünün tarihiyle birleştirir
      if (timeStr.contains(':')) {
        final now = DateTime.now();
        final parts = timeStr.split(':');
        return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      }
      return DateTime.tryParse(timeStr);
    } catch (_) {
      return null;
    }
  }

  List<MedicineIntakeItem> toEntityList(List<MedicineIntakeItemDto> dtos) => dtos.map(toEntity).toList();

  List<MedicineIntakeItemDto> toDtoList(List<MedicineIntakeItem> entities) => entities.map(toDto).toList();

  MedicineIntakeItem? toEntityOrNull(MedicineIntakeItemDto? dto) => dto == null ? null : toEntity(dto);

  MedicineIntakeItemDto? toDtoOrNull(MedicineIntakeItem? entity) => entity == null ? null : toDto(entity);
}
