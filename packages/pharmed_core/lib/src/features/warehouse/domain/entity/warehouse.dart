import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class Warehouse extends Selectable {
  final int? code;
  final String? name;
  final User? user;
  final WarehouseType? type;
  final bool isActive;

  Warehouse({super.id, this.code, this.name, this.user, this.type, this.isActive = true})
    : super(title: name ?? '', subtitle: type?.label);

  Status get status => isActive ? Status.active : Status.passive;

  // Update metodları
  Warehouse updateCode(int? code) {
    return copyWith(code: code);
  }

  Warehouse updateName(String? newName) {
    return copyWith(name: newName);
  }

  Warehouse updateStatus(Status? newStatus) {
    return copyWith(isActive: newStatus?.isActive ?? true);
  }

  Warehouse toggleStatus() {
    return copyWith(isActive: !isActive);
  }

  Warehouse updateType(WarehouseType? type) {
    return copyWith(type: type);
  }

  Warehouse updateUser(User? user) {
    return copyWith(user: user);
  }

  // Validasyon metodları
  bool get isValid => name?.trim().isNotEmpty == true;
  String? get nameError {
    if (name == null || name!.trim().isEmpty) return contextlessL10n().dataGuard_warehouseNameRequired;
    return null;
  }

  Warehouse copyWith({int? id, int? code, String? name, User? user, bool? isActive, WarehouseType? type}) {
    return Warehouse(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      user: user ?? this.user,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
    );
  }
}
