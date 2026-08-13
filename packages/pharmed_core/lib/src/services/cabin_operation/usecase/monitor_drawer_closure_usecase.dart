// [SWREQ-CLI-CABIN-OP-014] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Çekmecenin FİZİKSEL olarak kapandığını sensör stream'i üzerinden izler.
///
/// Kullanıcı işlemi tamamlayıp [MasterDrawerSessionNotifier.confirmClose]
/// çağırdıktan sonra devreye girer (stage: `WaitingForClose`). Sensör
/// [DrawerPhysicalStatus.locked] ("h0"/"h4"/"h5") durumuna ulaşınca
/// [DrawerClosed] yayınlanır ve stream sonlanır — bu, oturumun `Closed`
/// terminal stage'ine geçmesini tetikler (bkz. `master-drawer-operation`
/// skill §2, §6).
///
/// **Sadece ANA çekmecenin kapanışı izlenir.** Kübik gözlerin (kapakların)
/// kapanma sensörü YOKTUR — kullanıcının fiziksel olarak kapattığına
/// güvenilir (bkz. `master-drawer-operation` skill §6). Bu yüzden [isKubik]
/// dalında da adres [DrawerAddress.cubicMaster] ile SABİT master kilit
/// adresidir, açılışı izleyen [StartMasterDrawerSessionUseCase] ile birebir
/// aynı adresleme mantığı — burada göz bazlı bir adres asla hesaplanmaz.
class MonitorDrawerClosureUseCase {
  const MonitorDrawerClosureUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  /// [assignment]: kapanışı izlenecek çekmeceye ait (herhangi bir temsilci)
  /// atama. Çekmece tipi ve donanım adresi buradan türetilir — kübikte
  /// hangi gözün atandığının bir önemi yoktur, adres yine de sabit master
  /// kilide gider.
  ///
  /// Kapanma tespit edilince [DrawerClosed] yayınlanır, stream sonlanır.
  /// Manager edinilemezse [DrawerFailed] yayınlanır (TERMİNAL).
  /// Donanımla iletişim koparsa (bkz. [CabinOperationService.
  /// streamMasterDrawerStatus] — art arda başarısız poll sonrası
  /// [DrawerPhysicalStatus.timeoutError]) [DrawerFailed]
  /// (sensorCommunicationLost) yayınlanır (TERMİNAL) — aksi halde stream
  /// sessizce sonsuza kadar beklerdi ve kullanıcı arayüzde "kapanması
  /// bekleniyor" durumunda takılı kalırdı.
  Stream<DrawerSessionEvent> call({required MedicineAssignment assignment}) async* {
    final isSerum = assignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final address = calculateAddressFromAssignment(assignment);

    final ManagementCard manager;
    try {
      manager = await _scanManager(targetPort: assignment.cabin?.comPort?.name);
    } on CabinConnectionException catch (e) {
      yield DrawerFailed(
        failure: e.failure == CabinConnectionFailure.managerNotFound
            ? MasterDrawerFailure.managerNotFound
            : MasterDrawerFailure.managerConnectFailed,
        detail: e.detail,
      );
      return;
    }

    final Stream<DrawerPhysicalStatus> sensorStream;
    if (isSerum) {
      sensorStream = _cabinOps.streamMasterSerumDrawerStatus(manager: manager, row: address.row);
    } else if (isKubik) {
      final monitorAddress = DrawerAddress.cubicMaster(address.row);
      sensorStream = _cabinOps.streamMasterDrawerStatus(
        manager: manager,
        row: monitorAddress.row,
        port: monitorAddress.port,
        drawer: monitorAddress.index,
      );
    } else {
      sensorStream = _cabinOps.streamMasterDrawerStatus(
        manager: manager,
        row: address.row,
        port: address.port,
        drawer: address.index,
      );
    }

    await for (final status in sensorStream) {
      if (status == DrawerPhysicalStatus.timeoutError) {
        yield DrawerFailed(
          failure: MasterDrawerFailure.sensorCommunicationLost,
          detail: 'Donanımla iletişim kesildi (kapanış izlenirken sensör yanıt vermiyor).',
        );
        return;
      }

      if (status == DrawerPhysicalStatus.locked) {
        yield const DrawerClosed();
        return;
      }
    }
  }
}
