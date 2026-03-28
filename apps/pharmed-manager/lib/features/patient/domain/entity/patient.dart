import '../../../../core/core.dart';
import '../../data/model/patient_dto.dart';

class Patient extends Selectable implements TableData {
  final String? tcNo;
  final int? weight;
  final String? name;
  final String? surname;
  final DateTime? birthDate;
  final Gender? gender;
  final String? motherName;
  final String? fatherName;
  final String? phone;

  final String? address;
  final String? description;
  final String? protocolNo;

  Patient({
    super.id,
    this.tcNo,
    this.weight,
    this.name,
    this.surname,
    this.birthDate,
    this.gender,
    this.motherName,
    this.fatherName,
    this.phone,
    this.address,
    this.description,
    this.protocolNo,
  }) : super(
          title: '${name ?? '-'} ${surname ?? ''}'.trim(),
          subtitle: tcNo,
        );

  String get fullName => '${name ?? '-'} ${surname ?? ''}'.trim();

  bool isChanged(Patient other) {
    return name != other.name ||
        surname != other.surname ||
        tcNo != other.tcNo ||
        birthDate != other.birthDate ||
        gender != other.gender ||
        phone != other.phone ||
        address != other.address ||
        description != other.description;
  }

  static Patient? fromIdAndName({
    int? id,
    String? name,
    String? tcNo,
    String? protocolNo,
  }) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return Patient(
      id: id,
      name: name,
      tcNo: tcNo,
      protocolNo: protocolNo,
    );
  }

  // TableData
  @override
  List<String?> get titles => const [
        'T.C NO',
        'Ad',
        'Soyad',
        'Cinsiyet',
        'Protokol No',
      ];

  @override
  List<String?> get content => [
        tcNo?.toString() ?? '-',
        name ?? '-',
        surname ?? '-',
        gender?.label ?? '-',
        protocolNo ?? '-',
      ];

  @override
  List get rawContent => content;

  Patient copyWith({
    int? id,
    String? tcNo,
    int? weight,
    String? name,
    String? surname,
    DateTime? birthDate,
    Gender? gender,
    String? motherName,
    String? fatherName,
    String? phone,
    bool? isBaby,
    String? address,
    String? description,
    String? protocolNo,
  }) {
    return Patient(
      id: id ?? this.id,
      tcNo: tcNo ?? this.tcNo,
      weight: weight ?? this.weight,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      motherName: motherName ?? this.motherName,
      fatherName: fatherName ?? this.fatherName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      protocolNo: protocolNo ?? this.protocolNo,
    );
  }

  PatientDTO toDTO() => PatientDTO(
        id: id,
        tcNo: tcNo,
        weight: weight,
        name: name,
        surname: surname,
        birthDate: birthDate,
        genderType: gender?.id,
        motherName: motherName,
        fatherName: fatherName,
        phone: phone,
        address: address,
        description: description,
        protocolNo: protocolNo,
      );
}
