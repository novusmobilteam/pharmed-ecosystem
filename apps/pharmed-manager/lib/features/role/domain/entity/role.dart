import '../../../../core/core.dart';
import '../../data/model/role_dto.dart';

class Role extends Selectable implements TableData {
  final String? name;
  final bool isActive;

  Role({
    super.id,
    this.name,
    this.isActive = true,
  }) : super(
          title: name ?? '-',
          subtitle: statusFromBool(isActive).label,
        );

  Status get status => statusFromBool(isActive);

  @override
  List<String?> get content => [name ?? '-', status.label];

  @override
  List get rawContent => content;

  @override
  List<String?> get titles => const ['Rol Adı', 'Durumu'];

  // Update metodları
  Role updateName(String? newName) {
    return copyWith(name: newName);
  }

  Role updateStatus(Status? newStatus) {
    return copyWith(isActive: newStatus?.isActive ?? true);
  }

  Role toggleStatus() {
    return copyWith(isActive: !isActive);
  }

  // Validasyon metodları
  bool get isValid => name?.trim().isNotEmpty == true;
  String? get nameError {
    if (name == null || name!.trim().isEmpty) return 'Rol adı zorunludur';
    return null;
  }

  static Role? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    //final hasName = name != null && name.trim().isNotEmpty;
    // if (!hasId && !hasName) return null;
    if (!hasId) return null;

    return Role(
      id: id,
      //name: name,
    );
  }

  Role copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  RoleDTO toDTO() => RoleDTO(
        id: id,
        name: name,
        isActive: isActive,
      );
}
