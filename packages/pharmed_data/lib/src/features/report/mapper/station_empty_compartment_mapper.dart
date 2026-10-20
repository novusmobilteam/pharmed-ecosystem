import 'package:pharmed_core/pharmed_core.dart';

class StationEmptyCompartmentMapper {
  const StationEmptyCompartmentMapper();

  StationEmptyCompartment toEntity(StationEmptyCompartmentDto dto) {
    return StationEmptyCompartment(
      cabinDesignId: dto.cabinDesignId,
      stationId: dto.stationId,
      stationName: dto.stationName,
      cabinId: dto.cabinId,
      cabinName: dto.cabinName,
      drawerId: dto.drawrId,
      drawerName: dto.drawrName,
      emptyCount: dto.emptyCount,
      occupiedCount: dto.occupiedCount,
    );
  }

  List<StationEmptyCompartment> toEntityList(List<StationEmptyCompartmentDto> dtos) => dtos.map(toEntity).toList();

  StationEmptyCompartmentDetail toDetailEntity(StationEmptyCompartmentDetailDto dto) {
    return StationEmptyCompartmentDetail(
      cabinDrawerId: dto.cabinDrawrId,
      cabinDesignId: dto.cabinDesignId,
      stationId: dto.stationId,
      stationName: dto.stationName,
      cabinId: dto.cabinId,
      cabinName: dto.cabinName,
      drawerId: dto.drawrId,
      orderNumber: dto.orderNumber,
      address: dto.address,
      compartmentNo: dto.compartmentNo,
      orderNo: dto.orderNo,
      location: dto.location,
      compartmentCount: dto.compartmentCount,
      stepCount: dto.stepCount,
    );
  }

  List<StationEmptyCompartmentDetail> toDetailEntityList(List<StationEmptyCompartmentDetailDto> dtos) =>
      dtos.map(toDetailEntity).toList();
}
