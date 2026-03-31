import 'package:pharmed_core/pharmed_core.dart';

class Unit extends Selectable implements TableData {
  final String? name;
  final Status? status;

  Unit({super.id, this.name, this.status}) : super(title: name.toString(), subtitle: status?.label);

  @override
  List<String?> get content => [title, subtitle];

  @override
  List get rawContent => content;

  @override
  List<String?> get titles => ['Adı', 'Durumu'];

  static Unit? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return Unit(id: id, name: name);
  }

  Unit copyWith({int? id, String? name, Status? status}) {
    return Unit(id: id ?? this.id, name: name ?? this.name, status: status ?? this.status);
  }
}
