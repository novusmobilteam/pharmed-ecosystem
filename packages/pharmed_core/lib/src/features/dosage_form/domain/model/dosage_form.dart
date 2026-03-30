import 'package:pharmed_core/pharmed_core.dart';

class DosageForm extends Selectable implements TableData {
  final String? name;
  final bool isActive;

  DosageForm({super.id, this.name, this.isActive = true})
    : super(title: name?.isNotEmpty == true ? name! : 'İsimsiz', subtitle: statusFromBool(isActive).label);

  Status get status => statusFromBool(isActive);

  @override
  List<String?> get content => [title, subtitle];

  @override
  List<String?> get titles => ['Branş Adı', 'Durum'];

  @override
  List get rawContent => content;

  DosageForm updateName(String? newName) {
    return copyWith(name: newName);
  }

  DosageForm updateStatus(Status? newStatus) {
    return copyWith(isActive: newStatus?.isActive ?? true);
  }

  DosageForm toggleStatus() {
    return copyWith(isActive: !isActive);
  }

  // Validasyon metodları
  bool get isValid => name?.trim().isNotEmpty == true;
  String? get nameError {
    if (name == null || name!.trim().isEmpty) return 'Branş adı zorunludur';
    return null;
  }

  DosageForm copyWith({int? id, String? name, bool? isActive}) {
    return DosageForm(id: id ?? this.id, name: name ?? this.name, isActive: isActive ?? this.isActive);
  }

  @override
  String toString() {
    return 'DosageForm(id: $id, name: $name, isActive: $isActive)';
  }
}
