import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class EquivalentMedicineMapper {
  const EquivalentMedicineMapper();

  // ── DrawerType → DrawerConfig → DrawerSlot → DrawerUnit → DrawerCell ──

  DrawerType _toDrawerType(DrawerTypeDTO? dto) {
    if (dto == null) return const DrawerType();
    return DrawerType(
      id: dto.id,
      name: dto.name,
      compartmentCount: dto.compartmentCount,
      isMultipleMaterialInput: dto.isMultipleMaterialInput ?? false,
      isKubik: dto.isKubik ?? false,
      isActive: dto.isActive ?? true,
    );
  }

  DrawerConfig? _toDrawerConfig(DrawerConfigDTO? dto) {
    if (dto == null) return null;
    return DrawerConfig(
      id: dto.id,
      drawerTypeId: dto.drawerType?.id ?? 0,
      numberOfSteps: dto.numberOfSteps ?? 0,
      stepMultiplier: dto.stepMultiplier ?? 1,
      drawerType: dto.drawerType == null ? null : _toDrawerType(dto.drawerType),
    );
  }

  DrawerSlot? _toDrawerSlot(DrawerSlotDTO? dto) {
    if (dto == null) return null;
    return DrawerSlot(
      id: dto.id,
      drawerConfigId: dto.drawerConfigId,
      cabinId: dto.cabinId,
      orderNumber: dto.orderNumber,
      address: dto.address,
      drawerConfig: _toDrawerConfig(dto.drawerConfig),
    );
  }

  DrawerUnit? _toDrawerUnit(DrawerUnitDTO? dto) {
    if (dto == null) return null;
    return DrawerUnit(
      id: dto.id,
      drawerSlotId: dto.drawerSlotId,
      compartmentNo: dto.compartmentNo,
      orderNo: dto.orderNo,
      drawerSlot: _toDrawerSlot(dto.drawerSlot),
    );
  }

  DrawerCell? _toDrawerCell(DrawerCellDTO? dto) {
    if (dto == null) return null;
    return DrawerCell(id: dto.id, stepNo: dto.stepNo, drawerUnit: _toDrawerUnit(dto.drawerUnit));
  }

  // ── CabinStock (+ sentetik MedicineAssignment) ──

  CabinStock _toCabinStock(CabinStockDTO dto) {
    final cell = _toDrawerCell(dto.cabinDrawerDetail);
    final medicine = dto.medicine == null ? null : MedicineMapper().toEntity(dto.medicine!);

    // equivalentCheck yanıtı MedicineAssignment vermiyor — DrawerCell
    // zincirinden burada SENTEZLİYORUZ. minQuantity/maxQuantity/
    // criticalQuantity gibi atama-seviyesi alanlar bu yanıtta yok, null
    // bırakılıyor (yalnızca kuyruk kurulumu için yeterli: cabinDrawerId,
    // drawerUnit, cabinDrawerDetail).
    final assignment = cell == null
        ? null
        : MedicineAssignment(
            cabinDrawerId: cell.drawerUnit?.id,
            medicine: medicine,
            drawerUnit: cell.drawerUnit,
            cabinDrawerDetail: [cell],
          );

    return CabinStock(
      id: dto.id,
      cabinDrawerDetailId: dto.cabinDrawerDetailId,
      cabinDrawerId: cell?.drawerUnit?.id,
      quantity: dto.quantity,
      miadDate: dto.miadDate,
      medicine: medicine,
      cabinDrawerDetail: cell,
      assignment: assignment,
    );
  }

  EquivalentMedicine toEntity(EquivalentMedicineDto dto) => EquivalentMedicine(
    materialId: dto.materialId,
    materialName: dto.materialName,
    stockQuantity: dto.stockQuantity,
    purchaseQuantity: dto.purchaseQuantity,
    stocks: dto.stocks.map(_toCabinStock).toList(),
  );

  List<EquivalentMedicine> toEntityList(List<EquivalentMedicineDto> dtos) => dtos.map(toEntity).toList();
}
