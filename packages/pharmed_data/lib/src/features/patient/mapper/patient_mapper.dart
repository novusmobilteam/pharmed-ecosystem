import 'package:pharmed_core/pharmed_core.dart';

/// Patient ↔ PatientDTO dönüşümleri.
class PatientMapper {
  const PatientMapper();

  Patient toEntity(PatientDto dto) {
    return Patient(
      id: dto.id,
      tcNo: dto.tcNo,
      // DTO'daki 'weigh' (weight) alanı Entity'e eşleniyor
      weight: dto.weight,
      name: dto.name,
      surname: dto.surname,
      // DTO'daki 'birtDate' (birthDate) alanı Entity'e eşleniyor
      birthDate: dto.birthDate,
      // Enum/Id dönüşümü
      gender: Gender.fromId(dto.genderType),
      motherName: dto.motherName,
      fatherName: dto.fatherName,
      phone: dto.phone,
      address: dto.address,
      description: dto.description,
      protocolNo: dto.protocolNo,
    );
  }

  PatientDto toDto(Patient entity) {
    return PatientDto(
      id: entity.id,
      tcNo: entity.tcNo,
      weight: entity.weight,
      name: entity.name,
      surname: entity.surname,
      birthDate: entity.birthDate,
      genderType: entity.gender?.id,
      motherName: entity.motherName,
      fatherName: entity.fatherName,
      phone: entity.phone,
      address: entity.address,
      description: entity.description,
      protocolNo: entity.protocolNo,
    );
  }

  List<Patient> toEntityList(List<PatientDto> dtos) => dtos.map(toEntity).toList();

  List<PatientDto> toDtoList(List<Patient> entities) => entities.map(toDto).toList();

  Patient? toEntityOrNull(PatientDto? dto) => dto == null ? null : toEntity(dto);

  PatientDto? toDtoOrNull(Patient? entity) => entity == null ? null : toDto(entity);
}
