import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Hospitalization ↔ HospitalizationDTO dönüşümleri.
class HospitalizationMapper {
  const HospitalizationMapper();

  Hospitalization toEntity(HospitalizationDto dto) {
    return Hospitalization(
      id: dto.id,
      code: dto.code,
      roomId: dto.roomId,
      bedId: dto.bedId,
      description: dto.description,
      admissionDate: dto.admissionDate,
      exitDate: dto.exitDate,
      waitingQuantity: dto.waitingQuantity,
      lastApproveDate: dto.lastApproveDate,
      isBaby: dto.isBaby,
      colorId: dto.colorId,
      isUrgent: dto.isUrgent ?? false,
      bed: BedMapper().toEntityOrNull(dto.bed),
      physicalServiceId: dto.physicalServiceId,
      inpatientServiceId: dto.inpatientServiceId,
      patient: const PatientMapper().toEntityOrNull(dto.patient),
      physicalService: const ServiceMapper().toEntityOrNull(dto.physicalService),
      inpatientService: const ServiceMapper().toEntityOrNull(dto.inpatientService),
      doctor: const UserMapper().toEntityOrNull(dto.doctor),
    );
  }

  HospitalizationDto toDto(Hospitalization entity) {
    print(entity.exitDate);
    return HospitalizationDto(
      id: entity.id,
      code: entity.code,
      roomId: entity.roomId,
      bedId: entity.bedId,
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

  List<Hospitalization> toEntityList(List<HospitalizationDto> dtos) => dtos.map(toEntity).toList();

  List<HospitalizationDto> toDtoList(List<Hospitalization> entities) => entities.map(toDto).toList();

  Hospitalization? toEntityOrNull(HospitalizationDto? dto) => dto == null ? null : toEntity(dto);

  HospitalizationDto? toDtoOrNull(Hospitalization? entity) => entity == null ? null : toDto(entity);
}
