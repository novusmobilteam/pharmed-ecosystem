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

class StartMobileDrawerSessionUseCase {
  const StartMobileDrawerSessionUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  Stream<DrawerSessionEvent> call({required int drawerPort, String? comPort}) async* {
    // 1. Manager edin
    final ManagementCard manager;
    try {
      manager = await _scanManager(targetPort: comPort);
    } on CabinConnectionException catch (e) {
      yield DrawerFailed(failure: MobileDrawerFailure.managerConnectFailed, detail: e.detail);
      return;
    }

    // 2. Açma komutu
    yield const DrawerOpening();

    try {
      await _cabinOps.openMobileDrawer(manager: manager, port: drawerPort);
    } catch (e) {
      yield DrawerFailed(failure: MobileDrawerFailure.openCommandFailed, detail: e.toString());
      return;
    }

    // 3. Status stream
    bool wasOpened = false;

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

          case DrawerPhysicalStatus.timeoutError:
            yield const DrawerFailed(failure: MobileDrawerFailure.statusTimeout);
            return;

          case DrawerPhysicalStatus.waitingPull:
          case DrawerPhysicalStatus.halfOpen:
          case DrawerPhysicalStatus.unknown:
            break;
        }
      }

      if (!wasOpened) {
        yield const DrawerFailed(failure: MobileDrawerFailure.openNotConfirmed);
      }
    } catch (e) {
      yield DrawerFailed(failure: MobileDrawerFailure.statusReadError, detail: e.toString());
    }
  }
}
