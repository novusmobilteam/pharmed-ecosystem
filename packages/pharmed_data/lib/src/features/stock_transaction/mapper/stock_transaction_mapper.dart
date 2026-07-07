import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class StockTransactionMapper {
  const StockTransactionMapper();

  StockTransaction toEntity(StockTransactionDTO dto) {
    return StockTransaction(
      id: dto.id,
      warehouseId: dto.warehouseId,
      warehouse: dto.warehouse != null ? const WarehouseMapper().toEntity(dto.warehouse!) : null,
      materialType: dto.materialType,
      prescriptionDetailId: dto.prescriptionDetailId,
      transactionKind: dto.transactionKind != null ? StockTransactionKind.fromId(dto.transactionKind!) : null,
      quantity: dto.quantity,
      beforeQuantity: dto.beforeQuantity,
      userId: dto.userId,
      user: dto.user != null ? const UserMapper().toEntity(dto.user!) : null,
      isSend: dto.isSend,
      sendDate: dto.sendDate,
      expirationDate: dto.expirationDate,
      transactionType: dto.transactionType != null ? StockTransactionType.fromId(dto.transactionType!) : null,
      medicine: dto.medicine != null ? const MedicineMapper().toEntity(dto.medicine!) : null,
      service: dto.sendService != null ? const ServiceMapper().toEntity(dto.sendService!) : null,
    );
  }

  StockTransaction? toEntityOrNull(StockTransactionDTO? dto) => dto == null ? null : toEntity(dto);

  List<StockTransaction> toEntityList(List<StockTransactionDTO> dtos) => dtos.map(toEntity).toList();

  StockTransactionDTO toDto(StockTransaction entity) {
    return StockTransactionDTO(
      id: entity.id,
      warehouseId: entity.warehouseId,
      materialType: entity.materialType,
      prescriptionDetailId: entity.prescriptionDetailId,
      transactionKind: entity.transactionKind?.id,
      quantity: entity.quantity,
      userId: entity.userId,
      isSend: entity.isSend,
      sendDate: entity.sendDate,
      expirationDate: entity.expirationDate,
      transactionType: entity.transactionType?.id,
      medicineId: entity.medicine?.id,
      sendServiceId: entity.service?.id,
    );
  }
}
