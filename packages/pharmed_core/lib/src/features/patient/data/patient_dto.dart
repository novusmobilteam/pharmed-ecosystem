class PatientDto {
  final int? id;
  final String? tcNo;
  final int? weight;
  final String? name;
  final String? surname;
  final DateTime? birthDate;
  final int? genderType;
  final String? motherName;
  final String? fatherName;
  final String? phone;
  final String? address;
  final String? description;
  final String? protocolNo;

  const PatientDto({
    this.id,
    this.tcNo,
    this.weight,
    this.name,
    this.surname,
    this.birthDate,
    this.genderType,
    this.motherName,
    this.fatherName,
    this.phone,
    this.address,
    this.description,
    this.protocolNo,
  });

  factory PatientDto.fromJson(Map<String, dynamic> json) {
    return PatientDto(
      id: json['id'] as int?,
      tcNo: json['tcNo']?.toString(),
      weight: json['weigh'] as int?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      birthDate: json['birtDate'] != null ? DateTime.tryParse(json['birtDate']) : null,
      genderType: json['genderType'] as int?,
      motherName: json['motherName'] as String?,
      fatherName: json['fatherName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      description: json['description'] as String?,
      protocolNo: json['protocolNo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tcNo': tcNo,
    'weigh': weight,
    'name': name,
    'surname': surname,
    'birtDate': birthDate?.toIso8601String(),
    'genderType': genderType,
    'motherName': motherName,
    'fatherName': fatherName,
    'phone': phone,
    'address': address,
    'description': description,
    'protocolNo': protocolNo,
  };

  PatientDto copyWith({
    int? id,
    String? tcNo,
    int? weight,
    String? name,
    String? surname,
    DateTime? birthDate,
    int? genderType,
    String? motherName,
    String? fatherName,
    String? phone,
    bool? isBaby,
    String? address,
    String? description,
    String? protocolNo,
  }) {
    return PatientDto(
      id: id ?? this.id,
      tcNo: tcNo ?? this.tcNo,
      weight: weight ?? this.weight,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthDate: birthDate ?? this.birthDate,
      genderType: genderType ?? this.genderType,
      motherName: motherName ?? this.motherName,
      fatherName: fatherName ?? this.fatherName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      protocolNo: protocolNo ?? this.protocolNo,
    );
  }
}
