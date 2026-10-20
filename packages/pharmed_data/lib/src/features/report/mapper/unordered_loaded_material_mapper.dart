import 'package:pharmed_core/pharmed_core.dart';

class UnorderedLoadedMaterialMapper {
  const UnorderedLoadedMaterialMapper();

  UnorderedLoadedMaterial toEntity(UnorderedLoadedMaterialDto dto) {
    return UnorderedLoadedMaterial(
      stationId: dto.stationId,
      stationName: dto.stationName,
      materialId: dto.materialId,
      materialName: dto.materialName,
      barcode: dto.barcode,
      quantity: dto.quantity,
    );
  }

  UnorderedLoadedMaterial? toEntityOrNull(UnorderedLoadedMaterialDto? dto) => dto == null ? null : toEntity(dto);

  List<UnorderedLoadedMaterial> toEntityList(List<UnorderedLoadedMaterialDto> dtos) => dtos.map(toEntity).toList();

  UnorderedLoadedMaterialDto toDto(UnorderedLoadedMaterial entity) {
    return UnorderedLoadedMaterialDto(
      stationId: entity.stationId,
      stationName: entity.stationName,
      materialId: entity.materialId,
      materialName: entity.materialName,
      barcode: entity.barcode,
      quantity: entity.quantity,
    );
  }
}
