import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// CabinTargetedPrescriptionItem ↔ CabinTargetedPrescriptionItemDto dönüşümleri.
class CabinTargetedRxItemMapper {
  const CabinTargetedRxItemMapper();

  CabinTargetedPrescriptionItem toEntity(CabinTargetedPrescriptionItemDto dto) {
    return CabinTargetedPrescriptionItem(
      id: dto.id ?? 0,
      prescriptionId: dto.prescriptionId ?? 0,
      dosePiece: dto.dosePiece ?? 0,
      firstDoseEmergency: dto.firstDoseEmergency ?? false,
      askDoctor: dto.askDoctor ?? false,
      inCaseOfNecessity: dto.inCaseOfNecessity ?? false,
      time: _parseTime(dto.time),
      lastMovement: const PrescriptionItemMovementMapper().toEntityOrNull(dto.lastMovement),
      hospitalization: const HospitalizationMapper().toEntityOrNull(dto.hospitalization),
      medicine: const MedicineMapper().toEntityOrNull(dto.medicine),
      cabinAssignment: dto.cabinAssignment != null
          ? const MedicineAssignmentMapper().toEntity(dto.cabinAssignment!)
          : MedicineAssignment.empty(cabinId: 0, cabinDrawerId: 0),
      stock: dto.cabinDrawerStock != null ? const CabinStockMapper().toEntity(dto.cabinDrawerStock!) : null,
    );
  }

  CabinTargetedPrescriptionItemDto toDto(CabinTargetedPrescriptionItem entity) {
    return CabinTargetedPrescriptionItemDto(
      id: entity.id,
      prescriptionId: entity.prescriptionId,
      dosePiece: entity.dosePiece,
      firstDoseEmergency: entity.firstDoseEmergency,
      askDoctor: entity.askDoctor,
      inCaseOfNecessity: entity.inCaseOfNecessity,
      time: entity.time?.toIso8601String(),
      hospitalization: const HospitalizationMapper().toDtoOrNull(entity.hospitalization),
      medicine: const MedicineMapper().toDtoOrNull(entity.medicine),
      cabinAssignment: const MedicineAssignmentMapper().toDtoOrNull(entity.cabinAssignment),
      cabinDrawerStock: const CabinStockMapper().toDtoOrNull(entity.stock),
    );
  }

  List<CabinTargetedPrescriptionItem> toEntityList(List<CabinTargetedPrescriptionItemDto> dtos) =>
      dtos.map(toEntity).toList();

  List<CabinTargetedPrescriptionItemDto> toDtoList(List<CabinTargetedPrescriptionItem> entities) =>
      entities.map(toDto).toList();

  CabinTargetedPrescriptionItem? toEntityOrNull(CabinTargetedPrescriptionItemDto? dto) =>
      dto == null ? null : toEntity(dto);

  CabinTargetedPrescriptionItemDto? toDtoOrNull(CabinTargetedPrescriptionItem? entity) =>
      entity == null ? null : toDto(entity);

  DateTime? _parseTime(String? raw) => raw == null ? null : DateTime.tryParse(raw);
}
