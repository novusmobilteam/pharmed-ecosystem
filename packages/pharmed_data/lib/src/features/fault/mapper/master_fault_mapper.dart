import 'package:pharmed_core/pharmed_core.dart';
import 'package:collection/collection.dart';

class MasterFaultMapper {
  /// DTO -> Entity Dönüşümü
  MasterFault toEntity(MasterFaultDto dto) {
    return MasterFault(
      id: dto.id,
      slotId: dto.cabinDrawrId,
      startDate: dto.startDate,
      endDate: dto.endDate,
      description: dto.description,
      // Enum eşlemesi (id veya index hangisini kullanıyorsan ona göre güncelle)
      workingStatus: CabinWorkingStatus.values.firstWhereOrNull((e) => e.id == dto.workingStatusId),
      createdDate: dto.createdDate,
    );
  }

  /// Entity -> DTO Dönüşümü
  MasterFaultDto toDto(MasterFault entity) {
    return MasterFaultDto(
      id: entity.id,
      cabinDrawrId: entity.slotId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      description: entity.description,
      workingStatusId: entity.workingStatus?.id,
      createdDate: entity.createdDate,
    );
  }

  MasterFault? toEntityOrNull(MasterFaultDto? dto) => dto == null ? null : toEntity(dto);

  List<MasterFault> toEntityList(List<MasterFaultDto> dtos) => dtos.map(toEntity).toList();

  MasterFaultDto? toDtoOrNull(MasterFault? entity) => entity == null ? null : toDto(entity);

  List<MasterFaultDto> toDtoList(List<MasterFault> entities) => entities.map(toDto).toList();
}
