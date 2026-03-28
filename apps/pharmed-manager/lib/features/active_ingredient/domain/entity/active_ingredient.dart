import '../../../../core/core.dart';
import '../../data/model/active_ingredient_dto.dart';

class ActiveIngredient extends Selectable implements TableData {
  final String? name;
  final bool isActive;

  ActiveIngredient({super.id, this.name, this.isActive = true})
    : super(title: name?.isNotEmpty == true ? name! : 'İsimsiz', subtitle: statusFromBool(isActive).label);

  Status get status => statusFromBool(isActive);

  @override
  List<String?> get content => [title, subtitle];

  @override
  List<String?> get titles => ['Adı', 'Durumu'];

  @override
  List get rawContent => [title, subtitle];

  // Update metodları
  ActiveIngredient updateName(String? newName) {
    return copyWith(name: newName);
  }

  ActiveIngredient updateStatus(Status? newStatus) {
    return copyWith(isActive: newStatus?.isActive ?? true);
  }

  ActiveIngredient toggleStatus() {
    return copyWith(isActive: !isActive);
  }

  ActiveIngredient updateFromDTO(ActiveIngredientDTO dto) {
    return copyWith(id: dto.id, name: dto.name, isActive: dto.isActive);
  }

  // Validasyon metodları
  bool get isValid => name?.trim().isNotEmpty == true;
  String? get nameError {
    if (name == null || name!.trim().isEmpty) return 'İsim alanı zorunludur';
    return null;
  }

  ActiveIngredient copyWith({int? id, String? name, bool? isActive}) {
    return ActiveIngredient(id: id ?? this.id, name: name ?? this.name, isActive: isActive ?? this.isActive);
  }

  ActiveIngredientDTO toDTO() {
    return ActiveIngredientDTO(id: id, name: name, isActive: isActive);
  }

  // Factory metodlar
  static ActiveIngredient? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return ActiveIngredient(id: id, name: name);
  }

  @override
  String toString() {
    return 'ActiveIngredient(id: $id, name: $name, isActive: $isActive)';
  }
}
