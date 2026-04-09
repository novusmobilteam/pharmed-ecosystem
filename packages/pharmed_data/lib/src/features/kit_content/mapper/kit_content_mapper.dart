import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class KitContentMapper {
  const KitContentMapper();

  KitContent toEntity(KitContentDto dto) {
    return KitContent(
      id: dto.id,
      kitId: dto.kitId,
      // MedicineDTO'yu Medicine Entity'sine çeviriyoruz
      medicine: dto.medicine != null ? MedicineMapper().toEntity(dto.medicine!) : null,
      piece: dto.piece,
    );
  }

  KitContentDto toDto(KitContent entity) {
    return KitContentDto(
      id: entity.id,
      kitId: entity.kitId,
      medicine: entity.medicine != null ? MedicineMapper().toDto(entity.medicine!) : null,
      piece: entity.piece,
      materialId: entity.medicine?.id,
    );
  }

  KitContent? toEntityOrNull(KitContentDto? dto) => dto == null ? null : toEntity(dto);

  List<KitContent> toEntityList(List<KitContentDto> dtos) => dtos.map(toEntity).toList();

  KitContentDto? toDtoOrNull(KitContent? entity) => entity == null ? null : toDto(entity);

  List<KitContentDto> toDtoList(List<KitContent> entities) => entities.map(toDto).toList();
}
