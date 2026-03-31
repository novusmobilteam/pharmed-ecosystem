import 'package:pharmed_core/pharmed_core.dart';

import '../../data/dto/cabin_fault_dto.dart';
import '../model/cabin_fault.dart';

/// CabinFault ↔ CabinFaultDTO dönüşümleri.
class CabinFaultMapper {
  const CabinFaultMapper();

  CabinFault toEntity(CabinFaultDTO dto) {
    return CabinFault(
      id: dto.id,
      // DTO'daki cabinDrawrId -> Entity'deki slotId'ye eşleniyor.
      slotId: dto.cabinDrawrId,
      startDate: dto.startDate,
      endDate: dto.endDate,
      description: dto.description,
      // Statik factory metodu (fromId) kullanarak dönüşüm yapılıyor.
      workingStatus: CabinWorkingStatus.fromId(dto.workingStatusId),
      createdDate: dto.createdDate,
    );
  }

  CabinFaultDTO toDto(CabinFault entity) {
    return CabinFaultDTO(
      id: entity.id,
      // Entity'deki slotId -> DTO'daki cabinDrawrId'ye eşleniyor.
      cabinDrawrId: entity.slotId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      description: entity.description,
      workingStatusId: entity.workingStatus?.id,
      createdDate: entity.createdDate,
    );
  }

  List<CabinFault> toEntityList(List<CabinFaultDTO> dtos) => dtos.map(toEntity).toList();

  List<CabinFaultDTO> toDtoList(List<CabinFault> entities) => entities.map(toDto).toList();

  CabinFault? toEntityOrNull(CabinFaultDTO? dto) => dto == null ? null : toEntity(dto);

  CabinFaultDTO? toDtoOrNull(CabinFault? entity) => entity == null ? null : toDto(entity);
}
