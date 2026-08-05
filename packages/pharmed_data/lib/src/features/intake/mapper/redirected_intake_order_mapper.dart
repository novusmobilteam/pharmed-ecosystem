import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RedirectedIntakeOrderMapper {
  const RedirectedIntakeOrderMapper();

  RedirectedIntakeOrder toEntity(RedirectedIntakeOrderDTO dto) {
    final detail = dto.prescriptionItem;
    return RedirectedIntakeOrder(
      id: dto.id,
      prescriptionDetailId: detail?.id,
      dosePiece: detail?.dosePiece?.toDouble(),
      time: detail?.time,
      firstDoseEmergency: detail?.firstDoseEmergency ?? false,
      askDoctor: detail?.askDoctor ?? false,
      inCaseOfNecessity: detail?.inCaseOfNecessity ?? false,
      medicine: detail?.medicine == null ? null : MedicineMapper().toEntity(detail!.medicine!),
      hospitalization: detail?.hospitalization == null
          ? null
          : HospitalizationMapper().toEntity(detail!.hospitalization!),
      sendStationName: dto.sendStationName,
      sendServiceName: dto.sendServiceName,
      sendUserName: dto.sendUserName,
      receiveDate: dto.receiveDate,
      isCancel: dto.isCancel,
      stocks: CabinStockMapper().toEntityList(dto.stocks),
      prescriptionItem: PrescriptionItemMapper().toEntityOrNull(dto.prescriptionItem),
      isEquivalent: dto.isEquivalent,
    );
  }

  List<RedirectedIntakeOrder> toEntityList(List<RedirectedIntakeOrderDTO> dtos) => dtos.map(toEntity).toList();
}
