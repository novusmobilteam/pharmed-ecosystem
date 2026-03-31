import '../../../../core/core.dart';

import '../../data/model/kit_content_dto.dart';

class KitContent implements TableData {
  final int? id;
  final int? kitId;
  final Medicine? medicine;
  final int? piece;

  KitContent({this.id, this.kitId, this.medicine, this.piece});

  @override
  List get content => [medicine?.name, piece?.toCustomString()];

  @override
  List get rawContent => [medicine?.name, piece];

  @override
  List<String?> get titles => ['Malzeme Adı', 'Adet'];

  KitContent copyWith({int? id, int? kitId, Medicine? medicine, int? piece}) {
    return KitContent(
      id: id ?? this.id,
      kitId: kitId ?? this.kitId,
      medicine: medicine ?? this.medicine,
      piece: piece ?? this.piece,
    );
  }

  KitContentDTO toDTO() {
    return KitContentDTO(
      id: id,
      kitId: kitId,
      medicine: MedicineMapper().toDtoOrNull(medicine),
      materialId: medicine?.id,
      isMaterial: medicine?.isDrug,
      piece: piece,
    );
  }
}
