import 'package:pharmed_core/pharmed_core.dart';

class RefillObject {
  // Birden fazla göz kaydını taşımak için liste
  // Detay modunda: her eleman bir FillingDetail.id
  // Create modunda: tek elemanlı veya boş
  final List<int>? detailIds;

  final Medicine? medicine;
  final MedicineAssignment? assignment;
  final num quantity;
  final bool canEdit;
  final List<CabinStock>? stocks;

  RefillObject({
    this.detailIds,
    this.medicine,
    this.assignment,
    required this.quantity,
    this.canEdit = true,
    this.stocks,
  });

  RefillObject copyWith({
    List<int>? detailIds,
    num? quantity,
    bool? canEdit,
    MedicineAssignment? assignment,
    List<CabinStock>? stocks,
  }) {
    return RefillObject(
      detailIds: detailIds ?? this.detailIds,
      medicine: medicine,
      assignment: assignment ?? this.assignment,
      quantity: quantity ?? this.quantity,
      canEdit: canEdit ?? this.canEdit,
      stocks: stocks ?? this.stocks,
    );
  }
}
