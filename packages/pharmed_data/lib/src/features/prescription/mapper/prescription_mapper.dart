import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Prescription ↔ PrescriptionDTO dönüşümleri.
class PrescriptionMapper {
  const PrescriptionMapper();

  Prescription toEntity(PrescriptionDto dto) {
    return Prescription(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      hospitalizationId: dto.hospitalizationId,
      prescriptionDate: dto.prescriptionDate,
      hospitalizationDate: dto.hospitalizationDate,
      isPrescribed: dto.isPrescribed,
      remainingCount: dto.remainingCount,
      // İç içe geçmiş modelin dönüşümü
      hospitalization: dto.hospitalization != null
          ? const HospitalizationMapper().toEntity(dto.hospitalization!)
          : null,
    );
  }

  PrescriptionDto toDto(Prescription entity) {
    return PrescriptionDto(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      // DTO isimlendirmesine (patientHospitalizationId) DTO içinde
      // zaten map edildiği için burada DTO constructor parametre ismini kullanıyoruz.
      hospitalizationId: entity.hospitalizationId,
      prescriptionDate: entity.prescriptionDate,
      hospitalizationDate: entity.hospitalizationDate,
      isPrescribed: entity.isPrescribed,
      remainingCount: entity.remainingCount,
      hospitalization: const HospitalizationMapper().toDtoOrNull(entity.hospitalization),
    );
  }

  List<Prescription> toEntityList(List<PrescriptionDto> dtos) => dtos.map(toEntity).toList();

  List<PrescriptionDto> toDtoList(List<Prescription> entities) => entities.map(toDto).toList();

  Prescription? toEntityOrNull(PrescriptionDto? dto) => dto == null ? null : toEntity(dto);

  PrescriptionDto? toDtoOrNull(Prescription? entity) => entity == null ? null : toDto(entity);
}
