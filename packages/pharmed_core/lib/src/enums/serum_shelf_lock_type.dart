// [SWREQ-CORE-CABIN-SERUM-001] [IEC 62304 §5.5]
// Serum kabini rafının kilit tipi.
// Sınıf: Class B

/// Serum kabinindeki bir rafın (DrawerUnit) elektromanyetik kilit durumu.
///
/// API'de `cabinDrawrs[].toolType` alanına karşılık gelir.
///   - [locked]: rafın kendi kilit kartı var; işlemler `<iXX:YZ>` protokolüyle
///     avadanlık bazında yürütülür.
///   - [unlocked]: yazılım rafa müdahale etmez; yalnızca serum kabininin
///     kilidi açılır ve kapanış beklenir.
enum SerumShelfLockType {
  locked(1),
  unlocked(2);

  const SerumShelfLockType(this.id);

  final int id;

  bool get isLocked => this == SerumShelfLockType.locked;

  /// Bilinmeyen/boş değer güvenli tarafa (kilitsiz) düşer: kilitsiz rafta
  /// yazılım kilit kartına komut göndermez.
  static SerumShelfLockType fromId(int? id) =>
      SerumShelfLockType.values.firstWhere((e) => e.id == id, orElse: () => SerumShelfLockType.unlocked);
}
