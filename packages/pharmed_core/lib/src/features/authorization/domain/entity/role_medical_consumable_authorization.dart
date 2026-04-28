import 'package:pharmed_core/pharmed_core.dart';

class RoleMedicalConsumableAuthorization {
  final int? id;
  final int? roleId;
  final Set<DrugOp> ops;

  RoleMedicalConsumableAuthorization({this.id, this.roleId, Set<DrugOp>? ops}) : ops = ops ?? const <DrugOp>{};

  bool hasOp(DrugOp op) => ops.contains(op);

  RoleMedicalConsumableAuthorization toggle(DrugOp op) {
    final updated = {...ops};
    if (updated.contains(op)) {
      updated.remove(op);
    } else {
      updated.add(op);
    }
    return copyWith(ops: updated);
  }

  RoleMedicalConsumableAuthorization copyWith({int? id, int? roleId, Set<DrugOp>? ops}) {
    return RoleMedicalConsumableAuthorization(id: id ?? this.id, roleId: roleId ?? this.roleId, ops: ops ?? this.ops);
  }
}
