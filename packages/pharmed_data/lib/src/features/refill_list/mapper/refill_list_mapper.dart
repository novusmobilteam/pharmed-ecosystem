import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RefillListMapper {
  const RefillListMapper();

  RefillList toEntity(RefillListDto dto) {
    return RefillList(
      id: dto.id,
      station: dto.station != null ? StationMapper().toEntity(dto.station!) : null,
      user: dto.user != null ? UserMapper().toEntity(dto.user!) : null,
      status: dto.status != null ? RefillListStatus.fromId(dto.statusId) : null,
      isCancel: dto.isCancel,
      isFilled: dto.isFilled,
      date: dto.date,
    );
  }

  RefillListDto toDto(RefillList entity) {
    return RefillListDto(
      id: entity.id,
      stationId: entity.station?.id,
      station: entity.station != null ? StationMapper().toDto(entity.station!) : null,
      user: entity.user != null ? UserMapper().toDto(entity.user!) : null,
      status: entity.status?.label,
      isCancel: entity.isCancel,
      isFilled: entity.isFilled,
      date: entity.date,
    );
  }

  List<RefillList> toEntityList(List<RefillListDto> dtos) => dtos.map(toEntity).toList();
}
