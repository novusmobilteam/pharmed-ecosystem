import 'package:pharmed_core/pharmed_core.dart';

class Firm extends Selectable implements TableData {
  final String? name;
  final String? taxOffice;
  final FirmType? type;
  final int? taxNo;

  Firm({super.id, this.name, this.taxOffice, this.type, this.taxNo})
    : super(title: name.toString(), subtitle: type?.label);

  static Firm? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return Firm(id: id, name: name);
  }

  @override
  List<String?> get content => [id?.toString(), name, type?.label, taxOffice, taxNo?.toString()];

  @override
  List get rawContent => content;

  @override
  List<String> titles = ['Id', 'Adı', 'Firma Tipi', 'Vergi Dairesi', 'Vergi No'];

  Firm copyWith({int? id, String? name, String? taxOffice, int? taxNo, FirmType? type}) {
    return Firm(
      id: id ?? this.id,
      name: name ?? this.name,
      taxOffice: taxOffice ?? this.taxOffice,
      taxNo: taxNo ?? this.taxNo,
      type: type ?? this.type,
    );
  }
}
