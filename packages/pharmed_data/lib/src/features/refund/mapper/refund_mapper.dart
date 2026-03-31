import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Refund ↔ RefundDTO dönüşümleri.
class RefundMapper {
  const RefundMapper();

  Refund toEntity(RefundDTO dto) {
    return Refund(
      id: dto.id,
      type: dto.type,
      quantity: dto.quantity,
      returnFormId: dto.returnFormId,
      prescriptionDetailId: dto.prescriptionDetailId,
      userId: dto.userId,
      user: dto.user,
      receiveDate: dto.receiveDate,
      isCancel: dto.isCancel,
      description: dto.description,
      isDeleted: dto.isDeleted,
      // Alt Mapper'lar
      prescriptionDetail: const PrescriptionItemMapper().toEntityOrNull(dto.prescriptionDetail),
      medicine: const MedicineMapper().toEntityOrNull(dto.medicine),
      station: const StationMapper().toEntityOrNull(dto.station),
      receiveUser: const UserMapper().toEntityOrNull(dto.receiveUser),
      cancelUser: const UserMapper().toEntityOrNull(dto.cancelUser),
    );
  }

  RefundDTO toDto(Refund entity) {
    return RefundDTO(
      id: entity.id,
      type: entity.type,
      quantity: entity.quantity,
      returnFormId: entity.returnFormId,
      prescriptionDetailId: entity.prescriptionDetailId,
      userId: entity.userId,
      user: entity.user,
      receiveDate: entity.receiveDate,
      isCancel: entity.isCancel,
      description: entity.description,
      isDeleted: entity.isDeleted,
      // Alt DTO Dönüşümleri
      prescriptionDetail: const PrescriptionItemMapper().toDtoOrNull(entity.prescriptionDetail),
      medicine: const MedicineMapper().toDtoOrNull(entity.medicine),
      station: const StationMapper().toDtoOrNull(entity.station),
      receiveUser: const UserMapper().toDtoOrNull(entity.receiveUser),
      cancelUser: const UserMapper().toDtoOrNull(entity.cancelUser),
    );
  }

  List<Refund> toEntityList(List<RefundDTO> dtos) => dtos.map(toEntity).toList();
  List<RefundDTO> toDtoList(List<Refund> entities) => entities.map(toDto).toList();
  Refund? toEntityOrNull(RefundDTO? dto) => dto == null ? null : toEntity(dto);
  RefundDTO? toDtoOrNull(Refund? entity) => entity == null ? null : toDto(entity);
}
