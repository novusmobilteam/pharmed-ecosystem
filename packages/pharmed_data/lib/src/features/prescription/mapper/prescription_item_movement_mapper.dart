import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class PrescriptionItemMovementMapper {
  const PrescriptionItemMovementMapper();

  PrescriptionItemMovement toEntity(PrescriptionItemMovementDto dto) {
    return PrescriptionItemMovement(
      id: dto.id!,
      prescriptionItemId: dto.prescriptionItemId!,
      type: PrescriptionMovementType.fromId(dto.movementId),
      createdAt: dto.createdAt,
      performedBy: const UserMapper().toEntityOrNull(dto.user),
      quantity: dto.quantity,
    );
  }

  PrescriptionItemMovement? toEntityOrNull(PrescriptionItemMovementDto? dto) => dto == null ? null : toEntity(dto);

  List<PrescriptionItemMovement> toEntityList(List<PrescriptionItemMovementDto> dtos) => dtos.map(toEntity).toList();
}
