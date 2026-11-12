// [SWREQ-CABIN-OP-003] [IEC 62304 §5.5]
// Mobil kabinde bir çekmece oturumu başlatır:
//   1. ScanManagerUseCase → manager edin
//   2. openMobileDrawer komutu gönder → yield DrawerOpening
//   3. Status stream → fullyOpen → yield DrawerOpened
//   4. locked (açıldıktan sonra) → yield DrawerClosed
//   5. hata → yield DrawerFailed
// Sınıf: Class B

import 'dart:async';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class StartMobileDrawerSessionUseCase {
  const StartMobileDrawerSessionUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  static const _unit = 'MobileDrawerSession';

  /// Açma komutundan sonra çekmecenin çekilmesi için beklenen en uzun süre.
  /// Aşılırsa oturum [MobileDrawerFailure.openNotConfirmed] ile biter;
  /// önceden süresiz bekleniyor, ekran "açılıyor"da kalıyordu.
  static const openConfirmTimeout = Duration(seconds: 60);
  static const _swreq = 'SWREQ-CABIN-OP-003';

  /// Hata olayını loglar ve döner — hatalar önceden yalnız ekranda
  /// gösteriliyordu, sahada sebep loglardan görülemiyordu (#176).
  DrawerFailed _failed(MobileDrawerFailure failure, {String? detail, required int port, ManagementCard? manager}) {
    MedLogger.error(
      unit: _unit,
      swreq: _swreq,
      message: 'Mobil çekmece oturumu başarısız',
      context: {'failure': failure.name, 'detail': detail, 'port': port, 'yonetimKarti': manager?.addressChar},
    );
    return DrawerFailed(failure: failure, detail: detail);
  }

  Stream<DrawerSessionEvent> call({required int drawerPort, String? comPort}) async* {
    // 1. Manager edin
    final ManagementCard manager;
    try {
      manager = await _scanManager(targetPort: comPort);
    } on CabinConnectionException catch (e) {
      yield _failed(MobileDrawerFailure.managerConnectFailed, detail: e.detail, port: drawerPort);
      return;
    }

    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Mobil çekmece açılıyor',
      context: {'port': drawerPort, 'yonetimKarti': manager.addressChar, 'comPort': comPort},
    );

    // 2. Açma komutu
    yield const DrawerOpening();

    try {
      await _cabinOps.openMobileDrawer(manager: manager, port: drawerPort);
    } catch (e) {
      yield _failed(MobileDrawerFailure.openCommandFailed, detail: e.toString(), port: drawerPort, manager: manager);
      return;
    }

    // 3. Status stream
    bool wasOpened = false;
    bool sawWaitingPull = false;
    final openWatch = Stopwatch()..start();

    try {
      await for (final status in _cabinOps.streamMobileDrawerStatus(manager: manager, port: drawerPort)) {
        switch (status) {
          case DrawerPhysicalStatus.fullyOpen:
            if (!wasOpened) {
              wasOpened = true;
              yield const DrawerOpened();
            }

          case DrawerPhysicalStatus.locked:
            if (wasOpened) {
              yield const DrawerClosed();
              return;
            }
            // Kilit açıldı (h1) ama çekmece çekilmeden geri kilitlendi.
            if (sawWaitingPull) {
              yield _failed(
                MobileDrawerFailure.openNotConfirmed,
                detail: 'Çekmece çekilmeden kilit kapandı',
                port: drawerPort,
                manager: manager,
              );
              return;
            }

          case DrawerPhysicalStatus.timeoutError:
            yield _failed(MobileDrawerFailure.statusTimeout, port: drawerPort, manager: manager);
            return;

          case DrawerPhysicalStatus.waitingPull:
            sawWaitingPull = true;

          case DrawerPhysicalStatus.halfOpen:
          case DrawerPhysicalStatus.unknown:
            break;
        }

        if (!wasOpened && openWatch.elapsed > openConfirmTimeout) {
          yield _failed(
            MobileDrawerFailure.openNotConfirmed,
            detail: 'Çekmece ${openConfirmTimeout.inSeconds} sn içinde açılmadı',
            port: drawerPort,
            manager: manager,
          );
          return;
        }
      }

      if (!wasOpened) {
        yield _failed(MobileDrawerFailure.openNotConfirmed, port: drawerPort, manager: manager);
      }
    } catch (e) {
      yield _failed(MobileDrawerFailure.statusReadError, detail: e.toString(), port: drawerPort, manager: manager);
    }
  }
}
