class OrderedNotLoadedMaterialDto {
  final int? prescriptionDetailId;
  final int? stationId;
  final String? stationName;
  final String? serviceName;
  final int? materialId;
  final String? barcode;
  final String? materialName;
  final DateTime? orderDate;
  final String? protocolNo;
  final double? quantity;
  final String? patientFullName;

  const OrderedNotLoadedMaterialDto({
    this.prescriptionDetailId,
    this.stationId,
    this.stationName,
    this.serviceName,
    this.materialId,
    this.barcode,
    this.materialName,
    this.orderDate,
    this.protocolNo,
    this.quantity,
    this.patientFullName,
  });

  factory OrderedNotLoadedMaterialDto.fromJson(Map<String, dynamic> json) {
    return OrderedNotLoadedMaterialDto(
      prescriptionDetailId: json['prescriptionDetailId'] as int?,
      stationId: json['stationId'] as int?,
      stationName: json['stationName'] as String?,
      serviceName: json['serviceName'] as String?,
      materialId: json['materialId'] as int?,
      barcode: json['barcode'] as String?,
      materialName: json['materialName'] as String?,
      orderDate: json['orderDate'] != null ? DateTime.tryParse(json['orderDate'].toString()) : null,
      protocolNo: json['protocolNo'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      patientFullName: json['patientFullName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (prescriptionDetailId != null) 'prescriptionDetailId': prescriptionDetailId,
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      if (serviceName != null) 'serviceName': serviceName,
      if (materialId != null) 'materialId': materialId,
      if (barcode != null) 'barcode': barcode,
      if (materialName != null) 'materialName': materialName,
      if (orderDate != null) 'orderDate': orderDate!.toIso8601String(),
      if (protocolNo != null) 'protocolNo': protocolNo,
      if (quantity != null) 'quantity': quantity,
      if (patientFullName != null) 'patientFullName': patientFullName,
    };
  }
}
