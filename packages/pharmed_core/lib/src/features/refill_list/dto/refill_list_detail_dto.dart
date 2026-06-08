import 'package:pharmed_manager/core/core.dart';

// Dolum listesi oluşturulduktan sonra oluşturulan dolum listesinin detayı
// görüntülenmek istendiğinde kullanılan model.
class RefillListDetailDto {
  final int? id;
  final int? fillingListId;
  final int? medicineId;
  final MedicineDto? medicine;
  final DrawerUnitDTO? cabinDrawer;
  final MedicineAssignmentDto? cabinAssignment;
  final num? quantity;
  final num? fillingQuantity;
  final DateTime? fillingDate;
  final int? fillingUserId;
  final UserDto? fillingUser;
  final bool? isEdit;
  final List<DrawerCellDTO>? cabinDrawerDetail;
  final List<CabinStockDTO>? stocks;

  RefillListDetailDto({
    this.id,
    this.fillingListId,
    this.medicineId,
    this.medicine,
    this.cabinDrawer,
    this.cabinAssignment,
    this.quantity,
    this.fillingQuantity,
    this.fillingDate,
    this.fillingUserId,
    this.fillingUser,
    this.isEdit,
    this.cabinDrawerDetail,
    this.stocks,
  });

  factory RefillListDetailDto.fromJson(Map<String, dynamic> json) {
    return RefillListDetailDto(
      id: json['id'] as int?,
      fillingListId: json['fiilingListId'] as int?,
      medicineId: json['materialId'] as int?,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
      cabinDrawer: json['cabinDrawr'] != null ? DrawerUnitDTO.fromJson(json['cabinDrawr']) : null,
      cabinAssignment: json['cabinDrawrQuantity'] != null
          ? MedicineAssignmentDto.fromJson(json['cabinDrawrQuantity'])
          : null,
      quantity: json['quantity'] as num?,
      fillingQuantity: json['fiilingQuantity'] as num?,
      fillingDate: json['fiilingDate'] != null ? DateTime.parse(json['fiilingDate'] as String) : null,
      fillingUserId: json['fiilingUserId'] as int?,
      fillingUser: json['fillingUser'] != null ? UserDto.fromJson(json['fillingUser']) : null,
      isEdit: json['isEdit'] as bool?,
      cabinDrawerDetail: json['cabinDrawrDetail'] != null
          ? (json['cabinDrawrDetail'] as List).map((e) => DrawerCellDTO.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      stocks: json['cabinDrawrStock'] != null
          ? (json['cabinDrawrStock'] as List).map((e) => CabinStockDTO.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fiilingListId': fillingListId,
      'materialId': medicineId,
      //'material': medicine?.toJson(),
      'cabinDrawr': cabinDrawer?.toJson(),
      'cabinDrawrQuantity': cabinAssignment?.toJson(),
      'quantity': quantity,
      'fiilingQuantity': fillingQuantity,
      'fiilingDate': fillingDate?.toIso8601String(),
      'fiilingUserId': fillingUserId,
      'fillingUser': fillingUser?.toJson(),
      'isEdit': isEdit,
    };
  }

  RefillListDetailDto copyWith({
    int? id,
    int? fillingListId,
    int? medicineId,
    MedicineDto? medicine,
    int? quantity,
    int? fillingQuantity,
    DateTime? fillingDate,
    int? fillingUserId,
    String? fillingUser,
    bool? isEdit,
  }) {
    return RefillListDetailDto(
      id: id ?? this.id,
      fillingListId: fillingListId ?? this.fillingListId,
      medicine: medicine ?? this.medicine,
      medicineId: medicineId ?? this.medicineId,
      quantity: quantity ?? this.quantity,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
    );
  }
}
