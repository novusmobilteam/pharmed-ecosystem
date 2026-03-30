import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/features/medicine/mapper/medical_consumable_mapper.dart';

import 'drug_mapper.dart';

/// Medicine (Sealed) ↔ MedicineDTO dönüşümleri.
class MedicineMapper {
  const MedicineMapper();

  Medicine toEntity(MedicineDTO dto) {
    return dto.when(
      drug: (drugDto) => const DrugMapper().toEntity(drugDto),
      consumable: (consumableDto) => const MedicalConsumableMapper().toEntity(consumableDto),
    );
  }

  MedicineDTO toDto(Medicine entity) {
    if (entity is Drug) {
      return const DrugMapper().toDto(entity);
    } else if (entity is MedicalConsumable) {
      return const MedicalConsumableMapper().toDto(entity);
    }
    throw StateError('Tanımlanamayan Medicine alt tipi: ${entity.runtimeType}');
  }

  MedicineDTO? toDtoOrNull(Medicine? entity) {
    if (entity == null) return null;
    if (entity is Drug) {
      return const DrugMapper().toDto(entity);
    } else if (entity is MedicalConsumable) {
      return const MedicalConsumableMapper().toDto(entity);
    }
    throw StateError('Tanımlanamayan Medicine alt tipi: ${entity.runtimeType}');
  }

  List<Medicine> toEntityList(List<MedicineDTO> dtos) => dtos.map(toEntity).toList();

  List<MedicineDTO> toDtoList(List<Medicine> entities) => entities.map(toDto).toList();
}
