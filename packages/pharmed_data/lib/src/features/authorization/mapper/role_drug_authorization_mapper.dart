import 'package:pharmed_core/pharmed_core.dart';
import 'package:collection/collection.dart';

class RoleDrugAuthorizationMapper {
  const RoleDrugAuthorizationMapper();

  RoleDrugAuthorization toEntity(RoleDrugAuthorizationDto dto, {Role? role, Medicine? medicine}) {
    final ops = <DrugOp>{};
    if (dto.isDrugPull) ops.add(DrugOp.pull);
    if (dto.isFill) ops.add(DrugOp.fill);
    if (dto.isReturn) ops.add(DrugOp.returnOp);
    if (dto.isDestruction) ops.add(DrugOp.dispose);

    return RoleDrugAuthorization(id: dto.id, role: role, medicine: medicine, originalOps: ops, pendingOps: {...ops});
  }

  RoleDrugAuthorizationDto toDto(RoleDrugAuthorization entity) {
    return RoleDrugAuthorizationDto(
      id: entity.id,
      roleId: entity.role?.id,
      drugId: entity.medicine?.id,
      isDrugPull: entity.pendingOps.contains(DrugOp.pull),
      isFill: entity.pendingOps.contains(DrugOp.fill),
      isReturn: entity.pendingOps.contains(DrugOp.returnOp),
      isDestruction: entity.pendingOps.contains(DrugOp.dispose),
    );
  }

  List<RoleDrugAuthorization> toEntityList(
    List<RoleDrugAuthorizationDto> dtos, {
    Role? role,
    List<Medicine>? medicines,
  }) {
    return dtos.map((dto) {
      final medicine = medicines?.firstWhereOrNull((m) => m.id == dto.drugId);
      return toEntity(dto, role: role, medicine: medicine);
    }).toList();
  }
}
