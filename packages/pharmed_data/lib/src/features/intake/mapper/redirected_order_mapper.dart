import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RedirectedOrderMapper {
  const RedirectedOrderMapper();

  RedirectedOrder toEntity(RedirectedOrderDto dto) {
    return RedirectedOrder(
      id: dto.id,
      materialId: dto.materialId,
      quantity: dto.quantity,
      isEquivalent: dto.isEquivalent,
      materialName: dto.materialName,
      prescriptionItem: dto.prescriptionItem == null ? null : PrescriptionItemMapper().toEntity(dto.prescriptionItem!),
      stationId: dto.stationId,
      stationName: dto.stationName,
      serviceId: dto.serviceId,
      serviceName: dto.serviceName,
      sendStationId: dto.sendStationId,
      sendStationName: dto.sendStationName,
      sendServiceId: dto.sendServiceId,
      sendServiceName: dto.sendServiceName,
      sendUserId: dto.sendUserId,
      sendUserName: dto.sendUserName,
      receivedDate: dto.receivedDate,
      receivedUserId: dto.receivedUserId,
      receivedUserName: dto.receivedUserName,
      isCancel: dto.isCancel,
      cancelUserId: dto.cancelUserId,
      cancelUserName: dto.cancelUserName,
      tcNo: dto.tcNo,
      patientName: dto.patientName,
      patientSurname: dto.patientSurname,
      hospitalizationId: dto.hospitalizationId,
      cabinStocks: dto.cabinStocks == null ? null : CabinStockMapper().toEntityList(dto.cabinStocks!),
    );
  }

  List<RedirectedOrder> toEntityList(List<RedirectedOrderDto> dtos) => dtos.map(toEntity).toList();
}
