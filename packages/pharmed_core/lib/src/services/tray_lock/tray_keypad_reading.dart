// [SWREQ-HW-TRAY-003] [IEC 62304 §5.5]
// Avadanlık kilit kartındaki Al-Ver tuş değerinin (t komutu) anlık okuması.
// Sınıf: Class B

/// Al-Ver tuş değeri ve kullanıcının bu açılışta tuşlara dokunup dokunmadığı.
///
/// Kart, kilit açılırken değeri SIFIRLAMAZ — önceki işlemin değeri ekranda
/// kalır. Bu yüzden kilit açıldıktan sonraki ilk okuma [baseline] kabul
/// edilir; doğrulama yalnızca değer en az bir kez değiştiyse ([hasChanged])
/// geçerlidir. Aksi halde önceki işlemden kalan değer, kullanıcı hiçbir şey
/// girmeden eşleşmiş sayılırdı.
final class TrayKeypadReading {
  const TrayKeypadReading({required this.value, required this.baseline, required this.hasChanged});

  /// Son okunan tuş değeri (00-99).
  final int value;

  /// Kilit açıldıktan sonraki ilk okuma.
  final int baseline;

  /// Bu açılışta değer en az bir kez [baseline]'dan farklı okundu mu.
  final bool hasChanged;

  /// Değer [expected] ile eşleşiyor ve kullanıcı bu açılışta tuşlara dokundu.
  bool matches(int expected) => hasChanged && value == expected;

  TrayKeypadReading withValue(int next) =>
      TrayKeypadReading(value: next, baseline: baseline, hasChanged: hasChanged || next != baseline);

  @override
  bool operator ==(Object other) =>
      other is TrayKeypadReading && other.value == value && other.baseline == baseline && other.hasChanged == hasChanged;

  @override
  int get hashCode => Object.hash(value, baseline, hasChanged);

  @override
  String toString() => 'TrayKeypadReading(value: $value, baseline: $baseline, changed: $hasChanged)';
}
