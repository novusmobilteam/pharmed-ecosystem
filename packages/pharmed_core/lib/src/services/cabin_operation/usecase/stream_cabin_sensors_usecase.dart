// [SWREQ-HW-SENSOR-001] [IEC 62304 §5.5]
// Yönetim kartını edinip kabin sensör stream'ini başlatır.
// Manager edinimi başarısız olursa CabinConnectionException fırlatır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class StreamCabinSensorsUseCase {
  const StreamCabinSensorsUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  /// [targetPort]: COM port (null → servis default'u).
  /// [interval]: Polling aralığı (null → servis default'u).
  ///
  /// Throws [CabinConnectionException] manager edinilemezse.
  Stream<CabinSensorReading> call({String? targetPort, Duration? interval}) async* {
    final manager = await _scanManager(targetPort: targetPort);
    yield* _cabinOps.streamCabinSensors(manager: manager, interval: interval);
  }
}
