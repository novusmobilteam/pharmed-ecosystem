import '../../../medicine/data/model/medicine_dto.dart';

import '../../domain/entity/kit_content.dart';

class KitContentDTO {
  final int? id;
  final int? kitId;
  final int? materialId;
  final MedicineDTO? medicine;
  final int? piece;
  final bool? isMaterial;

  KitContentDTO({
    this.id,
    this.kitId,
    this.materialId,
    this.medicine,
    this.piece,
    this.isMaterial,
  });

  factory KitContentDTO.fromJson(Map<String, dynamic> json) => KitContentDTO(
        id: json["id"],
        kitId: json["kitId"],
        materialId: json["materialId"],
        medicine: json["material"] != null ? MedicineDTO.fromJson(json["material"]) : null,
        piece: json["piece"],
        isMaterial: json["isMaterial"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "kitId": kitId,
        "materialId": materialId,
        "piece": piece,
      };

  KitContent toEntity() {
    return KitContent(
      id: id,
      piece: piece,
      medicine: medicine?.toEntity(),
    );
  }
}
