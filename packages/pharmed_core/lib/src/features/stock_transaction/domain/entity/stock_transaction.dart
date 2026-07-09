import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class StockTransaction implements TableData {
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
    this.beforeQuantity,
    this.userId,
    this.user,
    this.isSend,
    this.sendDate,
    this.transactionType,
    this.expirationDate,
    this.medicine,
    this.service,
  });

  @override
  List get content => [
    sendDate?.formattedDate,
    medicine?.name.toString(),
    medicine?.barcode,
    transactionKind?.label,
    '${quantity?.formatFractional} ${medicine?.operationUnit}',
    '${beforeQuantity?.formatFractional} ${medicine?.operationUnit}',
    user?.fullName,
  ];

  @override
  List<String?> get titles => [
    contextlessL10n().tableCore_stockTransactionDateColumn,
    contextlessL10n().tableCore_materialColumn,
    contextlessL10n().tableCore_stockTransactionBarcodeColumn,
    contextlessL10n().tableCore_stockTransactionTypeColumn,
    contextlessL10n().tableCore_stockTransactionQuantityColumn,
    contextlessL10n().tableCore_stockTransactionPreviousQuantityColumn,
    contextlessL10n().tableCore_stockTransactionActorColumn,
  ];

  @override
  List get rawContent => [
    sendDate?.formattedDate,
    medicine?.name.toString(),
    medicine?.barcode,
    transactionKind?.label,
    '${quantity?.formatFractional} ${medicine?.operationUnit}',
    '${beforeQuantity?.formatFractional} ${medicine?.operationUnit}',
    user?.fullName,
  ];

  StockTransaction copyWith({
    int? id,
    int? warehouseId,
    int? materialType,
    int? prescriptionDetailId,
    double? quantity,
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
