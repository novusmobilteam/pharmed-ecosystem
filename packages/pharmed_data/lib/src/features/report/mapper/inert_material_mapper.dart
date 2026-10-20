import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class InertMaterialMapper {
  const InertMaterialMapper();

  InertMaterial toEntity(InertMaterialDto dto) {
    return InertMaterial(
      stationId: dto.stationId,
      stationName: dto.stationName,
      materialId: dto.materialId,
      materialName: dto.materialName,
      barcode: dto.barcode,
      quantity: dto.quantity,
      medicine: const MedicineMapper().toEntityOrNull(dto.material),
    );
  }

  InertMaterial? toEntityOrNull(InertMaterialDto? dto) => dto == null ? null : toEntity(dto);

  List<InertMaterial> toEntityList(List<InertMaterialDto> dtos) => dtos.map(toEntity).toList();

  InertMaterialDto toDto(InertMaterial entity) {
    return InertMaterialDto(
      stationId: entity.stationId,
      stationName: entity.stationName,
      materialId: entity.materialId,
      materialName: entity.materialName,
      barcode: entity.barcode,
      quantity: entity.quantity,
      material: const MedicineMapper().toDtoOrNull(entity.medicine),
    );
  }
}
