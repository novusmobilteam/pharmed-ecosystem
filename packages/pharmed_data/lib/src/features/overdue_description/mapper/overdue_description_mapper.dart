import 'package:pharmed_core/pharmed_core.dart';

class OverdueDescriptionMapper {
  const OverdueDescriptionMapper();

  OverdueDescription toEntity(OverdueDescriptionDto dto) {
    return OverdueDescription(id: dto.id, description: dto.description ?? '');
  }

  OverdueDescription? toEntityOrNull(OverdueDescriptionDto? dto) => dto == null ? null : toEntity(dto);

  List<OverdueDescription> toEntityList(List<OverdueDescriptionDto> dtos) => dtos.map(toEntity).toList();

  OverdueDescriptionDto toDto(OverdueDescription entity) {
    return OverdueDescriptionDto(id: entity.id, description: entity.description);
  }
}
