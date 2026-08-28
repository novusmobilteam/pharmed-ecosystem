import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class UpcomingTreatmentMapper {
  const UpcomingTreatmentMapper();

  UpcomingTreatment toEntity(UpcomingTreatmentDto dto) {
    return UpcomingTreatment(
      patientHospitalizationId: dto.patientHospitalizationId,
      patientId: dto.patientId,
      patientFullName: dto.patientFullName,
      patientName: dto.patientName,
      patientSurname: dto.patientSurname,
      patientCode: dto.patientCode,
      hospitalizationCode: dto.hospitalizationCode,
      serviceId: dto.serviceId,
      serviceName: dto.serviceName,
      roomName: dto.roomName,
      bedName: dto.bedName,
      treatmentCount: dto.treatmentCount,
      prescriptionCount: dto.prescriptionCount,
      firstTreatmentTime: dto.firstTreatmentTime,
      lastTreatmentTime: dto.lastTreatmentTime,
      details: TreatmentDetailMapper().toEntityList(dto.details ?? []),
    );
  }

  List<UpcomingTreatment> toEntityList(List<UpcomingTreatmentDto> dtos) => dtos.map(toEntity).toList();
}

class TreatmentDetailMapper {
  const TreatmentDetailMapper();

  TreatmentDetail toEntity(TreatmentDetailDto dto) {
    return TreatmentDetail(
      prescriptionDetailId: dto.prescriptionDetailId,
      prescriptionId: dto.prescriptionId,
      materialId: dto.materialId,
      materialName: dto.materialName,
      dosePiece: dto.dosePiece,
      time: dto.time,
      medicine: MedicineMapper().toEntityOrNull(dto.medicine),
    );
  }

  List<TreatmentDetail> toEntityList(List<TreatmentDetailDto> dtos) => dtos.map(toEntity).toList();
}
