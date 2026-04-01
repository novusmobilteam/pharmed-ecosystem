import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// MyPatient ↔ MyPatientDTO dönüşümleri.
class MyPatientMapper {
  const MyPatientMapper();

  MyPatient toEntity(MyPatientDTO dto) {
    return MyPatient(
      id: dto.id,
      userId: dto.userId,
      // User ve Hospitalization için ilgili mapper'ları kullanıyoruz
      user: const UserMapper().toEntityOrNull(dto.user),
      hospitalization: const HospitalizationMapper().toEntityOrNull(dto.hospitalization),
    );
  }

  MyPatientDTO toDto(MyPatient entity) {
    return MyPatientDTO(
      id: entity.id,
      userId: entity.userId,
      user: const UserMapper().toDtoOrNull(entity.user),
      hospitalization: const HospitalizationMapper().toDtoOrNull(entity.hospitalization),
    );
  }

  List<MyPatient> toEntityList(List<MyPatientDTO> dtos) => dtos.map(toEntity).toList();

  List<MyPatientDTO> toDtoList(List<MyPatient> entities) => entities.map(toDto).toList();

  MyPatient? toEntityOrNull(MyPatientDTO? dto) => dto == null ? null : toEntity(dto);

  MyPatientDTO? toDtoOrNull(MyPatient? entity) => entity == null ? null : toDto(entity);
}
