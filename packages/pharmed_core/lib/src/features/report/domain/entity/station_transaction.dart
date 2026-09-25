import 'package:pharmed_core/pharmed_core.dart';

class StationTransaction {
  final int? id;
  final String? cabinName;
  final StationTransactionType? transactionType;
  final String? transaction;
  final String? code;
  final String? barcode;
  final String? material;
  final DateTime? transactionDate;
  final double? quantity;
  final String? performedBy;
  final String? protocolCode;
  final String? patient;
  final int? order;
  final int? compartment;
  final String? witness;
  final bool? hasSteps;
  final int? stationId;
  final int? cabinId;

  StationTransaction({
    this.id,
    this.transactionType,
    this.cabinName,
    this.transaction,
    this.code,
    this.barcode,
    this.material,
    this.transactionDate,
    this.quantity,
    this.performedBy,
    this.protocolCode,
    this.patient,
    this.order,
    this.compartment,
    this.witness,
    this.hasSteps,
    this.stationId,
    this.cabinId,
  });
}
