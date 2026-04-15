import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// PrescriptionItem ↔ PrescriptionItemDTO dönüşümleri.
class PrescriptionItemMapper {
  const PrescriptionItemMapper();

  PrescriptionItem toEntity(PrescriptionItemDTO dto) {
    return PrescriptionItem(
      id: dto.id,
      prescriptionId: dto.prescriptionId,
      patientRegistrationId: dto.patientRegistrationId,
      physicalServiceId: dto.physicalServiceId,
      inpatientServiceId: dto.inpatientServiceId,
      doctorId: dto.doctorId,
      medicineId: dto.medicineId,
      dosePiece: dto.dosePiece,
      requestTypeName: dto.requestTypeName,
      firstDoseEmergency: dto.firstDoseEmergency,
      askDoctor: dto.askDoctor,
      inCaseOfNecessity: dto.inCaseOfNecessity,
      times: dto.times,
      time: dto.time,
      description: dto.description,
      deleteDescription: dto.deleteDescription,
      removed: dto.removed,
      returnQuantity: dto.returnQuantity,
      barcode: dto.barcode,
      sutCode: dto.sutCode,
      ubbCode: dto.ubbCode,
      atcCode: dto.atcCode,
      isQrCode: dto.isQrCode,
      qrCode: dto.qrCode,
      prescriptionDate: dto.prescriptionDate,
      protocolNo: dto.protocolNo,
      patientName: _parsePatientName(dto),

      // Enum Dönüşümleri
      requestType: RequestType.fromId(dto.requestType),
      status: PrescriptionStatus.fromId(dto.statusId),

      // Alt Mapperlar
      physicalService: const ServiceMapper().toEntityOrNull(dto.physicalService),
      inpatientService: const ServiceMapper().toEntityOrNull(dto.inpatientService),
      medicine: const MedicineMapper().toEntityOrNull(dto.medicine),
      prescription: const PrescriptionMapper().toEntityOrNull(dto.prescription),

      // Doktor (DTO'da String veya Id olarak gelebiliyor)
      doctor: User.fromIdAndFullName(id: dto.doctorId, fullName: dto.doctor),

      // Süreç Kullanıcıları ve Tarihleri
      approvalDate: dto.approvalDate,
      approvalUserId: dto.approvalUserId,
      approvalUser: const UserMapper().toEntityOrNull(dto.approvalUser),

      cancelDate: dto.cancelDate,
      cancelUserId: dto.cancelUserId,
      cancelUser: const UserMapper().toEntityOrNull(dto.cancelUser),

      applicationDate: dto.applicationDate,
      applicationUserId: dto.applicationUserId,
      applicationUser: const UserMapper().toEntityOrNull(dto.applicationUser),

      returnDate: dto.returnDate,
      returnUserId: dto.returnUserId,
      returnUser: const UserMapper().toEntityOrNull(dto.returnUser),

      createdDate: dto.createdDate,
      createdUserId: dto.createdUserId,
      createdUser: const UserMapper().toEntityOrNull(dto.createdUser),

      rejectDate: dto.rejectDate,
      rejectUserId: dto.rejectUserId,
      rejectUser: const UserMapper().toEntityOrNull(dto.rejectUser),

      wastageDate: dto.wastageDate,
      wastageUserId: dto.wastageUserId,
      wastageUser: const UserMapper().toEntityOrNull(dto.wastageUser),

      destructionDate: dto.destructionDate,
      destructionUserId: dto.destructionUserId,
      destructionUser: const UserMapper().toEntityOrNull(dto.destructionUser),
    );
  }

  PrescriptionItemDTO toDto(PrescriptionItem entity) {
    return PrescriptionItemDTO(
      id: entity.id,
      prescriptionId: entity.prescriptionId,
      patientRegistrationId: entity.patientRegistrationId,
      physicalServiceId: entity.physicalServiceId,
      inpatientServiceId: entity.inpatientServiceId,
      doctorId: entity.doctorId,
      doctor: entity.doctor?.fullName,
      medicineId: entity.medicineId,
      dosePiece: entity.dosePiece,
      requestType: entity.requestType?.id,
      requestTypeName: entity.requestTypeName,
      firstDoseEmergency: entity.firstDoseEmergency,
      askDoctor: entity.askDoctor,
      inCaseOfNecessity: entity.inCaseOfNecessity,
      times: entity.times,
      time: entity.time,
      description: entity.description,
      deleteDescription: entity.deleteDescription,
      removed: entity.removed,
      returnQuantity: entity.returnQuantity,
      barcode: entity.barcode,
      sutCode: entity.sutCode,
      ubbCode: entity.ubbCode,
      atcCode: entity.atcCode,
      isQrCode: entity.isQrCode,
      qrCode: entity.qrCode,
      prescriptionDate: entity.prescriptionDate,
      protocolNo: entity.protocolNo,
      patientName: entity.patientName,
      statusId: entity.status?.id,

      // Alt DTO Dönüşümleri
      physicalService: const ServiceMapper().toDtoOrNull(entity.physicalService),
      inpatientService: const ServiceMapper().toDtoOrNull(entity.inpatientService),
      medicine: const MedicineMapper().toDtoOrNull(entity.medicine),
      prescription: const PrescriptionMapper().toDtoOrNull(entity.prescription),

      // Süreç Kullanıcı DTO'ları
      approvalDate: entity.approvalDate,
      approvalUserId: entity.approvalUserId,
      approvalUser: const UserMapper().toDtoOrNull(entity.approvalUser),

      cancelDate: entity.cancelDate,
      cancelUserId: entity.cancelUserId,
      cancelUser: const UserMapper().toDtoOrNull(entity.cancelUser),

      applicationDate: entity.applicationDate,
      applicationUserId: entity.applicationUserId,
      applicationUser: const UserMapper().toDtoOrNull(entity.applicationUser),

      returnDate: entity.returnDate,
      returnUserId: entity.returnUserId,
      returnUser: const UserMapper().toDtoOrNull(entity.returnUser),
    );
  }

  /// Hasta adını DTO'daki farklı alanlardan (name/surname veya patientName) güvenli birleştirir.
  String? _parsePatientName(PrescriptionItemDTO dto) {
    if (dto.patientName != null) return dto.patientName;
    final namePart = [dto.name, dto.surname].whereType<String>().join(' ').trim();
    return namePart.isEmpty ? null : namePart;
  }

  List<PrescriptionItem> toEntityList(List<PrescriptionItemDTO> dtos) => dtos.map(toEntity).toList();
  List<PrescriptionItemDTO> toDtoList(List<PrescriptionItem> entities) => entities.map(toDto).toList();
  PrescriptionItem? toEntityOrNull(PrescriptionItemDTO? dto) => dto == null ? null : toEntity(dto);
  PrescriptionItemDTO? toDtoOrNull(PrescriptionItem? entity) => entity == null ? null : toDto(entity);
}
