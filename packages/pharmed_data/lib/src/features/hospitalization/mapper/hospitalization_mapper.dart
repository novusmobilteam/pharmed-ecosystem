import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Hospitalization ↔ HospitalizationDTO dönüşümleri.
class HospitalizationMapper {
  const HospitalizationMapper();

  Hospitalization toEntity(HospitalizationDTO dto) {
    return Hospitalization(
      id: dto.id,
      code: dto.code,
      roomNo: dto.roomNo,
      bedNo: dto.bedNo,
      description: dto.description,
      admissionDate: dto.admissionDate,
      exitDate: dto.exitDate,
      waitingQuantity: dto.waitingQuantity,
      lastApproveDate: dto.lastApproveDate,
      isBaby: dto.isBaby,
      colorId: dto.colorId,
      isUrgent: dto.isUrgent ?? false,
      // Alt modellerin mapper çağrıları
      patient: const PatientMapper().toEntityOrNull(dto.patient),
      physicalService: const ServiceMapper().toEntityOrNull(dto.physicalService),
      inpatientService: const ServiceMapper().toEntityOrNull(dto.inpatientService),
      doctor: const UserMapper().toEntityOrNull(dto.doctor),
    );
  }

  HospitalizationDTO toDto(Hospitalization entity) {
    return HospitalizationDTO(
      id: entity.id,
      code: entity.code,
      roomNo: entity.roomNo,
      bedNo: entity.bedNo,
      description: entity.description,
      admissionDate: entity.admissionDate,
      exitDate: entity.exitDate,
      waitingQuantity: entity.waitingQuantity,
      lastApproveDate: entity.lastApproveDate,
      isBaby: entity.isBaby,
      colorId: entity.colorId,
      isUrgent: entity.isUrgent,
      // Entity'den DTO'ya dönüşüm
      patient: const PatientMapper().toDtoOrNull(entity.patient),
      patientId: entity.patient?.id,
      physicalService: const ServiceMapper().toDtoOrNull(entity.physicalService),
      physicalServiceId: entity.physicalService?.id,
      inpatientService: const ServiceMapper().toDtoOrNull(entity.inpatientService),
      inpatientServiceId: entity.inpatientService?.id,
      doctor: const UserMapper().toDtoOrNull(entity.doctor),
      doctorId: entity.doctor?.id,
    );
  }

  List<Hospitalization> toEntityList(List<HospitalizationDTO> dtos) => dtos.map(toEntity).toList();

  List<HospitalizationDTO> toDtoList(List<Hospitalization> entities) => entities.map(toDto).toList();

  Hospitalization? toEntityOrNull(HospitalizationDTO? dto) => dto == null ? null : toEntity(dto);

  HospitalizationDTO? toDtoOrNull(Hospitalization? entity) => entity == null ? null : toDto(entity);
}
