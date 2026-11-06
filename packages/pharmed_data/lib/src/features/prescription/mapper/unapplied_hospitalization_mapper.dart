import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// UnappliedHospitalization ↔ UnappliedHospitalizationDto dönüşümü (salt okunur).
class UnappliedHospitalizationMapper {
  const UnappliedHospitalizationMapper({
    this.prescriptionMapper = const PrescriptionMapper(),
    this.prescriptionItemMapper = const PrescriptionItemMapper(),
  });

  final PrescriptionMapper prescriptionMapper;
  final PrescriptionItemMapper prescriptionItemMapper;

  UnappliedHospitalization toEntity(UnappliedHospitalizationDto dto) {
    return UnappliedHospitalization(
      id: dto.id,
      hospitalizationId: dto.hospitalizationId,
      hospitalization: const HospitalizationMapper().toEntityOrNull(dto.hospitalization),
      hospitalizationDate: dto.hospitalizationDate,
      remainingCount: dto.remainingCount,
      materialNames: dto.materialNames,
      prescriptions: prescriptionMapper.toEntityList(dto.prescriptions),
      items: prescriptionItemMapper.toEntityList(dto.details),
    );
  }

  List<UnappliedHospitalization> toEntityList(List<UnappliedHospitalizationDto> dtos) => dtos.map(toEntity).toList();
}
