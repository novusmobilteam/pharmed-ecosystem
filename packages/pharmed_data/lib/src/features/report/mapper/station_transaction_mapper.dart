import 'package:pharmed_core/pharmed_core.dart';

class StationTransactionMapper {
  const StationTransactionMapper();

  StationTransaction toEntity(StationTransactionDto dto) {
    return StationTransaction(
      id: dto.id,
      cabinName: dto.cabinName,
      transaction: dto.transaction,
      transactionType: StationTransactionType.fromValue(dto.transactionId),
      code: dto.code,
      barcode: dto.barcode,
      material: dto.material,
      transactionDate: dto.transactionDate,
      quantity: dto.quantity,
      performedBy: dto.performedBy,
      protocolCode: dto.protocolCode,
      patient: dto.patient,
      order: dto.order,
      compartment: dto.compartment,
      witness: dto.witness,
      hasSteps: dto.hasSteps,
      stationId: dto.stationId,
      cabinId: dto.cabinId,
    );
  }

  StationTransaction? toEntityOrNull(StationTransactionDto? dto) => dto == null ? null : toEntity(dto);

  List<StationTransaction> toEntityList(List<StationTransactionDto> dtos) => dtos.map(toEntity).toList();

  StationTransactionDto toDto(StationTransaction entity) {
    return StationTransactionDto(
      id: entity.id,
      cabinName: entity.cabinName,
      transaction: entity.transaction,
      code: entity.code,
      barcode: entity.barcode,
      material: entity.material,
      transactionDate: entity.transactionDate,
      quantity: entity.quantity,
      performedBy: entity.performedBy,
      protocolCode: entity.protocolCode,
      patient: entity.patient,
      order: entity.order,
      compartment: entity.compartment,
      witness: entity.witness,
      hasSteps: entity.hasSteps,
      stationId: entity.stationId,
      cabinId: entity.cabinId,
    );
  }
}
