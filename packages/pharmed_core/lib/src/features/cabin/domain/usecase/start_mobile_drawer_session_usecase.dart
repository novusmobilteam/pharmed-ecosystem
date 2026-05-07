// pharmed_core/lib/src/cabin/usecase/start_mobile_drawer_session_use_case.dart
//
// [SWREQ-CABIN-OP-003] [IEC 62304 §5.5]
// Mobil kabinde bir çekmece oturumu başlatır:
//   1. COM porta bağlan (gerekirse) → ICabinOperationService.getOrScanManager
//   2. openMobileDrawer komutu gönder → yield Opening
//   3. Status stream → fullyOpen tespit edilince yield Opened
//   4. locked tespit edilince (açıldıktan sonra) yield Closed (stream kapanır)
//   5. timeout/unknown/exception → yield Failed
//
// Bu use case operasyon tipinden (refill/pickup/return) bağımsızdır;
// sadece çekmece fiziksel oturumunu modeller.
//
// Sınıf: Class B

import 'dart:async';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class StartMobileDrawerSessionUseCase {
  StartMobileDrawerSessionUseCase({required ICabinOperationService cabinOperationService})
    : _cabinOps = cabinOperationService;

  final ICabinOperationService _cabinOps;

  /// [comPort] COM port adı (örn: 'COM3'). Null ise service kendi default'unu kullanır.
  /// [drawerPort] mobil kontrol kartı üzerinde 1–4 arası port.
  /// [slotId] görsel slot kimliği — stage event'lerinde geri yayınlanır.
  Stream<MobileDrawerStage> call({required int drawerPort, required int slotId, String? comPort}) async* {
    // 1. Manager edinme (gerekirse port bağlantısı + kart taraması)
    final ManagementCard? manager;
    try {
      manager = await _cabinOps.getOrScanManager(targetPort: comPort);
    } catch (e) {
      MedLogger.error(
        unit: 'StartMobileDrawerSessionUseCase',
        swreq: 'SWREQ-CABIN-OP-003',
        message: 'getOrScanManager exception',
        context: {'error': e.toString()},
      );
      yield MobileDrawerFailed(message: 'Yönetim kartına bağlanılamadı: $e', port: drawerPort, slotId: slotId);
      return;
    }

    if (manager == null) {
      yield MobileDrawerFailed(message: 'Yönetim kartı bulunamadı.', port: drawerPort, slotId: slotId);
      return;
    }

    // 2. Açma komutu
    yield MobileDrawerOpening(port: drawerPort, slotId: slotId);

    try {
      await _cabinOps.openMobileDrawer(manager: manager, port: drawerPort);
    } on AppException catch (e) {
      MedLogger.error(
        unit: 'StartMobileDrawerSessionUseCase',
        swreq: 'SWREQ-CABIN-OP-003',
        message: 'openMobileDrawer başarısız',
        context: {'port': drawerPort, 'error': e.toString()},
      );
      yield MobileDrawerFailed(
        message: 'Çekmece açma komutu gönderilemedi: ${e.toString()}',
        port: drawerPort,
        slotId: slotId,
      );
      return;
    } catch (e) {
      yield MobileDrawerFailed(message: 'Çekmece açma komutu gönderilemedi: $e', port: drawerPort, slotId: slotId);
      return;
    }

    // 3. Status stream tüketilir
    bool wasOpened = false;

    try {
      await for (final status in _cabinOps.streamMobileDrawerStatus(manager: manager, port: drawerPort)) {
        switch (status) {
          case DrawerPhysicalStatus.fullyOpen:
            if (!wasOpened) {
              wasOpened = true;
              yield MobileDrawerOpened(port: drawerPort, slotId: slotId);
            }
            break;

          case DrawerPhysicalStatus.locked:
            if (wasOpened) {
              yield MobileDrawerClosed(port: drawerPort, slotId: slotId);
              return; // Oturum tamamlandı
            }
            // Henüz açılmadıysa locked durumu beklenir; göz ardı edilir.
            break;

          case DrawerPhysicalStatus.waitingPull:
          case DrawerPhysicalStatus.halfOpen:
            // Açılış sürecinin ara durumları; herhangi bir stage emit etme.
            break;

          case DrawerPhysicalStatus.timeoutError:
            yield MobileDrawerFailed(
              message: 'Çekmece durumu okunurken zaman aşımı oluştu.',
              port: drawerPort,
              slotId: slotId,
            );
            return;

          case DrawerPhysicalStatus.unknown:
            // Tek seferlik unknown göz ardı edilir; sürekli unknown gelirse
            // alt katmanın timeoutError'a düşmesi beklenir.
            break;
        }
      }

      // Stream caller iptal etmeden sonlandıysa ve hâlâ açılmadıysa → hata.
      if (!wasOpened) {
        yield MobileDrawerFailed(message: 'Çekmecenin açıldığı doğrulanamadı.', port: drawerPort, slotId: slotId);
      }
    } catch (e) {
      MedLogger.error(
        unit: 'StartMobileDrawerSessionUseCase',
        swreq: 'SWREQ-CABIN-OP-003',
        message: 'Status stream hatası',
        context: {'port': drawerPort, 'error': e.toString()},
      );
      yield MobileDrawerFailed(message: 'Çekmece durumu okunurken hata oluştu: $e', port: drawerPort, slotId: slotId);
    }
  }
}
