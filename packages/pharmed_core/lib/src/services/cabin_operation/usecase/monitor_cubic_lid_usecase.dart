// [SWREQ-CLI-CABIN-OP-013] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Kübik çekmecede TEK bir gözün kapak durumunu periyodik olarak yayınlar.
///
/// Adres hesabı [OpenCubicLidUseCase] ile BİREBİR aynıdır
/// ([calculateAddressFromAssignment] — row / compartmentNo / orderNo);
/// açılan göz ile izlenen göz aynı fiziksel adres olmak zorundadır.
///
/// Ham durumu yayar — "ac → kp" kenar tespiti ve süre aşımı kararları
/// [MasterDrawerSession]'ın sorumluluğudur.
///
/// Stream HATA FIRLATMAZ: manager edinilemezse [CubicLidStatus.timeoutError]
/// yayıp kapanır. Session bunu `lidSensorLost` olarak ele alır; böylece
/// dinleyicide ayrıca onError yönetimi gerekmez.
class MonitorCubicLidUseCase {
  const MonitorCubicLidUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  Stream<CubicLidStatus> call({required MedicineAssignment cellAssignment}) async* {
    final ManagementCard manager;
    try {
      manager = await _scanManager(targetPort: cellAssignment.cabin?.comPort?.name);
    } catch (e) {
      MedLogger.warn(
        unit: 'MonitorCubicLid',
        swreq: 'SWREQ-CLI-CABIN-OP-013',
        message: 'Kübik kapak izlemesi başlatılamadı — manager edinilemedi',
        context: {'error': e.toString()},
      );
      yield CubicLidStatus.timeoutError;
      return;
    }

    final address = calculateAddressFromAssignment(cellAssignment);

    yield* _cabinOps.streamMasterCubicLidStatus(
      manager: manager,
      row: address.row,
      port: address.port,
      lidIndex: address.index,
    );
  }
}
