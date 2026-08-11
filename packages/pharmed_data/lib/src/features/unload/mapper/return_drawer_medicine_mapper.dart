import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// ReturnDrawerMedicine ↔ ReturnDrawerMedicineDTO dönüşümleri.
class ReturnDrawerMedicineMapper {
  const ReturnDrawerMedicineMapper();

  ReturnDrawerMedicine toEntity(ReturnDrawerMedicineDTO dto) {
    return ReturnDrawerMedicine(
      id: dto.id,
      prescriptionItemId: dto.prescriptionItemId,
      materialId: dto.materialId,
      quantity: dto.quantity,
      returnUserId: dto.returnUserId,
      // Alt Mapper'lar
      prescriptionItem: const PrescriptionItemMapper().toEntityOrNull(dto.prescriptionItem),
      material: const MedicineMapper().toEntityOrNull(dto.material),
      returnUser: const UserMapper().toEntityOrNull(dto.returnUser),
      returnDate: dto.returnDate == null ? null : DateTime.tryParse(dto.returnDate!),
    );
  }

  ReturnDrawerMedicineDTO toDto(ReturnDrawerMedicine entity) {
    return ReturnDrawerMedicineDTO(
      id: entity.id,
      prescriptionItemId: entity.prescriptionItemId,
      materialId: entity.materialId,
      quantity: entity.quantity,
      returnUserId: entity.returnUserId,
      // Alt DTO Dönüşümleri
      prescriptionItem: const PrescriptionItemMapper().toDtoOrNull(entity.prescriptionItem),
      material: const MedicineMapper().toDtoOrNull(entity.material),
      returnUser: const UserMapper().toDtoOrNull(entity.returnUser),
      returnDate: entity.returnDate?.toIso8601String(),
    );
  }

  List<ReturnDrawerMedicine> toEntityList(List<ReturnDrawerMedicineDTO> dtos) => dtos.map(toEntity).toList();
  List<ReturnDrawerMedicineDTO> toDtoList(List<ReturnDrawerMedicine> entities) => entities.map(toDto).toList();
  ReturnDrawerMedicine? toEntityOrNull(ReturnDrawerMedicineDTO? dto) => dto == null ? null : toEntity(dto);
  ReturnDrawerMedicineDTO? toDtoOrNull(ReturnDrawerMedicine? entity) => entity == null ? null : toDto(entity);
}
