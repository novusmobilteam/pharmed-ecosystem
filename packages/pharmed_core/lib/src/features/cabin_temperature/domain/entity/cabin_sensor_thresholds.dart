// [SWREQ-HW-SENSOR-002]
class CabinSensorThresholds {
  const CabinSensorThresholds({this.tempMin, this.tempMax, this.humidityMin, this.humidityMax});

  final double? tempMin;
  final double? tempMax;
  final double? humidityMin;
  final double? humidityMax;

  /// Servis eşik dönmezse kullanılır. İlaç saklama için tipik oda koşulları.
  static const fallback = CabinSensorThresholds(tempMin: 15, tempMax: 25, humidityMin: 30, humidityMax: 65);

  bool get hasTempRange => tempMin != null && tempMax != null;
  bool get hasHumidityRange => humidityMin != null && humidityMax != null;

  SensorStatus temperatureStatus(double? value) => _evaluate(value, tempMin, tempMax);

  SensorStatus humidityStatus(double? value) => _evaluate(value, humidityMin, humidityMax);

  /// Ölçüm veya eşik yoksa değerlendirme yapılamaz — yanlış alarm vermektense
  /// unknown döner.
  SensorStatus _evaluate(double? value, double? min, double? max) {
    if (value == null || min == null || max == null) return SensorStatus.unknown;
    if (value < min || value > max) return SensorStatus.outOfRange;
    return SensorStatus.normal;
  }
}

// [SWREQ-HW-SENSOR-002]
/// Bir sensör okumasının eşiklere göre değerlendirilmesi.
///
/// [unknown] iki durumda döner: ölçüm yok (sensör okumadı) veya eşik yok
/// (servis tanımlamamış). İkisinde de UI uyarı göstermez — yanlış alarm
/// vermektense sessiz kalmak tercih edilir.
enum SensorStatus {
  /// Değer tanımlı aralık içinde.
  normal,

  /// Değer alt veya üst eşiği aştı — UI uyarı gösterir.
  outOfRange,

  /// Değerlendirme yapılamıyor (ölçüm ya da eşik eksik).
  unknown;

  bool get isAlert => this == SensorStatus.outOfRange;
}
