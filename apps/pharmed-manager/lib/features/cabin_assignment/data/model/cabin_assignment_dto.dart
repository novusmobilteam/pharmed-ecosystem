import '../../../cabin_stock/data/model/cabin_stock_dto.dart';
import '../../../medicine/data/model/medicine_dto.dart';
import '../../domain/entity/cabin_assignment.dart';
import '../../../cabin/data/model/drawer_cell_dto.dart';
import '../../../cabin/data/model/drawer_unit_dto.dart';
import '../../../cabin/data/model/cabin_dto.dart';

/// Eski Adı: CabinDrawerQuantityDTO
class CabinAssignmentDTO {
  final int? id;
  final int? cabinId;
  final int? cabinDrawerId;
  final num? minQuantity;
  final num? criticalQuantity;
  final num? maxQuantity;

  final CabinDTO? cabin;
  final MedicineDTO? medicine;
  final DrawerUnitDTO? cabinDrawer;
  final List<DrawerCellDTO>? cabinDrawerDetail;

  /// Dolum yaparken geliyor sadece bu veri, yeni model açmaktansa burada handle edildi..
  final List<CabinStockDTO>? stocks;

  CabinAssignmentDTO({
    this.id,
    this.cabinId,
    this.cabinDrawerId,
    this.minQuantity,
    this.criticalQuantity,
    this.maxQuantity,
    this.cabin,
    this.medicine,
    this.cabinDrawer,
    this.cabinDrawerDetail,
    this.stocks,
  });

  factory CabinAssignmentDTO.fromJson(Map<String, dynamic> json) {
    return CabinAssignmentDTO(
      id: json['id'] as int?,
      cabinId: json['cabinId'] as int?,
      cabinDrawerId: json['cabinDrawrId'] as int?,
      minQuantity: json['minQuantity'] as int?,
      criticalQuantity: json['criticalQuantity'] as int?,
      maxQuantity: json['maxQuantity'] as int?,
      cabin: json['cabin'] != null ? CabinDTO.fromJson(json['cabin']) : null,
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      cabinDrawer: json['cabinDrawr'] != null ? DrawerUnitDTO.fromJson(json['cabinDrawr']) : null,
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
      'cabinDrawrId': cabinDrawerId,
      'materialId': medicine?.toEntity().id,
      'minQuantity': minQuantity,
      'criticalQuantity': criticalQuantity,
      'maxQuantity': maxQuantity,
    };
  }

  CabinAssignmentDTO copyWith({
    int? id,
    int? cabinDrawerId,
    int? minQuantity,
    int? criticalQuantity,
    int? maxQuantity,
    CabinDTO? cabin,
    MedicineDTO? medicine,
    DrawerUnitDTO? cabinDrawer,
  }) {
    return CabinAssignmentDTO(
      id: id ?? this.id,
      cabinDrawerId: cabinDrawerId ?? this.cabinDrawerId,
      minQuantity: minQuantity ?? this.minQuantity,
      criticalQuantity: criticalQuantity ?? this.criticalQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      cabin: cabin ?? this.cabin,
      medicine: medicine ?? this.medicine,
      cabinDrawer: cabinDrawer ?? this.cabinDrawer,
    );
  }

  CabinAssignment toEntity() {
    return CabinAssignment(
      id: id,
      cabinDrawerId: cabinDrawerId,
      maxQuantity: maxQuantity,
      minQuantity: minQuantity,
      criticalQuantity: criticalQuantity,
      cabin: cabin?.toEntity(),
      medicine: medicine?.toEntity(),
      drawerUnit: cabinDrawer?.toEntity(),
      cabinDrawerDetail: cabinDrawerDetail?.map((c) => c.toEntity()).toList(),
      stocks: stocks?.map((c) => c.toEntity()).toList(),
    );
  }
}
