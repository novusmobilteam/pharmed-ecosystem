import 'package:pharmed_manager/core/core.dart';

class KitContentDto {
  final int? id;
  final int? kitId;
  final int? materialId;
  final MedicineDTO? medicine;
  final int? piece;
  final bool? isMaterial;

  KitContentDto({this.id, this.kitId, this.materialId, this.medicine, this.piece, this.isMaterial});

  factory KitContentDto.fromJson(Map<String, dynamic> json) => KitContentDto(
    id: json["id"],
    kitId: json["kitId"],
    materialId: json["materialId"],
    medicine: json["material"] != null ? MedicineDTO.fromJson(json["material"]) : null,
    piece: json["piece"],
    isMaterial: json["isMaterial"],
  );

  Map<String, dynamic> toJson() => {"id": id, "kitId": kitId, "materialId": materialId, "piece": piece};
}
