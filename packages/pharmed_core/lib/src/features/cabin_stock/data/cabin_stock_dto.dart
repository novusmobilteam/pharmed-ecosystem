import 'package:pharmed_core/pharmed_core.dart';

class CabinStockDTO {
  final int? id;
  final int? cabinId;
  final int? cabinDrawerId;
  final int? cabinDrawerDetailId;
  final int? corpartmentNo;
  final int? shelfNo;
  final num? quantity;
  final DateTime? miadDate;
  final MedicineDTO? medicine;
  final MedicineAssignmentDto? cabinDrawerQuantity;
  final DrawerCellDTO? cabinDrawerDetail;

  CabinStockDTO({
    this.id,
    this.cabinId,
    this.cabinDrawerId,
    this.cabinDrawerDetailId,
    this.corpartmentNo,
    this.shelfNo,
    this.quantity,
    this.miadDate,
    this.medicine,
    this.cabinDrawerQuantity,
    this.cabinDrawerDetail,
  });

  factory CabinStockDTO.fromJson(Map<String, dynamic> json) {
    return CabinStockDTO(
      id: json['id'],
      cabinId: json['cabinId'],
      cabinDrawerId: json['cabinDrawrId'],
      cabinDrawerDetailId: json['cabinDrawrDetailId'],
      corpartmentNo: json['corpartmentNo'],
      quantity: json['quantity'],
      shelfNo: json['shelfNo'],
      miadDate: json['miadDate'] != null ? DateTime.tryParse(json['miadDate']) : null,
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      cabinDrawerQuantity: json['cabinDrawrQuantity'] != null
          ? MedicineAssignmentDto.fromJson(json['cabinDrawrQuantity'])
          : null,
      cabinDrawerDetail: json['cabinDrawrDetail'] != null ? DrawerCellDTO.fromJson(json['cabinDrawrDetail']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cabinDrawrDetailId": cabinDrawerDetailId,
      "materialId": medicine?.toEntity().id,
      "quantity": quantity,
      "miadDate": miadDate,
      "shelfNo": shelfNo,
      "corpartmentNo": corpartmentNo,
    };
  }

  CabinStockDTO copyWith({
    int? id,
    int? cabinId,
    int? cabinDrawerId,
    int? corpartmentNo,
    int? shelfNo,
    double? quantity,
    DateTime? miadDate,
    MedicineDTO? medicine,
    MedicineAssignmentDto? cabinDrawerQuantity,
    DrawerCellDTO? cabinDrawerDetail,
  }) {
    return CabinStockDTO(
      id: id ?? this.id,
      cabinId: cabinId ?? this.cabinId,
      cabinDrawerId: cabinDrawerId ?? this.cabinDrawerId,
      corpartmentNo: corpartmentNo ?? this.corpartmentNo,
      miadDate: miadDate ?? this.miadDate,
      quantity: quantity ?? this.quantity,
      shelfNo: shelfNo ?? this.shelfNo,
      medicine: medicine ?? this.medicine,
      cabinDrawerQuantity: cabinDrawerQuantity ?? this.cabinDrawerQuantity,
      cabinDrawerDetail: cabinDrawerDetail ?? this.cabinDrawerDetail,
    );
  }
}
