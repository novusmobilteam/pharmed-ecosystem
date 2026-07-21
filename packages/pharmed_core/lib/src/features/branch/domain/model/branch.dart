import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class Branch extends Selectable {
  final String? name;
  final bool isActive;

  Branch({super.id, this.name, this.isActive = true})
    : super(
        title: name?.isNotEmpty == true ? name! : contextlessL10n().common_unknownName,
        subtitle: statusFromBool(isActive).label,
      );

  Status get status => statusFromBool(isActive);

  // Update metodları
  Branch updateName(String? newName) {
    return copyWith(name: newName);
  }

  Branch updateStatus(Status? newStatus) {
    return copyWith(isActive: newStatus?.isActive ?? true);
  }

  Branch toggleStatus() {
    return copyWith(isActive: !isActive);
  }

  // Validasyon metodları
  bool get isValid => name?.trim().isNotEmpty == true;
  String? get nameError {
    if (name == null || name!.trim().isEmpty) return 'Branş adı zorunludur';
    return null;
  }

  Branch copyWith({int? id, String? name, bool? isActive}) {
    return Branch(id: id ?? this.id, name: name ?? this.name, isActive: isActive ?? this.isActive);
  }

  @override
  String toString() {
    return 'Branch(id: $id, name: $name, isActive: $isActive)';
  }
}
