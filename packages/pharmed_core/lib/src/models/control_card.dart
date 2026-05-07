// apps/pharmed-client/lib/core/hardware/model/control_card.dart

/// KONTROL KARTI TİPİ
enum ControlCardType { standard, serum, unknown }

/// KONTROL KARTI MODELİ
/// --------------------
/// Yönetim kartına bağlı bir çekmece kontrol kartını temsil eder.
/// Tarama sırasında her satır adresine tip sorgusu gönderilir,
/// gelen cevap parse edilerek [databaseTypeId] çıkarılır.
///
/// [rowAddress]: Kartın satır adresi (1-26)
/// [rawTypeResponse]: Cihazdan gelen ham tip cevabı (örn: ".33,", ".250,")
/// [databaseTypeId]: Parse edilmiş tip numarası — DrawerConfig.deviceTypeNo ile eşleşir
class ControlCard {
  ControlCard({required this.rowAddress, required this.rawTypeResponse}) : type = _determineType(rawTypeResponse);

  /// Kartın satır adresi (1-26)
  final int rowAddress;

  /// Cihazdan gelen ham tip cevabı (örn: ".33,", ".08,", ".250,")
  final String rawTypeResponse;

  /// Kart tipi (standard veya serum)
  final ControlCardType type;

  /// Ham cevaptan tip numarasını çıkarır.
  /// ".33," → 33, ".08," → 8, ".250," → 250
  int get databaseTypeId {
    final match = _typeRegex.firstMatch(rawTypeResponse);
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '0') ?? 0;
  }

  /// Serum kartı mı? (databaseTypeId == 250)
  bool get isSerum => type == ControlCardType.serum;

  static final _typeRegex = RegExp(r'\.(\d+),');

  static ControlCardType _determineType(String response) {
    final match = _typeRegex.firstMatch(response);
    if (match == null) return ControlCardType.unknown;

    final id = int.tryParse(match.group(1) ?? '0') ?? 0;
    return id == 250 ? ControlCardType.serum : ControlCardType.standard;
  }

  @override
  String toString() => 'ControlCard(row: $rowAddress, typeNo: $databaseTypeId, type: $type)';
}
