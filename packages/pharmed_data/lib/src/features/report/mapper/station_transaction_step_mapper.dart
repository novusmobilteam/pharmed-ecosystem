import 'package:pharmed_core/pharmed_core.dart';

class StationTransactionStepMapper {
  const StationTransactionStepMapper();

  StationTransactionStep toEntity(StationTransactionStepDto dto) {
    return StationTransactionStep(
      id: dto.id,
      cabinDrawrDetailId: dto.cabinDrawrDetailId,
      stepNo: dto.stepNo,
      quantity: dto.quantity,
    );
  }

  StationTransactionStep? toEntityOrNull(StationTransactionStepDto? dto) => dto == null ? null : toEntity(dto);

  List<StationTransactionStep> toEntityList(List<StationTransactionStepDto> dtos) => dtos.map(toEntity).toList();

  StationTransactionStepDto toDto(StationTransactionStep entity) {
    return StationTransactionStepDto(
      id: entity.id,
      cabinDrawrDetailId: entity.cabinDrawrDetailId,
      stepNo: entity.stepNo,
      quantity: entity.quantity,
    );
  }

  List<StationTransactionStepDto> toDtoList(List<StationTransactionStep> entities) => entities.map(toDto).toList();
}
