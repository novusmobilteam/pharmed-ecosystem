import 'package:pharmed_core/pharmed_core.dart';

class KitContent {
  final int? id;
  final int? kitId;
  final Medicine? medicine;
  final int? piece;

  KitContent({this.id, this.kitId, this.medicine, this.piece});

  KitContent copyWith({int? id, int? kitId, Medicine? medicine, int? piece}) {
    return KitContent(
      id: id ?? this.id,
      kitId: kitId ?? this.kitId,
      medicine: medicine ?? this.medicine,
      piece: piece ?? this.piece,
    );
  }
}
