import '../../../../core/core.dart';
import '../../data/model/branch_dto.dart';

class Branch extends Selectable implements TableData {
  final String? name;
  final bool isActive;

  Branch({super.id, this.name, this.isActive = true})
    : super(title: name?.isNotEmpty == true ? name! : 'İsimsiz', subtitle: statusFromBool(isActive).label);

  Status get status => statusFromBool(isActive);

  @override
  List<String?> get content => [title, subtitle];

  @override
  List<String?> get titles => ['Branş Adı', 'Durum'];

  @override
  List get rawContent => content;

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

  BranchDTO toDTO() {
    return BranchDTO(id: id, name: name, isActive: isActive);
  }

  @override
  String toString() {
    return 'Branch(id: $id, name: $name, isActive: $isActive)';
  }
}
