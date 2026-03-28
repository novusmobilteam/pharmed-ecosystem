import '../../../cabin/data/model/drawer_cell_dto.dart';
import '../../../cabin_stock/data/model/cabin_stock_dto.dart';
import '../../../user/user.dart';
import '../../domain/entity/filling_detail.dart';
import '../../../cabin/data/model/drawer_unit_dto.dart';
import '../../../cabin_assignment/data/model/cabin_assignment_dto.dart';
import '../../../medicine/data/model/medicine_dto.dart';

// Dolum listesi oluşturulduktan sonra oluşturulan dolum listesinin detayı
// görüntülenmek istendiğinde kullanılan model.
class FillingDetailDTO {
  final int? id;
  final int? fillingListId;
  final int? medicineId;
  final MedicineDTO? medicine;
  final DrawerUnitDTO? cabinDrawer;
  final CabinAssignmentDTO? cabinAssignment;
  final num? quantity;
  final num? fillingQuantity;
  final DateTime? fillingDate;
  final int? fillingUserId;
  final UserDTO? fillingUser;
  final bool? isEdit;
  final List<DrawerCellDTO>? cabinDrawerDetail;
  final List<CabinStockDTO>? stocks;

  FillingDetailDTO({
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

  factory FillingDetailDTO.fromJson(Map<String, dynamic> json) {
    return FillingDetailDTO(
      id: json['id'] as int?,
      fillingListId: json['fiilingListId'] as int?,
      medicineId: json['materialId'] as int?,
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      cabinDrawer: json['cabinDrawr'] != null ? DrawerUnitDTO.fromJson(json['cabinDrawr']) : null,
      cabinAssignment:
          json['cabinDrawrQuantity'] != null ? CabinAssignmentDTO.fromJson(json['cabinDrawrQuantity']) : null,
      quantity: json['quantity'] as num?,
      fillingQuantity: json['fiilingQuantity'] as num?,
      fillingDate: json['fiilingDate'] != null ? DateTime.parse(json['fiilingDate'] as String) : null,
      fillingUserId: json['fiilingUserId'] as int?,
      fillingUser: json['fillingUser'] != null ? UserDTO.fromJson(json['fillingUser']) : null,
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
      'material': medicine?.toJson(),
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

  FillingDetail toEntity() {
    return FillingDetail(
      id: id,
      fillingListId: fillingListId,
      medicineId: medicineId,
      medicine: medicine?.toEntity(),
      cabinDrawer: cabinDrawer?.toEntity(),
      cabinAssignment: cabinAssignment?.toEntity(),
      quantity: quantity,
      fillingQuantity: fillingQuantity,
      fillingDate: fillingDate,
      fillingUserId: fillingUserId,
      fillingUser: fillingUser?.toEntity(),
      isEdit: isEdit,
      cabinDrawerDetail: cabinDrawerDetail?.map((c) => c.toEntity()).toList(),
      stocks: stocks?.map((c) => c.toEntity()).toList(),
    );
  }

  FillingDetailDTO copyWith({
    int? id,
    int? fillingListId,
    int? medicineId,
    MedicineDTO? medicine,
    int? quantity,
    int? fillingQuantity,
    DateTime? fillingDate,
    int? fillingUserId,
    String? fillingUser,
    bool? isEdit,
  }) {
    return FillingDetailDTO(
      id: id ?? this.id,
      fillingListId: fillingListId ?? this.fillingListId,
      medicine: medicine ?? this.medicine,
      medicineId: medicineId ?? this.medicineId,
      quantity: quantity ?? this.quantity,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
    );
  }

  /// Mock factory for test data generation
  static FillingDetailDTO mockFactory(int id, {bool withNested = true}) {
    final fillingListId = ((id - 1) ~/ 10) + 1;
    final materialId = ((id - 1) % 20) + 1;
    final drawerId = ((id - 1) % 50) + 1;
    final userId = ((id - 1) % 10) + 1;
    final date = DateTime.now().subtract(Duration(hours: id));

    return FillingDetailDTO(
      id: id,
      fillingListId: fillingListId,
      medicineId: materialId,
      cabinDrawer: withNested ? DrawerUnitDTO.mockFactory(drawerId, withNested: false) : null,
      cabinAssignment: withNested ? CabinAssignmentDTO.mockFactory(id, withNested: false) : null,
      quantity: (id * 5) % 50,
      fillingQuantity: (id * 5) % 50,
      fillingDate: date,
      fillingUserId: userId,
      fillingUser: withNested ? UserDTO.mockFactory(userId) : null,
      isEdit: false,
    );
  }
}
