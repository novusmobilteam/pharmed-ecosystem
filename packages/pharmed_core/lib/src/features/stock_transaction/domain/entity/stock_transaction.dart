import 'package:pharmed_core/pharmed_core.dart';

class StockTransaction {
  final int? id;
  final int? warehouseId;
  final Warehouse? warehouse;
  final int? materialType;
  final int? prescriptionDetailId;
  final num? quantity;
  final num? beforeQuantity;
  final int? userId;
  final User? user;
  final bool? isSend;
  final DateTime? sendDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final Medicine? medicine;
  final HospitalService? service;
  final StockTransactionType? transactionType;
  final StockTransactionKind? transactionKind;

  const StockTransaction({
    this.id,
    this.warehouseId,
    this.warehouse,
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
    this.startDate,
    this.endDate,
    this.medicine,
    this.service,
  });

  StockTransaction copyWith({
    int? id,
    int? warehouseId,
    int? materialType,
    int? prescriptionDetailId,
    double? quantity,
    int? userId,
    bool? isSend,
    DateTime? startDate,
    DateTime? endDate,
    Medicine? medicine,
    HospitalService? service,
    StockTransactionType? transactionType,
    StockTransactionKind? transactionKind,
  }) {
    return StockTransaction(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      materialType: materialType ?? this.materialType,
      prescriptionDetailId: prescriptionDetailId ?? this.prescriptionDetailId,
      quantity: quantity ?? this.quantity,
      userId: userId ?? this.userId,
      isSend: isSend ?? this.isSend,
      sendDate: sendDate ?? this.sendDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      medicine: medicine ?? this.medicine,
      service: service ?? this.service,
      transactionKind: transactionKind ?? this.transactionKind,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}
