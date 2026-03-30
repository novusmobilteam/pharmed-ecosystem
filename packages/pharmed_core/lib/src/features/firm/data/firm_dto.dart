class FirmDTO {
  final int? id;
  final String? name;
  final String? taxOffice;
  final int? taxNo;
  final int? firmTypeId;

  const FirmDTO({this.id, this.name, this.taxOffice, this.taxNo, this.firmTypeId});

  factory FirmDTO.fromJson(Map<String, dynamic> json) {
    return FirmDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      taxOffice: json['taxOffice'] as String?,
      taxNo: json['taxNo'] as int?,
      firmTypeId: json['firmTypeId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'taxOffice': taxOffice,
    'taxNo': taxNo,
    'firmTypeId': firmTypeId,
  };

  FirmDTO copyWith({int? id, String? name, String? taxOffice, int? taxNo, int? firmTypeId}) {
    return FirmDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      taxOffice: taxOffice ?? this.taxOffice,
      taxNo: taxNo ?? this.taxNo,
      firmTypeId: firmTypeId ?? this.firmTypeId,
    );
  }
}
