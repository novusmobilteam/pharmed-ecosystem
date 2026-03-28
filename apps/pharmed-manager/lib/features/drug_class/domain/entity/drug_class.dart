import '../../../../core/core.dart';
import '../../data/model/drug_class_dto.dart';

class DrugClass extends Selectable implements TableData {
  final String? name;
  final bool isActive;

  DrugClass({
    super.id,
    this.name,
    this.isActive = true,
  }) : super(
          title: name.toString(),
          subtitle: statusFromBool(isActive).label,
        );

  Status get status => statusFromBool(isActive);

  @override
  List<String?> get content => [title, subtitle];

  @override
  List<String?> get titles => ['İlaç Sınıfı', 'Durumu'];

  @override
  List get rawContent => content;

  static DrugClass? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return DrugClass(
      id: id,
      name: name,
    );
  }

  factory DrugClass.fromDTO(DrugClassDTO dto) {
    return DrugClass(
      id: dto.id,
      name: dto.name,
      isActive: dto.isActive ?? true,
    );
  }

  DrugClassDTO toDTO() {
    return DrugClassDTO(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  DrugClass copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return DrugClass(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
