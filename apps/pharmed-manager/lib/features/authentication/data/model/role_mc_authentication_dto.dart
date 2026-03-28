import '../../../../core/core.dart';
import '../../domain/entity/role_medical_consumable_authentication.dart';

class RoleMedicalConsumableAuthenticationDTO {
  final int? id;
  final int? roleId;
  final bool isMedicalConsumablesPull;
  final bool isMedicalConsumablesFill;
  final bool isMedicalConsumablesReturn;
  final bool isMedicalConsumablesDestruction;

  RoleMedicalConsumableAuthenticationDTO({
    this.id,
    this.roleId,
    this.isMedicalConsumablesPull = false,
    this.isMedicalConsumablesFill = false,
    this.isMedicalConsumablesReturn = false,
    this.isMedicalConsumablesDestruction = false,
  });

  RoleMedicalConsumableAuthenticationDTO copyWith({
    int? id,
    int? roleId,
    bool? isMedicalConsumablesPull,
    bool? isMedicalConsumablesFill,
    bool? isMedicalConsumablesReturn,
    bool? isMedicalConsumablesDestruction,
  }) {
    return RoleMedicalConsumableAuthenticationDTO(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      isMedicalConsumablesPull: isMedicalConsumablesPull ?? this.isMedicalConsumablesPull,
      isMedicalConsumablesFill: isMedicalConsumablesFill ?? this.isMedicalConsumablesFill,
      isMedicalConsumablesReturn: isMedicalConsumablesReturn ?? this.isMedicalConsumablesReturn,
      isMedicalConsumablesDestruction: isMedicalConsumablesDestruction ?? this.isMedicalConsumablesDestruction,
    );
  }

  factory RoleMedicalConsumableAuthenticationDTO.fromJson(Map<String, dynamic> json) {
    return RoleMedicalConsumableAuthenticationDTO(
      id: json['id'] as int?,
      roleId: json['roleId'] as int?,
      isMedicalConsumablesPull: json['isMedicalConsumablesPull'] as bool? ?? false,
      isMedicalConsumablesFill: json['isMedicalConsumablesFill'] as bool? ?? false,
      isMedicalConsumablesReturn: json['isMedicalConsumablesReturn'] as bool? ?? false,
      isMedicalConsumablesDestruction: json['isMedicalConsumablesDestruction'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'isMedicalConsumablesPull': isMedicalConsumablesPull,
      'isMedicalConsumablesFill': isMedicalConsumablesFill,
      'isMedicalConsumablesReturn': isMedicalConsumablesReturn,
      'isMedicalConsumablesDestruction': isMedicalConsumablesDestruction,
    };
  }

  RoleMedicalConsumableAuthentication toEntity() {
    final ops = <DrugOp>{};
    if (isMedicalConsumablesPull) ops.add(DrugOp.pull);
    if (isMedicalConsumablesFill) ops.add(DrugOp.fill);
    if (isMedicalConsumablesReturn) ops.add(DrugOp.returnOp);
    if (isMedicalConsumablesDestruction) ops.add(DrugOp.dispose);

    return RoleMedicalConsumableAuthentication(
      id: id,
      roleId: roleId,
      ops: ops,
    );
  }

  /// Mock factory for test data generation
  static RoleMedicalConsumableAuthenticationDTO mockFactory(int id) {
    return RoleMedicalConsumableAuthenticationDTO(
      id: id,
      roleId: ((id - 1) % 6) + 1,
      isMedicalConsumablesPull: true,
      isMedicalConsumablesFill: id % 2 == 0,
      isMedicalConsumablesReturn: id % 3 == 0,
      isMedicalConsumablesDestruction: id % 4 == 0,
    );
  }
}
