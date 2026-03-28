import '../../../../core/core.dart';
import '../../data/model/kit_dto.dart';

class Kit implements TableData {
  final int? id;
  final String? name;
  final String? normalizedName;
  final bool? isActive;

  Kit({this.id, this.name, this.normalizedName, this.isActive});

  Status get status => (isActive ?? false) ? Status.active : Status.passive;

  @override
  List<String> get content => [name.toString(), status.label];

  @override
  List<String> get rawContent => content;

  @override
  List<String> get titles => ['Kit Adı', 'Durum'];

  KitDTO toDto() => KitDTO(id: id, name: name, normalizedName: normalizedName, isActive: isActive);

  Kit copyWith({int? id, String? name, String? normalizedName, bool? isActive}) {
    return Kit(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      isActive: isActive ?? this.isActive,
    );
  }
}
