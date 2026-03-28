import '../../../../core/core.dart';
import '../../../dosage_form/domain/entity/dosage_form.dart';
import '../../../drug_class/domain/entity/drug_class.dart';
import '../../../drug_type/domain/entity/drug_type.dart';
import '../../../firm/domain/entity/firm.dart';
import '../../../material_type/domain/entity/material_type.dart';
import '../../../station/data/model/station_dto.dart';
import '../../../unit/data/model/unit_dto.dart';
import '../../../user/user.dart';
import '../../domain/entity/medicine.dart';

part 'drug_dto.dart';
part 'medical_consumable_dto.dart';

/// İlaç/Tıbbi Sarf Tanım ekranında İlaç(Drug) ve Tıbbi Sarf(MedicalConsumable)
/// tipindeki verileri tek bir listede gösteriyoruz. Verile /material/all adlı servisten
/// geliyor. Material, Flutter'da tanımlı bir class olduğu için böyle bir isim verildi.
///
/// isMaterial == true  -> DrugDTO
/// isMaterial == false -> MedicalConsumableDTO
sealed class MedicineDTO {
  const MedicineDTO();

  factory MedicineDTO.fromJson(Map<String, dynamic> json) {
    final isMaterial = json['isMaterial'] as bool? ?? false;
    return isMaterial ? DrugDTO.fromJson(json) : MedicalConsumableDTO.fromJson(json);
  }

  static List<MedicineDTO> listFromJson(List<dynamic>? data) {
    if (data == null) return const [];
    return data.whereType<Map<String, dynamic>>().map(MedicineDTO.fromJson).toList();
  }

  T when<T>({
    required T Function(DrugDTO drug) drug,
    required T Function(MedicalConsumableDTO consumable) consumable,
  }) {
    final self = this;
    if (self is DrugDTO) return drug(self);
    if (self is MedicalConsumableDTO) return consumable(self);
    throw StateError('Unknown MaterialInventoryDTO subtype: $runtimeType');
  }

  Map<String, dynamic> toJson();
  Medicine toEntity();
}
