/// LiFePO4 8S akü (nominal 25.6V, max 29.6V, min 21.2V) için
/// voltaj → yaklaşık doluluk yüzdesi.
///
/// UYARI: LiFePO4 voltaj eğrisi %20-%90 arasında çok düz olduğundan
/// bu değer YAKLAŞIKTIR. Kesin doluluk için akünün BMS'inden
/// coulomb sayımı (SoC) okunmalıdır.
///
/// [SWREQ-HW-SENSOR-001]
class BatteryLevelConverter {
  /// (voltaj, yüzde) çiftleri — azalan sırada.
  static const List<({double volts, double percent})> _curve = [
    (volts: 27.2, percent: 100),
    (volts: 26.8, percent: 90),
    (volts: 26.4, percent: 70),
    (volts: 26.0, percent: 50),
    (volts: 25.6, percent: 30),
    (volts: 25.2, percent: 20),
    (volts: 24.0, percent: 10),
    (volts: 21.2, percent: 0),
  ];

  /// Ölçülen voltajı doluluk yüzdesine çevirir (0-100).
  static double toPercent(double volts) {
    if (volts >= _curve.first.volts) return 100;
    if (volts <= _curve.last.volts) return 0;

    for (int i = 0; i < _curve.length - 1; i++) {
      final upper = _curve[i];
      final lower = _curve[i + 1];

      if (volts <= upper.volts && volts >= lower.volts) {
        final ratio = (volts - lower.volts) / (upper.volts - lower.volts);
        return lower.percent + ratio * (upper.percent - lower.percent);
      }
    }
    return 0;
  }

  /// Şarj oluyor olabilir mi? 27.2V üstü LiFePO4'te aktif şarjı işaret eder.
  static bool isLikelyCharging(double volts) => volts > 27.2;

  /// Kritik seviye — kabin işlemi başlatılmamalı.
  static bool isCritical(double volts) => volts <= 24.0;
}