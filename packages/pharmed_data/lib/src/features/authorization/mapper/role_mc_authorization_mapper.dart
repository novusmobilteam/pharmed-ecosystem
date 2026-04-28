import 'package:pharmed_core/pharmed_core.dart';

class RoleMedicalConsumableAuthorizationMapper {
  const RoleMedicalConsumableAuthorizationMapper();

  RoleMedicalConsumableAuthorization toEntity(RoleMedicalConsumableAuthorizationDto dto) {
    final ops = <DrugOp>{};
    if (dto.isMedicalConsumablesPull) ops.add(DrugOp.pull);
    if (dto.isMedicalConsumablesFill) ops.add(DrugOp.fill);
    if (dto.isMedicalConsumablesReturn) ops.add(DrugOp.returnOp);
    if (dto.isMedicalConsumablesDestruction) ops.add(DrugOp.dispose);

    return RoleMedicalConsumableAuthorization(id: dto.id, roleId: dto.roleId, ops: ops);
  }

  RoleMedicalConsumableAuthorizationDto toDto(RoleMedicalConsumableAuthorization entity) {
    return RoleMedicalConsumableAuthorizationDto(
      id: entity.id,
      roleId: entity.roleId,
      isMedicalConsumablesPull: entity.ops.contains(DrugOp.pull),
      isMedicalConsumablesFill: entity.ops.contains(DrugOp.fill),
      isMedicalConsumablesReturn: entity.ops.contains(DrugOp.returnOp),
      isMedicalConsumablesDestruction: entity.ops.contains(DrugOp.dispose),
    );
  }
}
