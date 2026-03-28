import '../../../../core/core.dart';
import '../../data/model/material_type_dto.dart';

class MaterialType extends Selectable implements TableData {
  final String? name;
  final bool isActive;

  MaterialType({super.id, this.name, this.isActive = true})
    : super(title: name.toString(), subtitle: statusFromBool(isActive).label);

  Status get status => statusFromBool(isActive);

  @override
  List<String?> get content => [title, subtitle];
  @override
  List<String?> get rawContent => [title, subtitle];

  @override
  List<String?> get titles => ['Malzeme Tipi', 'Durumu'];

  static MaterialType? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return MaterialType(id: id, name: name);
  }

  MaterialType copyWith({int? id, String? name, bool? isActive}) {
    return MaterialType(id: id ?? this.id, name: name ?? this.name, isActive: isActive ?? this.isActive);
  }

  MaterialTypeDTO toDTO() {
    return MaterialTypeDTO(id: id, name: name, isActive: isActive);
  }
}
