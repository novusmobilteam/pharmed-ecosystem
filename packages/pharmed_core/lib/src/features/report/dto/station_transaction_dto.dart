class StationTransactionDto {
  final int? id;
  final String? cabinName;
  final int? transactionId;
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

  StationTransactionDto({
    this.id,
    this.cabinName,
    this.transactionId,
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

  factory StationTransactionDto.fromJson(Map<String, dynamic> json) {
    return StationTransactionDto(
      id: json['id'] as int?,
      cabinName: json['cabinName'] as String?,
      transactionId: json['transactionId'] as int?,
      transaction: json['transaction'] as String?,
      code: json['code'] as String?,
      barcode: json['barcode'] as String?,
      material: json['material'] as String?,
      transactionDate: json['transactionDate'] != null ? DateTime.tryParse(json['transactionDate'].toString()) : null,
      quantity: (json['quantity'] as num?)?.toDouble(),
      performedBy: json['userName'] as String?,
      protocolCode: json['protocolCode'] as String?,
      patient: json['patient'] as String?,
      order: json['order'] as int?,
      compartment: json['compartment'] as int?,
      witness: json['witness'] as String?,
      hasSteps: json['hasSteps'] as bool?,
      stationId: json['stationId'] as int?,
      cabinId: json['cabinId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (cabinName != null) 'cabinName': cabinName,
      if (transaction != null) 'transaction': transaction,
      if (code != null) 'code': code,
      if (barcode != null) 'barcode': barcode,
      if (material != null) 'material': material,
      if (transactionDate != null) 'transactionDate': transactionDate!.toIso8601String(),
      if (quantity != null) 'quantity': quantity,
      if (performedBy != null) 'performedBy': performedBy,
      if (protocolCode != null) 'protocolCode': protocolCode,
      if (patient != null) 'patient': patient,
      if (order != null) 'order': order,
      if (compartment != null) 'compartment': compartment,
      if (witness != null) 'witness': witness,
      if (hasSteps != null) 'hasSteps': hasSteps,
      if (stationId != null) 'stationId': stationId,
      if (cabinId != null) 'cabinId': cabinId,
    };
  }
}
