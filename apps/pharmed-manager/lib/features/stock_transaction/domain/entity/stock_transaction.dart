import '../../../../core/core.dart';
import '../../../service/domain/entity/service.dart';
import '../../../warehouse/domain/entity/warehouse.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../../user/user.dart';
import '../../data/model/stock_transaction_dto.dart';

class StockTransaction implements TableData {
  final int? id;
  final int? warehouseId;
  final Warehouse? warehouse;
  final int? materialType;
  final int? prescriptionDetailId;
  final int? quantity;
  final int? userId;
  final User? user;
  final bool? isSend;
  final DateTime? sendDate;
  final DateTime? expirationDate;
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
    this.userId,
    this.user,
    this.isSend,
    this.sendDate,
    this.transactionType,
    this.expirationDate,
    this.medicine,
    this.service,
  });

  StockTransactionDTO toDTO() {
    return StockTransactionDTO(
      id: id,
      warehouseId: warehouseId,
      medicineId: medicine?.id,
      materialType: medicine?.type,
      prescriptionDetailId: prescriptionDetailId,
      transactionKind: transactionKind?.id,
      quantity: quantity,
      userId: userId,
      isSend: isSend,
      sendDate: sendDate,
      transactionType: transactionType?.id,
      expirationDate: expirationDate,
      sendServiceId: service?.id,
    );
  }

  @override
  List get content => [
        sendDate?.formattedDate,
        medicine?.name.toString(),
        expirationDate?.formattedDate,
        quantity?.toCustomString(),
        service?.name,
      ];

  @override
  List<String?> get titles => [
        'Tarih',
        'Malzeme',
        'Son Kullanma Tarihi',
        'Miktar',
        'Servis',
      ];

  @override
  List get rawContent => [sendDate, medicine?.name.toString(), expirationDate, quantity];

  StockTransaction copyWith({
    int? id,
    int? warehouseId,
    int? materialType,
    int? prescriptionDetailId,
    int? quantity,
    int? userId,
    bool? isSend,
    DateTime? sendDate,
    DateTime? expirationDate,
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
      expirationDate: expirationDate ?? this.expirationDate,
      medicine: medicine ?? this.medicine,
      service: service ?? this.service,
      transactionKind: transactionKind ?? this.transactionKind,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}
