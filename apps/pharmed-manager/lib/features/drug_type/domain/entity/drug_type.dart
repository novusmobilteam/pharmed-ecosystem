import '../../../../core/core.dart';
import '../../data/model/drug_type_dto.dart';

/// Entity: Uygulama içinde kullanılacak sınıf
class DrugType extends Selectable implements TableData {
  final String? name;
  final bool isActive;

  DrugType({
    super.id,
    this.name,
    this.isActive = true,
  }) : super(
          title: name.toString(),
          subtitle: statusFromBool(isActive).label,
        );

  @override
  List<String?> get content => [title, subtitle];

  @override
  List<String?> get titles => ['İlaç Tipi', 'Durumu'];

  @override
  List get rawContent => content;

  Status get status => statusFromBool(isActive);

  static DrugType? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return DrugType(
      id: id,
      name: name,
    );
  }

  DrugType copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return DrugType(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Entity → DTO
  DrugTypeDTO toDto() {
    return DrugTypeDTO(
      id: id,
      name: name,
      isActive: isActive,
    );
  }
}
