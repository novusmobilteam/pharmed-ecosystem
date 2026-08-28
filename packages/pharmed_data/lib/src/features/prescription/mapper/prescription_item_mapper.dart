import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// PrescriptionItem ↔ PrescriptionItemDTO dönüşümleri.
class PrescriptionItemMapper {
  const PrescriptionItemMapper();

  PrescriptionItem toEntity(PrescriptionItemDto dto) {
    return PrescriptionItem(
      id: dto.id,
      prescriptionId: dto.prescriptionId,
      patientRegistrationId: dto.hospitalizationId,
      physicalServiceId: dto.physicalServiceId,
      inpatientServiceId: dto.inpatientServiceId,
      doctorId: dto.doctorId,
      medicineId: dto.medicineId,
      dosePiece: dto.dosePiece,
      receiveDosePiece: dto.receiveDosePiece,
      firstDoseEmergency: dto.firstDoseEmergency,
      askDoctor: dto.askDoctor,
      inCaseOfNecessity: dto.inCaseOfNecessity,
      times: dto.times,
      time: dto.time,
      description: dto.description,
      deleteDescription: dto.deleteDescription,
      removed: dto.removed,
      barcode: dto.barcode,
      sutCode: dto.sutCode,
      ubbCode: dto.ubbCode,
      atcCode: dto.atcCode,
      isQrCode: dto.isQrCode,
      qrCode: dto.qrCode,
      prescriptionDate: dto.prescriptionDate,
      protocolNo: dto.protocolNo,
      patientName: _parsePatientName(dto),
      rfidTag: dto.rfidTag,
      applicationDate: dto.applicationDate,
      applicationUser: const UserMapper().toEntityOrNull(dto.applicationUser),

      // Enum Dönüşümleri
      requestType: RequestType.fromId(dto.requestType),

      // Alt Mapperlar
      physicalService: const ServiceMapper().toEntityOrNull(dto.physicalService),
      inpatientService: const ServiceMapper().toEntityOrNull(dto.inpatientService),
      medicine: const MedicineMapper().toEntityOrNull(dto.medicine),
      prescription: const PrescriptionMapper().toEntityOrNull(dto.prescription),
      doctor: User.fromIdAndFullName(id: dto.doctorId, fullName: dto.doctor),
      hospitalization: HospitalizationMapper().toEntityOrNull(dto.hospitalization),

      // Son Hareket
      lastMovement: PrescriptionItemMovementMapper().toEntityOrNull(dto.lastMovement),
    );
  }

  PrescriptionItemDto toDto(PrescriptionItem entity) {
    return PrescriptionItemDto(
      id: entity.id,
      prescriptionId: entity.prescriptionId,
      hospitalizationId: entity.patientRegistrationId,
      physicalServiceId: entity.physicalServiceId,
      inpatientServiceId: entity.inpatientServiceId,
      doctorId: entity.doctorId,
      doctor: entity.doctor?.fullName,
      medicineId: entity.medicineId,
      dosePiece: entity.dosePiece,
      requestType: entity.requestType?.id,
      firstDoseEmergency: entity.firstDoseEmergency,
      askDoctor: entity.askDoctor,
      inCaseOfNecessity: entity.inCaseOfNecessity,
      times: entity.times,
      time: entity.time,
      description: entity.description,
      deleteDescription: entity.deleteDescription,
      removed: entity.removed,
      barcode: entity.barcode,
      sutCode: entity.sutCode,
      ubbCode: entity.ubbCode,
      atcCode: entity.atcCode,
      isQrCode: entity.isQrCode,
      qrCode: entity.qrCode,
      prescriptionDate: entity.prescriptionDate,
      protocolNo: entity.protocolNo,
      patientName: entity.patientName,
      rfidTag: entity.rfidTag,

      // Alt DTO Dönüşümleri
      physicalService: const ServiceMapper().toDtoOrNull(entity.physicalService),
      inpatientService: const ServiceMapper().toDtoOrNull(entity.inpatientService),
      medicine: const MedicineMapper().toDtoOrNull(entity.medicine),
      prescription: const PrescriptionMapper().toDtoOrNull(entity.prescription),
    );
  }

  String? _parsePatientName(PrescriptionItemDto dto) {
    if (dto.patientName != null) return dto.patientName;
    final namePart = [dto.name, dto.surname].whereType<String>().join(' ').trim();
    return namePart.isEmpty ? null : namePart;
  }

  List<PrescriptionItem> toEntityList(List<PrescriptionItemDto> dtos) => dtos.map(toEntity).toList();
  List<PrescriptionItemDto> toDtoList(List<PrescriptionItem> entities) => entities.map(toDto).toList();
  PrescriptionItem? toEntityOrNull(PrescriptionItemDto? dto) => dto == null ? null : toEntity(dto);
  PrescriptionItemDto? toDtoOrNull(PrescriptionItem? entity) => entity == null ? null : toDto(entity);
}
