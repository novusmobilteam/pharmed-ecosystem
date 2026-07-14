import 'package:pharmed_core/pharmed_core.dart';

class CabinSensorState {
  const CabinSensorState({
    this.reading,
    this.thresholds = CabinSensorThresholds.fallback,
    this.isPaused = false,
    this.tempHistory = const [],
    this.humidityHistory = const [],
  });

  final CabinSensorReading? reading;

  /// Servisten gelen ısı/nem eşikleri. Çekilene kadar (veya hata durumunda)
  /// fallback değerler kullanılır.
  final CabinSensorThresholds thresholds;

  final bool isPaused;

  /// Sparkline için son N okuma. Null okumalar geçmişe girmez.
  final List<double> tempHistory;
  final List<double> humidityHistory;

  CabinSensorState copyWith({
    CabinSensorReading? reading,
    CabinSensorThresholds? thresholds,
    bool? isPaused,
    List<double>? tempHistory,
    List<double>? humidityHistory,
  }) => CabinSensorState(
    reading: reading ?? this.reading,
    thresholds: thresholds ?? this.thresholds,
    isPaused: isPaused ?? this.isPaused,
    tempHistory: tempHistory ?? this.tempHistory,
    humidityHistory: humidityHistory ?? this.humidityHistory,
  );
}
