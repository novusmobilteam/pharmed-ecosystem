import '../../domain/entity/inconsistency.dart';
import '../../../cabin/data/model/drawer_cell_dto.dart';
import '../../../medicine/data/model/medicine_dto.dart';

class InconsistencyDTO {
  final int? id;
  final DrawerCellDTO? cabinDrawerDetail;
  final MedicineDTO? medicine;
  final num? quantity;
  final num? stockEntryQuantity;
  final num? stockExitQuantity;
  final num? requiredQuantity;
  final DateTime? miadDate;
  final int? shelfNo;
  final int? corpartmentNo;
  final List<String>? activeIngredients;

  InconsistencyDTO({
    this.id,
    this.cabinDrawerDetail,
    this.medicine,
    this.quantity,
    this.stockEntryQuantity,
    this.stockExitQuantity,
    this.requiredQuantity,
    this.miadDate,
    this.shelfNo,
    this.corpartmentNo,
    this.activeIngredients,
  });

  factory InconsistencyDTO.fromJson(Map<String, dynamic> json) {
    return InconsistencyDTO(
      id: json['id'] as int?,
      cabinDrawerDetail: json['cabinDrawrDetail'] != null ? DrawerCellDTO.fromJson(json['cabinDrawrDetail']) : null,
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      quantity: json['quantity'],
      stockEntryQuantity: json['stockEntryQuantity'],
      stockExitQuantity: json['stockExitQuantity'],
      requiredQuantity: json['requiredQuantity'],
      miadDate: json['miadDate'] != null ? DateTime.parse(json['miadDate'] as String) : null,
      shelfNo: json['shelfNo'] as int?,
      corpartmentNo: json['corpartmentNo'] as int?,
      activeIngredients: (json['activeIngredients'] as List?)?.map((j) => j as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cabinDrawerDetail': cabinDrawerDetail,
      'material': medicine?.toEntity(),
      'stockEntryQuantity': stockEntryQuantity,
      'stockExitQuantity': stockExitQuantity,
      'requiredQuantity': requiredQuantity,
    };
  }

  InconsistencyDTO copyWith({
    int? id,
    int? stationId,
    String? station,
    List<int>? cabinIds,
    List<String>? cabins,
  }) {
    return InconsistencyDTO(
      id: id ?? this.id,
    );
  }

  Inconsistency toEntity() {
    return Inconsistency(
      id: id,
      cabinDrawerDetail: cabinDrawerDetail?.toEntity(),
      medicine: medicine?.toEntity(),
      quantity: quantity,
      stockEntryQuantity: stockEntryQuantity,
      stockExitQuantity: stockExitQuantity,
      requiredQuantity: requiredQuantity,
      miadDate: miadDate,
      shelfNo: shelfNo,
      corpartmentNo: corpartmentNo,
      activeIngredients: activeIngredients,
    );
  }

  /// Mock factory for test data generation
  static InconsistencyDTO mockFactory(int id, {bool withNested = true}) {
    final drawerDetailId = ((id - 1) % 50) + 1;
    final miadDate = DateTime.now().add(Duration(days: 365 + (id * 10)));

    return InconsistencyDTO(
      id: id,
      cabinDrawerDetail: withNested ? DrawerCellDTO.mockFactory(drawerDetailId, withNested: false) : null,
      quantity: (id * 7) % 20,
      stockEntryQuantity: 100,
      stockExitQuantity: 80,
      requiredQuantity: 20,
      miadDate: miadDate,
      shelfNo: ((id - 1) % 5) + 1,
      corpartmentNo: ((id - 1) % 10) + 1,
      activeIngredients: ['Etken Madde 1', 'Etken Madde 2'],
    );
  }
}
