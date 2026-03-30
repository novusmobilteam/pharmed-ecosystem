import 'package:pharmed_core/pharmed_core.dart';

/// Branch ↔ BranchDTO dönüşümleri.
class BranchMapper {
  const BranchMapper();

  Branch toEntity(BranchDTO dto) {
    return Branch(id: dto.id, name: dto.name, isActive: dto.isActive);
  }

  Branch? toEntityOrNull(BranchDTO? dto) => dto == null ? null : toEntity(dto);

  List<Branch> toEntityList(List<BranchDTO> dtos) => dtos.map(toEntity).toList();

  BranchDTO toDto(Branch entity) {
    return BranchDTO(id: entity.id, name: entity.name, isActive: entity.isActive);
  }

  BranchDTO? toDtoOrNull(Branch? entity) => entity == null ? null : toDto(entity);
}
