import 'package:pharmed_core/pharmed_core.dart';
import 'package:collection/collection.dart';

class MobileFaultMapper {
  const MobileFaultMapper();

  MobileFault toEntity(MobileFaultDto dto) => MobileFault(
    id: dto.id,
    cabinDesignId: dto.cabinDesignId,
    startDate: dto.startDate,
    endDate: dto.endDate,
    description: dto.description,
    workingStatus: CabinWorkingStatus.values.firstWhereOrNull((e) => e.id == dto.workingStatusId),
    createdDate: dto.createdDate,
  );

  MobileFaultDto toDto(MobileFault entity) => MobileFaultDto(
    id: entity.id,
    cabinDesignId: entity.cabinDesignId,
    startDate: entity.startDate,
    endDate: entity.endDate,
    description: entity.description,
    workingStatusId: entity.workingStatus?.id,
    createdDate: entity.createdDate,
  );

  MobileFault? toEntityOrNull(MobileFaultDto? dto) => dto == null ? null : toEntity(dto);
  List<MobileFault> toEntityList(List<MobileFaultDto> dtos) => dtos.map(toEntity).toList();
  MobileFaultDto? toDtoOrNull(MobileFault? entity) => entity == null ? null : toDto(entity);
  List<MobileFaultDto> toDtoList(List<MobileFault> entities) => entities.map(toDto).toList();
}
