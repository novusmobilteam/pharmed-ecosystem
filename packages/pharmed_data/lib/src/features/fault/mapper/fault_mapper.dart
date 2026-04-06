import 'package:pharmed_core/pharmed_core.dart';
import 'package:collection/collection.dart';

class FaultMapper {
  /// DTO -> Entity Dönüşümü
  Fault toEntity(FaultDto dto) {
    return Fault(
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
  FaultDto toDto(Fault entity) {
    return FaultDto(
      id: entity.id,
      cabinDrawrId: entity.slotId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      description: entity.description,
      workingStatusId: entity.workingStatus?.id,
      createdDate: entity.createdDate,
    );
  }

  Fault? toEntityOrNull(FaultDto? dto) => dto == null ? null : toEntity(dto);

  List<Fault> toEntityList(List<FaultDto> dtos) => dtos.map(toEntity).toList();

  FaultDto? toDtoOrNull(Fault? entity) => entity == null ? null : toDto(entity);

  List<FaultDto> toDtoList(List<Fault> entities) => entities.map(toDto).toList();
}
