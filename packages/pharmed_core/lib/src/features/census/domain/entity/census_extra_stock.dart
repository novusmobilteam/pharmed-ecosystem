import 'package:pharmed_core/pharmed_core.dart';

/// Sayım sırasında kullanıcının bildirdiği, beklenmedik şekilde
/// kabinde bulunan fazla stok.
class CensusExtraStock {
  /// Lokal ID — listeden silme/düzenleme için. Backend'e gitmez.
  final String localId;
  final Medicine medicine;
  final double quantity;

  const CensusExtraStock({required this.localId, required this.medicine, required this.quantity});

  CensusExtraStock copyWith({double? quantity}) =>
      CensusExtraStock(localId: localId, medicine: medicine, quantity: quantity ?? this.quantity);
}
