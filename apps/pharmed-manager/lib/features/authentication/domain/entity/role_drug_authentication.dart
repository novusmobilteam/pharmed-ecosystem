import '../../../../core/core.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../data/model/role_drug_authentication_dto.dart';

class RoleDrugAuthentication implements TableData {
  final int? id;
  final Role? role;
  final Medicine? medicine;

  /// Orijinal hücreler (backend’ten gelen)
  final Set<DrugOp> originalOps;

  /// Pending hücreler (UI’da geçici değişiklikler)
  final Set<DrugOp> pendingOps;

  const RoleDrugAuthentication({this.id, this.role, this.medicine, Set<DrugOp>? originalOps, Set<DrugOp>? pendingOps})
    : originalOps = originalOps ?? const <DrugOp>{},
      pendingOps = pendingOps ?? const <DrugOp>{};

  bool get isDirty => originalOps.length != pendingOps.length || !originalOps.containsAll(pendingOps);

  RoleDrugAuthentication toggle(DrugOp op) {
    final n = {...pendingOps};
    if (n.contains(op)) {
      n.remove(op);
    } else {
      n.add(op);
    }
    return copyWith(pendingOps: n);
  }

  RoleDrugAuthentication resetPending() => copyWith(pendingOps: {...originalOps});

  RoleDrugAuthentication commit() => copyWith(originalOps: {...pendingOps});

  RoleDrugAuthentication copyWith({
    int? id,
    Role? role,
    Medicine? medicine,
    Set<DrugOp>? originalOps,
    Set<DrugOp>? pendingOps,
  }) {
    return RoleDrugAuthentication(
      id: id ?? this.id,
      role: role ?? this.role,
      medicine: medicine ?? this.medicine,
      originalOps: originalOps ?? this.originalOps,
      pendingOps: pendingOps ?? this.pendingOps,
    );
  }

  RoleDrugAuthenticationDTO toDTO() {
    return RoleDrugAuthenticationDTO(
      id: id,
      roleId: role?.id,
      drugId: medicine?.id,
      isDrugPull: pendingOps.contains(DrugOp.pull),
      isFill: pendingOps.contains(DrugOp.fill),
      isReturn: pendingOps.contains(DrugOp.returnOp),
      isDestruction: pendingOps.contains(DrugOp.dispose),
    );
  }

  @override
  List<dynamic> get content => [medicine, role];

  @override
  List<dynamic> get rawContent => [medicine, role];

  @override
  List<String?> get titles => ['İlaç', 'Rol'];
}
