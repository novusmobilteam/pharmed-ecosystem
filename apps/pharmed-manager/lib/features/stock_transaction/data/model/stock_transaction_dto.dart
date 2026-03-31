import '../../../../core/core.dart';

import '../../domain/entity/stock_transaction.dart';

class StockTransactionDTO {
  final int? id;
  final int? warehouseId;
  final WarehouseDTO? warehouse;
  final int? medicineId;
  final MedicineDTO? medicine;
  final int? materialType;
  final int? prescriptionDetailId;
  final int? transactionKind;
  final int? quantity;
  final int? userId;
  final UserDTO? user;
  final bool? isSend;
  final int? transactionType;
  final int? sendServiceId;
  final ServiceDTO? sendService;
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
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      materialType: json['materialType'],
      prescriptionDetailId: json['prescriptionDetailId'],
      transactionKind: json['transactionKind'],
      quantity: json['quantity'],
      userId: json['userId'],
      isSend: json['isSend'],
      sendDate: json['sendDate'] != null ? DateTime.tryParse(json['sendDate']) : null,
      expirationDate: json['miadDate'] != null ? DateTime.tryParse(json['miadDate']) : null,
      transactionType: json['transactionType'],
      sendServiceId: json['sendServiceId'],
      sendService: json['sendService'] != null ? ServiceDTO.fromJson(json['sendService']) : null,
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

  StockTransaction toEntity() {
    return StockTransaction(
      id: id,
      warehouseId: warehouseId,
      materialType: materialType,
      prescriptionDetailId: prescriptionDetailId,
      quantity: quantity,
      userId: userId,
      isSend: isSend,
      sendDate: sendDate,
      expirationDate: expirationDate,
      medicine: medicine?.toEntity(),
      service: ServiceMapper().toEntityOrNull(sendService),
      warehouse: WarehouseMapper().toEntityOrNull(warehouse),
      user: const UserMapper().toEntityOrNull(user),
      transactionKind: StockTransactionKind.fromId(transactionKind),
      transactionType: StockTransactionType.fromId(transactionType),
    );
  }
}
