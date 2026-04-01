import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// UrgentPatient ↔ UrgentPatientDTO dönüşümleri.
class UrgentPatientMapper {
  const UrgentPatientMapper();

  UrgentPatient toEntity(UrgentPatientDTO dto) {
    return UrgentPatient(
      id: dto.id,
      code: dto.code,
      patientId: dto.patientId,
      admissionDate: dto.admissionDate,
      // Patient için mevcut mapper'ı kullanıyoruz
      patient: const PatientMapper().toEntityOrNull(dto.patient),
      // Liste dönüşümü: PrescriptionItemMapper üzerinden
      prescriptionItems: dto.prescriptionItems != null
          ? const PrescriptionItemMapper().toEntityList(dto.prescriptionItems!)
          : null,
    );
  }

  UrgentPatientDTO toDto(UrgentPatient entity) {
    return UrgentPatientDTO(
      id: entity.id,
      code: entity.code,
      patientId: entity.patientId,
      admissionDate: entity.admissionDate,
      patient: const PatientMapper().toDtoOrNull(entity.patient),
      prescriptionItems: entity.prescriptionItems != null
          ? const PrescriptionItemMapper().toDtoList(entity.prescriptionItems!)
          : null,
    );
  }

  List<UrgentPatient> toEntityList(List<UrgentPatientDTO> dtos) => dtos.map(toEntity).toList();

  List<UrgentPatientDTO> toDtoList(List<UrgentPatient> entities) => entities.map(toDto).toList();

  UrgentPatient? toEntityOrNull(UrgentPatientDTO? dto) => dto == null ? null : toEntity(dto);

  UrgentPatientDTO? toDtoOrNull(UrgentPatient? entity) => entity == null ? null : toDto(entity);
}
