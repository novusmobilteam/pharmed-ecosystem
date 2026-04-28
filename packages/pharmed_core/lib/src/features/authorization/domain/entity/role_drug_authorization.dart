import 'package:pharmed_core/pharmed_core.dart';

class RoleDrugAuthorization implements TableData {
  final int? id;
  final Role? role;
  final Medicine? medicine;

  /// Orijinal hücreler (backend’ten gelen)
  final Set<DrugOp> originalOps;

  /// Pending hücreler (UI’da geçici değişiklikler)
  final Set<DrugOp> pendingOps;

  const RoleDrugAuthorization({this.id, this.role, this.medicine, Set<DrugOp>? originalOps, Set<DrugOp>? pendingOps})
    : originalOps = originalOps ?? const <DrugOp>{},
      pendingOps = pendingOps ?? const <DrugOp>{};

  bool get isDirty => originalOps.length != pendingOps.length || !originalOps.containsAll(pendingOps);

  RoleDrugAuthorization toggle(DrugOp op) {
    final n = {...pendingOps};
    if (n.contains(op)) {
      n.remove(op);
    } else {
      n.add(op);
    }
    return copyWith(pendingOps: n);
  }

  RoleDrugAuthorization resetPending() => copyWith(pendingOps: {...originalOps});

  RoleDrugAuthorization commit() => copyWith(originalOps: {...pendingOps});

  RoleDrugAuthorization copyWith({
    int? id,
    Role? role,
    Medicine? medicine,
    Set<DrugOp>? originalOps,
    Set<DrugOp>? pendingOps,
  }) {
    return RoleDrugAuthorization(
      id: id ?? this.id,
      role: role ?? this.role,
      medicine: medicine ?? this.medicine,
      originalOps: originalOps ?? this.originalOps,
      pendingOps: pendingOps ?? this.pendingOps,
    );
  }

  @override
  List<dynamic> get content => [medicine, role];

  @override
  List<dynamic> get rawContent => [medicine, role];

  @override
  List<String?> get titles => ['İlaç', 'Rol'];
}
