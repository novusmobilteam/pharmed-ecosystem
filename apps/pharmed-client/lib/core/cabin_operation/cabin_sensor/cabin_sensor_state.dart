import 'package:pharmed_core/pharmed_core.dart';

class CabinSensorState {
  const CabinSensorState({this.reading, this.isPaused = false});
  final CabinSensorReading? reading;
  final bool isPaused;

  CabinSensorState copyWith({CabinSensorReading? reading, bool? isPaused}) =>
      CabinSensorState(
        reading: reading ?? this.reading,
        isPaused: isPaused ?? this.isPaused,
      );
}