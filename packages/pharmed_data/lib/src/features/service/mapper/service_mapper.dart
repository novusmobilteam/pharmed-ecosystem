import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Service ↔ ServiceDTO dönüşümleri.
class ServiceMapper {
  const ServiceMapper();

  HospitalService toEntity(ServiceDto dto) {
    return HospitalService(
      id: dto.id,
      name: dto.name,
      isActive: dto.isActive,
      branch: BranchMapper().toEntityOrNull(dto.branch),
      user: UserMapper().toEntityOrNull(dto.user),
      rooms: RoomMapper().toEntityList(dto.rooms ?? []),
    );
  }

  HospitalService? toEntityOrNull(ServiceDto? dto) => dto == null ? null : toEntity(dto);

  List<HospitalService> toEntityList(List<ServiceDto> dtos) => dtos.map(toEntity).toList();

  ServiceDto toDto(HospitalService entity) {
    return ServiceDto(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
      branchId: entity.branch?.id,
      userId: entity.user?.id,
      branch: BranchMapper().toDtoOrNull(entity.branch),
      rooms: RoomMapper().toDtoList(entity.rooms),
    );
  }

  ServiceDto? toDtoOrNull(HospitalService? entity) => entity == null ? null : toDto(entity);

  List<ServiceDto> toDtoList(List<HospitalService> entities) => entities.map(toDto).toList();
}
