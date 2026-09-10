/// Serum rafının (DrawerUnit) elektromanyetik kilit durumu.
/// API'de `toolType` alanına karşılık gelir.
enum DrawerUnitLockType {
  locked(1),
  unlocked(2);

  const DrawerUnitLockType(this.apiValue);
  final int apiValue;
}
