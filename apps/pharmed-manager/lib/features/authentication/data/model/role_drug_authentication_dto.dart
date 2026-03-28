import '../../../../core/core.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../../role/domain/entity/role.dart';
import '../../domain/entity/role_drug_authentication.dart';

class RoleDrugAuthenticationDTO {
  final int? id;
  final int? roleId;
  final int? drugId;
  final bool isDrugPull;
  final bool isFill;
  final bool isReturn;
  final bool isDestruction;

  RoleDrugAuthenticationDTO({
    this.id,
    this.roleId,
    this.isDrugPull = false,
    this.isFill = false,
    this.isReturn = false,
    this.isDestruction = false,
    this.drugId,
  });

  RoleDrugAuthenticationDTO copyWith({
    int? id,
    int? roleId,
    bool? isDrugPull,
    bool? isFill,
    bool? isReturn,
    bool? isDestruction,
    int? drugId,
  }) {
    return RoleDrugAuthenticationDTO(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      isDrugPull: isDrugPull ?? this.isDrugPull,
      isFill: isFill ?? this.isFill,
      isReturn: isReturn ?? this.isReturn,
      isDestruction: isDestruction ?? this.isDestruction,
      drugId: drugId ?? this.drugId,
    );
  }

  factory RoleDrugAuthenticationDTO.fromJson(Map<String, dynamic> json) {
    return RoleDrugAuthenticationDTO(
      id: json['id'] as int?,
      roleId: json['roleId'] as int?,
      isDrugPull: json['isDrugPull'] as bool? ?? false,
      isFill: json['isFill'] as bool? ?? false,
      isReturn: json['isReturn'] as bool? ?? false,
      isDestruction: json['isDestruction'] as bool? ?? false,
      drugId: json['materialId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'isDrugPull': isDrugPull,
      'isFill': isFill,
      'isReturn': isReturn,
      'isDestruction': isDestruction,
      'materialId': drugId,
    };
  }

  RoleDrugAuthentication toEntity() {
    final ops = <DrugOp>{};
    if (isDrugPull == true) ops.add(DrugOp.pull);
    if (isFill == true) ops.add(DrugOp.fill);
    if (isReturn == true) ops.add(DrugOp.returnOp);
    if (isDestruction == true) ops.add(DrugOp.dispose);

    return RoleDrugAuthentication(
      id: id,
      role: Role.fromIdAndName(id: roleId),
      medicine: Drug.fromIdAndName(id: drugId),
      originalOps: ops,
      pendingOps: ops,
    );
  }

  /// Mock factory for test data generation
  static RoleDrugAuthenticationDTO mockFactory(int id) {
    return RoleDrugAuthenticationDTO(
      id: id,
      roleId: ((id - 1) % 6) + 1,
      drugId: ((id - 1) % 20) + 1,
      isDrugPull: true,
      isFill: id % 2 == 0,
      isReturn: id % 3 == 0,
      isDestruction: id % 4 == 0,
    );
  }
}
