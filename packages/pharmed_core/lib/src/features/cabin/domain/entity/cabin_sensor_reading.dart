import 'battery_level_convertor.dart';

/// Kabin sensör okuması — ısı, nem, akü.
/// [SWREQ-HW-SENSOR-001]
class CabinSensorReading {
  const CabinSensorReading({required this.timestamp, this.temperature, this.humidity, this.batteryVolts});

  final DateTime timestamp;
  final double? temperature; // °C
  final double? humidity; // %
  final double? batteryVolts; // V (ham ölçüm)

  /// Voltajdan türetilen YAKLAŞIK doluluk. Güvenlik kararı için kullanma —
  /// LiFePO4 platosunda hata payı yüksektir. Eşikler voltajdan işletilmeli.
  double? get batteryPercent => batteryVolts == null ? null : BatteryLevelConverter.toPercent(batteryVolts!);

  bool get isBatteryCritical => batteryVolts != null && BatteryLevelConverter.isCritical(batteryVolts!);

  bool get hasTempHumidity => temperature != null && humidity != null;
  bool get hasBattery => batteryVolts != null;
}
