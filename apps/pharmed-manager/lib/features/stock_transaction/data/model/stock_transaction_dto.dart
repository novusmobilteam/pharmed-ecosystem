import '../../../../core/core.dart';
import '../../../service/data/model/service_dto.dart';
import '../../../warehouse/data/model/warehouse_dto.dart';
import '../../../medicine/data/model/medicine_dto.dart';
import '../../../user/user.dart';
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
      service: sendService?.toEntity(),
      warehouse: warehouse?.toEntity(),
      user: user?.toEntity(),
      transactionKind: StockTransactionKind.fromId(transactionKind),
      transactionType: StockTransactionType.fromId(transactionType),
    );
  }

  /// Mock factory for test data generation
  static StockTransactionDTO mockFactory(int id, {bool withNested = true}) {
    final warehouseId = ((id - 1) % 5) + 1;
    final materialId = ((id - 1) % 20) + 1;
    final userId = ((id - 1) % 10) + 1;
    final serviceId = ((id - 1) % 10) + 1;
    final date = DateTime.now().subtract(Duration(days: id % 30));

    return StockTransactionDTO(
      id: id,
      warehouseId: warehouseId,
      warehouse: withNested ? WarehouseDTO.mockFactory(warehouseId) : null,
      medicineId: materialId,
      materialType: 1,
      prescriptionDetailId: null,
      transactionKind: 1,
      quantity: (id * 5) % 50 + 1,
      userId: userId,
      user: withNested ? UserDTO.mockFactory(userId) : null,
      isSend: true,
      sendDate: date,
      transactionType: 1,
      expirationDate: date.add(Duration(days: 365)),
      sendServiceId: serviceId,
      sendService: withNested ? ServiceDTO.mockFactory(serviceId, withNested: false) : null,
    );
  }
}
