import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class AuthorizationBreakdownMapper {
  const AuthorizationBreakdownMapper();

  AuthorizationBreakdown toEntity(AuthorizationBreakdownDto dto) {
    return AuthorizationBreakdown(
      id: dto.id,
      prescriptionDetailId: dto.prescriptionDetailId,
      patientFullName: dto.patientFullName,
      materialId: dto.materialId,
      medicine: const MedicineMapper().toEntityOrNull(dto.material),
      materialName: dto.materialName,
      quantity: dto.quantity,
      applicationDate: dto.applicationDate,
      userId: dto.userId,
      userFullName: dto.userFullName,
      stationId: dto.stationId,
      stationName: dto.stationName,
      isOrderlessCollect: dto.isOrderlessCollect ?? false,
      isFreeAccessCollect: dto.isFreeAccessCollect ?? false,
    );
  }

  AuthorizationBreakdown? toEntityOrNull(AuthorizationBreakdownDto? dto) => dto == null ? null : toEntity(dto);

  List<AuthorizationBreakdown> toEntityList(List<AuthorizationBreakdownDto> dtos) => dtos.map(toEntity).toList();

  AuthorizationBreakdownDto toDto(AuthorizationBreakdown entity) {
    return AuthorizationBreakdownDto(
      id: entity.id,
      prescriptionDetailId: entity.prescriptionDetailId,
      patientFullName: entity.patientFullName,
      materialId: entity.materialId,
      material: const MedicineMapper().toDtoOrNull(entity.medicine),
      materialName: entity.materialName,
      quantity: entity.quantity,
      applicationDate: entity.applicationDate,
      userId: entity.userId,
      userFullName: entity.userFullName,
      stationId: entity.stationId,
      stationName: entity.stationName,
      isOrderlessCollect: entity.isOrderlessCollect,
      isFreeAccessCollect: entity.isFreeAccessCollect,
    );
  }
}
