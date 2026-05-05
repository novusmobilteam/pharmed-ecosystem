// [SWREQ-SETUP-HW-001] [IEC 62304 §5.5]
// Mobil kabin çekmece port tarama use case.
//
// SORUMLULUK:
//   Serum kartına bağlı aktif portları tarar.
//   CabinOperationService'deki atomik komutları orkestre eder.
//
// AKIŞ:
//   1. Yönetim kartını bul (getOrScanManager)
//   2. Port 1-[_portCount] için:
//      a. Açma komutu gönder (openMobileDrawer)
//      b. .ok → aktif, çekmece açıldı → kullanıcı kapatana kadar bekle
//      c. .no / hata → pasif, sonraki porta geç
//   3. ScanMobileDrawerPortsResult döndür
//
// NEDEN BURADA:
//   - CabinOperationService sadece atomik donanım komutlarını bilir
//   - Tarama döngüsü, kapanma bekleme iş kuralları use case'e aittir
//   - Notifier sadece UI state'ini yönetir, iş mantığı bilmez
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/model/drawer_status.dart';
import '../../../../core/hardware/model/management_card.dart';
import '../../../../core/hardware/service/cabin_operation/i_cabin_operation_service.dart';
import '../../../../core/providers/providers.dart';
import '../entity/port_discovery_result.dart';

final scanMobileDrawerPortsUseCaseProvider = Provider<ScanMobileDrawerPortsUseCase>((ref) {
  return ScanMobileDrawerPortsUseCase(ref.read(cabinOperationServiceProvider));
});

class ScanMobileDrawerPortsUseCase {
  const ScanMobileDrawerPortsUseCase(this._service);

  final ICabinOperationService _service;

  /// Taranacak port sayısı — donanım kartındaki fiziksel port adedi.
  static const int _portCount = 4;

  /// Polling aralığı — çekmece kapanma kontrolü için.
  static const _pollInterval = Duration(milliseconds: 600);

  /// [targetPort]: Seri port adı (örn. 'COM3').
  /// [onPortDiscovered]: Her aktif port bulunduğunda çağrılır — UI anlık güncelleme için.
  /// [onWaitingClose]: Çekmece açılıp kapanması beklenirken çağrılır — UI'da
  ///   "Lütfen çekmeceyi kapatın" mesajı göstermek için kullanılır.
  Future<Result<PortDiscoveryResult>> call({
    required String targetPort,
    void Function(int portNumber)? onPortDiscovered,
    void Function(int portNumber)? onWaitingClose,
  }) async {
    try {
      // 1. Yönetim kartını bul
      final manager = await _service.getOrScanManager(targetPort: targetPort);

      if (manager == null) {
        return Result.error(
          SerialPortException(
            message:
                'Yönetim kartı bulunamadı. '
                'Seri port bağlantısını ve kart adresini kontrol edin.',
          ),
        );
      }

      final List<int> activePorts = [];

      // 2. Port 1-[_portCount] arası tara
      for (int port = 1; port <= _portCount; port++) {
        final opened = await _tryOpenPort(manager: manager, port: port);

        if (opened) {
          activePorts.add(port);
          onPortDiscovered?.call(port);
        }
      }

      return Result.ok(PortDiscoveryResult(activePorts: activePorts, pendingClosePorts: List.from(activePorts)));
    } on SerialPortException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(UnexpectedException(cause: e));
    }
  }

  /// Belirli bir porta açma komutu gönderir.
  ///
  /// Returns: true → solenoid var, çekmece açıldı
  ///          false → solenoid yok (.no) veya komut başarısız
  Future<bool> _tryOpenPort({required ManagementCard manager, required int port}) async {
    try {
      await _service.openMobileDrawer(manager: manager, port: port);
      // .ok geldi — şimdi kapanmasını bekle
      return await _waitForClose(manager: manager, port: port);
    } on SerialPortException {
      // Pasif port (.no) veya bağlantı hatası — bu portu pasif say
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Açılan çekmecenin kullanıcı tarafından kapatılmasını bekler.
  ///
  /// Timeout yoktur — kullanıcı kapatana kadar polling devam eder.
  /// UI'da [onWaitingClose] callback'i ile kullanıcı bilgilendirilmelidir.
  Future<bool> _waitForClose({required ManagementCard manager, required int port}) async {
    final deadline = DateTime.now().add(const Duration(seconds: 35));

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(_pollInterval);
      final status = await _service.getMobileDrawerStatus(manager: manager, port: port);
      if (status == DrawerPhysicalStatus.locked) return true;
    }

    return false; // timeout → fiziksel çekmece yok
  }
}
