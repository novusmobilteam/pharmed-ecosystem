// pharmed_core/features/witness/witness_context.dart
// [SWREQ-CORE-WITNESS-001] [IEC 62304 §5.5]
//
// Bir işlem kaleminin şahitlik durumunu taşır — alım (isWitnessedPurchase)
// ve fire/imha (isWastageWitnessedPurchase) ortak kullanır. İade'de şahitlik
// kavramı hiç yok, bu yüzden RefundItem bu tipi hiç taşımaz (nullable bir
// alan olarak eklenmez — yapısal olarak yoktur).
//
// Hangi drug flag'inin (isWitnessedPurchase / isWastageWitnessedPurchase)
// kontrol edileceğine bu sınıf karar vermez — çağıran (use case) ilacın
// doğru flag'ini okuyup witnesses/stations listesini bu sınıfa doldurur.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class WitnessContext {
  const WitnessContext({this.witnesses = const [], this.stations = const [], this.witness});

  /// Şahit olabilecek kullanıcılar (servisten, ilgili flag true ise gelir).
  final List<User> witnesses;

  /// Şahit kısıtının uygulandığı istasyonlar — boşsa TÜM istasyonlarda
  /// şahit gerekir.
  final List<Station> stations;

  /// Kullanıcının seçtiği/onayladığı şahit.
  final User? witness;

  /// [requiresWitness]: ilgili drug flag'i (isWitnessedPurchase ya da
  /// isWastageWitnessedPurchase) — çağıran hangi işlemde olduğuna göre verir.
  bool needsWitness({required bool requiresWitness, Station? currentStation}) {
    if (!requiresWitness) return false;
    if (stations.isEmpty) return true;
    if (currentStation == null) return false;
    return stations.any((s) => s.id == currentStation.id);
  }

  bool isApproved({required bool requiresWitness, Station? currentStation}) =>
      needsWitness(requiresWitness: requiresWitness, currentStation: currentStation) && witness != null;

  WitnessContext copyWith({User? witness}) =>
      WitnessContext(witnesses: witnesses, stations: stations, witness: witness ?? this.witness);
}
