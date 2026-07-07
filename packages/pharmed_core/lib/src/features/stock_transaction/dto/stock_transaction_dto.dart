import 'package:pharmed_core/pharmed_core.dart';

class StockTransactionDTO {
  final int? id;
  final int? warehouseId;
  final WarehouseDTO? warehouse;
  final int? medicineId;
  final MedicineDto? medicine;
  final int? materialType;
  final int? prescriptionDetailId;
  final int? transactionKind;
  final num? quantity;
  final num? beforeQuantity;
  final int? userId;
  final UserDto? user;
  final bool? isSend;
  final int? transactionType;
  final int? sendServiceId;
  final ServiceDto? sendService;
  final DateTime? sendDate;
  final DateTime? expirationDate;

  const StockTransactionDTO({
    this.id,
    this.warehouseId,
    this.warehouse,
    this.medicineId,
    this.medicine,
    this.materialType,
    this.prescriptionDetailId,
    this.transactionKind,
    this.quantity,
    this.beforeQuantity,
    this.userId,
    this.user,
    this.isSend,
    this.sendDate,
    this.transactionType,
    this.expirationDate,
    this.sendServiceId,
    this.sendService,
  });

  factory StockTransactionDTO.fromJson(Map<String, dynamic> json) {
    return StockTransactionDTO(
      id: json['id'],
      warehouseId: json['warehouseId'],
      warehouse: json['warehouse'] != null ? WarehouseDTO.fromJson(json['warehouse']) : null,
      medicineId: json['materialId'],
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
      materialType: json['materialType'],
      prescriptionDetailId: json['prescriptionDetailId'],
      transactionKind: json['transactionKind'],
      quantity: json['quantity'] as num?,
      beforeQuantity: json['beforeQuantity'] as num?,
      userId: json['userId'],
      isSend: json['isSend'],
      sendDate: json['sendDate'] != null ? DateTime.tryParse(json['sendDate']) : null,
      expirationDate: json['miadDate'] != null ? DateTime.tryParse(json['miadDate']) : null,
      transactionType: json['transactionType'],
      sendServiceId: json['sendServiceId'],
      sendService: json['sendService'] != null ? ServiceDto.fromJson(json['sendService']) : null,
      user: json['user'] != null ? UserDto.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouseId': warehouseId,
      'materialId': medicineId,
      'materialType': materialType,
      'prescriptionDetailId': prescriptionDetailId,
      'transactionKind': transactionKind,
      'quantity': quantity,
      'userId': userId,
      'isSend': isSend,
      'sendDate': sendDate?.toIso8601String(),
      'transactionType': transactionType,
      'expirationDate': expirationDate?.toIso8601String(),
      'sendServiceId': sendServiceId,
    };
  }
}
