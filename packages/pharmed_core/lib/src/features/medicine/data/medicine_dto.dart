import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

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

  T when<T>({required T Function(DrugDTO drug) drug, required T Function(MedicalConsumableDTO consumable) consumable}) {
    final self = this;
    if (self is DrugDTO) return drug(self);
    if (self is MedicalConsumableDTO) return consumable(self);
    throw StateError('Unknown MaterialInventoryDTO subtype: $runtimeType');
  }

  Map<String, dynamic> toJson();
  Medicine toEntity();
}
