import '../../../../core/core.dart';
import '../../data/model/role_mc_authentication_dto.dart';

class RoleMedicalConsumableAuthentication {
  final int? id;
  final int? roleId;
  final Set<DrugOp> ops;

  RoleMedicalConsumableAuthentication({
    this.id,
    this.roleId,
    Set<DrugOp>? ops,
  }) : ops = ops ?? const <DrugOp>{};

  bool hasOp(DrugOp op) => ops.contains(op);

  RoleMedicalConsumableAuthentication toggle(DrugOp op) {
    final updated = {...ops};
    if (updated.contains(op)) {
      updated.remove(op);
    } else {
      updated.add(op);
    }
    return copyWith(ops: updated);
  }

  RoleMedicalConsumableAuthentication copyWith({
    int? id,
    int? roleId,
    Set<DrugOp>? ops,
  }) {
    return RoleMedicalConsumableAuthentication(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      ops: ops ?? this.ops,
    );
  }

  RoleMedicalConsumableAuthenticationDTO toDTO() {
    return RoleMedicalConsumableAuthenticationDTO(
      id: id,
      roleId: roleId,
      isMedicalConsumablesPull: ops.contains(DrugOp.pull),
      isMedicalConsumablesFill: ops.contains(DrugOp.fill),
      isMedicalConsumablesReturn: ops.contains(DrugOp.returnOp),
      isMedicalConsumablesDestruction: ops.contains(DrugOp.dispose),
    );
  }

  factory RoleMedicalConsumableAuthentication.fromDTO(RoleMedicalConsumableAuthenticationDTO dto) {
    final ops = <DrugOp>{};
    if (dto.isMedicalConsumablesPull) ops.add(DrugOp.pull);
    if (dto.isMedicalConsumablesFill) ops.add(DrugOp.fill);
    if (dto.isMedicalConsumablesReturn) ops.add(DrugOp.returnOp);
    if (dto.isMedicalConsumablesDestruction) ops.add(DrugOp.dispose);

    return RoleMedicalConsumableAuthentication(
      id: dto.id,
      roleId: dto.roleId,
      ops: ops,
    );
  }
}
