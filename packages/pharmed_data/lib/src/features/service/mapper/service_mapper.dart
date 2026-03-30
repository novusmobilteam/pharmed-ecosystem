import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/features/branch/branch.dart';
import 'package:pharmed_data/src/features/user/mapper/user_mapper.dart';

/// Service ↔ ServiceDTO dönüşümleri.
class ServiceMapper {
  const ServiceMapper();

  HospitalService toEntity(ServiceDTO dto) {
    return HospitalService(
      id: dto.id,
      name: dto.name,
      isActive: dto.isActive,
      branch: BranchMapper().toEntityOrNull(dto.branch),
      user: UserMapper().toEntityOrNull(dto.user),
    );
  }

  HospitalService? toEntityOrNull(ServiceDTO? dto) => dto == null ? null : toEntity(dto);

  List<HospitalService> toEntityList(List<ServiceDTO> dtos) => dtos.map(toEntity).toList();

  ServiceDTO toDto(HospitalService entity) {
    return ServiceDTO(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
      branch: BranchMapper().toDtoOrNull(entity.branch),
    );
  }

  ServiceDTO? toDtoOrNull(HospitalService? entity) => entity == null ? null : toDto(entity);

  List<ServiceDTO> toDtoList(List<HospitalService> entities) => entities.map(toDto).toList();
}
