import 'package:pharmed_core/pharmed_core.dart';

class DrugType extends Selectable {
  final String? name;
  final bool isActive;

  DrugType({super.id, this.name, this.isActive = true})
    : super(title: name.toString(), subtitle: statusFromBool(isActive).label);

  Status get status => statusFromBool(isActive);

  static DrugType? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return DrugType(id: id, name: name);
  }

  DrugType copyWith({int? id, String? name, bool? isActive}) {
    return DrugType(id: id ?? this.id, name: name ?? this.name, isActive: isActive ?? this.isActive);
  }
}
