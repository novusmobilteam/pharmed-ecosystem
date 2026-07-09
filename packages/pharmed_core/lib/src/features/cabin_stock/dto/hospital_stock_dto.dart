class HospitalStockDto {
  final int? serviceId;
  final String? serviceName;
  final int? materialId;
  final String? materialName;
  final String? code;
  final num? quantity;

  HospitalStockDto({this.serviceId, this.serviceName, this.materialId, this.materialName, this.code, this.quantity});

  factory HospitalStockDto.fromJson(Map<String, dynamic> json) {
    return HospitalStockDto(
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      materialId: json['materialId'],
      materialName: json['materialName'],
      code: json['materialCode'],
      quantity: json['quantity'],
    );
  }
}
