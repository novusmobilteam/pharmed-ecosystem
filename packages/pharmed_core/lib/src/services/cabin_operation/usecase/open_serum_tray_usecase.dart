// [SWREQ-HW-TRAY-002] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Elektromanyetik kilitli serum rafında TEK bir avadanlığın kilidini açar.
///
/// **Ön koşul:** Serum kapağı açık olmalıdır (session [MasterDrawerOpened]'a
/// geçmiş). Bu use case bunu kendisi doğrulamaz.
///
/// **Sıra:** önce rafın TÜM kilitleri enerjilenir (`k`, bütün avadanlıklar
/// sabitlenir), ardından hedef port serbest bırakılır (`o`; kart diğer
/// portları kendisi kilitli tutar).
///
/// **Otomatik tekrar deneme:** yanıt yok / protokol hatası 1 kez, 200ms
/// sonra sessizce tekrar denenir. Kart meşgulse (`noo4`/`noo2` — rafta başka
/// bir avadanlık çekili) tekrar DENENMEZ; kullanıcının önce onu yerine itmesi
/// gerekir.
class OpenSerumTrayUseCase {
  const OpenSerumTrayUseCase(this._trayLock);

  final ITrayLockService _trayLock;

  static const _unit = 'OpenSerumTray';
  static const _swreq = 'SWREQ-HW-TRAY-002';

  /// Throws [MasterDrawerException]: `trayBusy` (rafta başka avadanlık
  /// çekili) ya da `trayUnlockFailed` (diğer tüm nedenler, denemeler tükendi).
  Future<void> call({required SerumTrayAddress address}) async {
    for (var attempt = 0; ; attempt++) {
      try {
        await _trayLock.lockAll(deviceId: address.deviceId);
        await _trayLock.unlock(deviceId: address.deviceId, port: address.port);
        return;
      } on TrayLockException catch (e) {
        final mapped = _map(e.failure);
        final retryable = mapped == MasterDrawerFailure.trayUnlockFailed && attempt < 1;

        MedLogger.warn(
          unit: _unit,
          swreq: _swreq,
          message: retryable ? 'Avadanlık kilidi açılamadı, tekrar deneniyor' : 'Avadanlık kilidi açılamadı',
          context: {
            'failure': e.failure.name,
            'detail': e.detail,
            'attempt': attempt + 1,
            'deviceId': address.deviceId,
            'port': address.port,
            'cellId': address.cellId,
          },
        );

        if (!retryable) throw MasterDrawerException(mapped, detail: e.toString());
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  static MasterDrawerFailure _map(TrayLockFailure failure) => switch (failure) {
    TrayLockFailure.busy || TrayLockFailure.trayOpen => MasterDrawerFailure.trayBusy,
    _ => MasterDrawerFailure.trayUnlockFailed,
  };
}
