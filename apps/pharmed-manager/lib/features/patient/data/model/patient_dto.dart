import '../../../../core/core.dart';
import '../../domain/entity/patient.dart';

class PatientDTO {
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

  const PatientDTO({
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

  factory PatientDTO.fromJson(Map<String, dynamic> json) {
    return PatientDTO(
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

  Patient toEntity() => Patient(
        id: id,
        tcNo: tcNo,
        weight: weight,
        name: name,
        surname: surname,
        birthDate: birthDate,
        gender: Gender.fromId(genderType),
        motherName: motherName,
        fatherName: fatherName,
        phone: phone,
        address: address,
        description: description,
        protocolNo: protocolNo,
      );

  PatientDTO copyWith({
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
    return PatientDTO(
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

  /// Mock factory for test data generation
  static PatientDTO mockFactory(int id) {
    final firstNames = [
      'Ahmet',
      'Mehmet',
      'Mustafa',
      'Ali',
      'Hüseyin',
      'Hasan',
      'İbrahim',
      'Ömer',
      'Yusuf',
      'Murat',
      'Fatma',
      'Ayşe',
      'Emine',
      'Hatice',
      'Zeynep',
      'Elif',
      'Merve',
      'Özlem',
      'Gamze',
      'Selin',
    ];
    final lastNames = [
      'Yılmaz',
      'Kaya',
      'Demir',
      'Şahin',
      'Çelik',
      'Yıldız',
      'Yıldırım',
      'Öztürk',
      'Aydın',
      'Özdemir',
    ];

    // Generate a realistic TC No (11 digits)
    final tcNo = int.parse('${10000000 + ((id * 123456789) % 90000000)}${100 + (id % 900)}').toString();

    // Generate birth date (between 1950-2000)
    final year = 1950 + ((id * 7) % 50);
    final month = ((id * 3) % 12) + 1;
    final day = ((id * 5) % 28) + 1;

    return PatientDTO(
      id: id,
      tcNo: tcNo,
      weight: 50 + ((id * 11) % 50),
      name: firstNames[(id - 1) % firstNames.length],
      surname: lastNames[(id - 1) % lastNames.length],
      birthDate: DateTime(year, month, day),
      genderType: (id % 2),
      motherName: firstNames[((id + 5) - 1) % firstNames.length],
      fatherName: firstNames[((id + 10) - 1) % firstNames.length],
      phone: (5300000000 + (id * 123456 % 99999999)).toString(),
      address: 'Örnek Mahallesi, No: $id',
      description: null,
      protocolNo: 'P${id.toString().padLeft(6, '0')}',
    );
  }
}
