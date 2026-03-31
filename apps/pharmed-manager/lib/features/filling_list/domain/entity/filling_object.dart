import '../../../../core/core.dart';

class FillingObject extends TableData {
  // Birden fazla göz kaydını taşımak için liste
  // Detay modunda: her eleman bir FillingDetail.id
  // Create modunda: tek elemanlı veya boş
  final List<int>? detailIds;

  final Medicine? medicine;
  final CabinAssignment? assignment;
  final num quantity;
  final bool canEdit;
  final List<CabinStock>? stocks;

  FillingObject({
    this.detailIds,
    this.medicine,
    this.assignment,
    required this.quantity,
    this.canEdit = true,
    this.stocks,
  });

  FillingObject copyWith({
    List<int>? detailIds,
    num? quantity,
    bool? canEdit,
    CabinAssignment? assignment,
    List<CabinStock>? stocks,
  }) {
    return FillingObject(
      detailIds: detailIds ?? this.detailIds,
      medicine: medicine,
      assignment: assignment ?? this.assignment,
      quantity: quantity ?? this.quantity,
      canEdit: canEdit ?? this.canEdit,
      stocks: stocks ?? this.stocks,
    );
  }

  @override
  List<dynamic> get content => [medicine?.name, medicine?.barcode];

  @override
  List<dynamic> get rawContent => [medicine?.name, medicine?.barcode];

  @override
  List<String?> get titles => ['İlaç Adı', 'İlaç Barkodu'];
}

extension FillingObjectAdapter on FillingObject {
  CabinAssignment? toCabinAssignment() {
    if (assignment == null) return null;

    return assignment!.copyWith(medicine: medicine, fillingQuantity: quantity, stocks: stocks);
  }
}

extension FillingObjectListAdapter on List<FillingObject> {
  List<CabinAssignment> toCabinAssignments() {
    return where((o) => o.assignment != null).map((o) => o.toCabinAssignment()!).toList();
  }
}
