import 'package:pharmed_manager/core/core.dart';

class InconsistencyDTO {
  final int? id;
  final int? stationId;
  final DrawerCellDTO? drawerCell;
  final MedicineDto? medicine;
  final num? quantity;
  final num? requiredQuantity;
  final DateTime? miadDate;
  final int? shelfNo;
  final int? corpartmentNo;
  final List<String>? activeIngredients;
  final UserDto? user;
  final bool isSolved;
  final DateTime? createdDate;
  final UserDto? solvedUser;
  final DateTime? solvedDate;
  final String? description;

  InconsistencyDTO({
    this.id,
    this.stationId,
    this.drawerCell,
    this.medicine,
    this.quantity,
    this.requiredQuantity,
    this.miadDate,
    this.shelfNo,
    this.corpartmentNo,
    this.activeIngredients,
    this.user,
    this.isSolved = false,
    this.createdDate,
    this.solvedUser,
    this.solvedDate,
    this.description,
  });

  factory InconsistencyDTO.fromJson(Map<String, dynamic> json) {
    return InconsistencyDTO(
      id: json['id'] as int?,
      stationId: json['stationId'] as int?,
      drawerCell: json['cabinDrawrDetail'] != null ? DrawerCellDTO.fromJson(json['cabinDrawrDetail']) : null,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
      quantity: json['quantity'],
      requiredQuantity: json['requiredQuantity'],
      miadDate: json['miadDate'] != null ? DateTime.parse(json['miadDate'] as String) : null,
      shelfNo: json['shelfNo'] as int?,
      corpartmentNo: json['corpartmentNo'] as int?,
      activeIngredients: (json['activeIngredients'] as List?)?.map((j) => j as String).toList(),
      user: json['user'] != null ? UserDto.fromJson(json['user']) : null,
      isSolved: json['isSolved'] as bool,
      createdDate: json['createDate'] != null ? DateTime.parse(json['createDate'] as String) : null,
      solvedUser: json['solvedUser'] != null ? UserDto.fromJson(json['solvedUser']) : null,
      description: json['solveDescription'] as String?,
      solvedDate: json['solvedDate'] != null ? DateTime.parse(json['solvedDate'] as String) : null,
    );
  }
}
