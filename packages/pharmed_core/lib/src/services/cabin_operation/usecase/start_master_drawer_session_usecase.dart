// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// Sınıf: Class B

import 'dart:async';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Master kabin çekmece oturumunu BAŞLATIR: yönetim kartını bulur, ilgili
/// çekmece/kübik ana kilidini açma komutunu gönderir ve fiziksel sensör
/// üzerinden çekmecenin gerçekten açıldığını doğrular.
///
/// Akış (event sırası):
///   1. [DrawerOpeningWithStep](devicePreparing) — yönetim kartı aranıyor
///   2. [DrawerFailed] — yönetim kartı bulunamazsa/bağlanamazsa (TERMİNAL)
///   3. [DrawerOpeningWithStep](lockOpening) — açma komutu gönderiliyor
///   4. [DrawerFailed] — açma komutu reddedilirse/donanım hata dönerse (TERMİNAL)
///   5. [DrawerWaitingForPull] — komut kabul edildi, kullanıcının/motorun
///      çekmeceyi açması bekleniyor
///   6. Sensör izlenir; hedef fiziksel duruma ulaşılırsa:
///      → [DrawerOpened] (TERMİNAL, başarı)
///      10 saniye içinde hedef duruma ulaşılamazsa VEYA donanımla iletişim
///      kesilirse (bkz. [DrawerPhysicalStatus.timeoutError]):
///      → [DrawerFailed](lockOpenTimeout) (TERMİNAL)
///
/// Çekmece tipine göre farklılıklar:
///   - **Serum**: `openMasterSerumDrawer` + `streamMasterSerumDrawerStatus`,
///     row dışında port/drawer parametresi yok (sabit adresleme).
///   - **Kübik**: adres `DrawerAddress.cubicMaster(row)` ile hesaplanır
///     (sabit port=[DeviceConstants.masterLockPort],
///     drawer=[DeviceConstants.cubicMasterDrawerId]) — kübik ana kilidi
///     TEK bir fiziksel adrestir, hangi gözde işlem yapılacağının bir önemi
///     yoktur. Kabul kriteri SADECE [DrawerPhysicalStatus.fullyOpen]
///     (donanım "h3"): kübikte [DrawerPhysicalStatus.halfOpen] ("h2") kapak
///     açmaya izin vermeyen bir ara durumdur, bu yüzden standarttan farklı
///     olarak kabul edilmez. Bu event akışı SADECE ana çekmeceyi açar; kübik
///     gözlerin kapaklarını açmaz — bkz. [OpenCubicLidUseCase.call],
///     [DrawerOpened] sonrası feature notifier tarafından ayrıca çağrılır.
///   - **Standart (birim doz)**: adres [calculateAddressFromAssignment] ile
///     hesaplanan gerçek port/drawer'dır. Kabul kriteri
///     [DrawerPhysicalStatus.fullyOpen] VEYA [DrawerPhysicalStatus.halfOpen]
///     (ikisi de "işlem yapılabilir" sayılır — standart çekmecede kısmi
///     açılma da yeterlidir, kübikteki gibi bir kapak kilitlenmesi yoktur).
class StartMasterDrawerSessionUseCase {
  const StartMasterDrawerSessionUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  /// Sensörün hedef fiziksel duruma ulaşması için beklenecek azami süre.
  /// Bu süre aşılırsa (mekanik sıkışma, motor arızası vb.) [DrawerFailed]
  /// (lockOpenTimeout) yayınlanır — aksi halde stream sonsuza kadar
  /// beklerdi ve kullanıcı arayüzde donmuş bir "açılıyor" göstergesinde
  /// takılı kalırdı.
  static const _fullyOpenTimeout = Duration(seconds: 10);

  /// [assignment]: açılacak çekmece/göze ait atama. Çekmece tipi
  /// (`isKubik`/`isSerum`) ve donanım adresi buradan türetilir.
  ///
  /// [requestedQuantity]: hedef göz henüz çözülmemiş akışlar için (bkz.
  /// [calculateAddressFromAssignment]). Dolumda hiç kullanılmaz (sabit 0 →
  /// tam açılış). Kübikte bu parametrenin HİÇBİR etkisi yoktur — kübik ana
  /// kilit adresi sabittir, miktar hesabına girmez.
  ///
  /// [explicitTargetStep]: hedef göz ZATEN ÇÖZÜLMÜŞ akışlar için (alım/iade
  /// — CheckIntake/CheckRefund planı hangi stoktan alınacağını/konacağını
  /// zaten belirledi). Verildiğinde [calculateAddressFromAssignment]'ın
  /// kümülatif stok toplama mantığına HİÇ girilmez. Kübikte bu parametrenin
  /// de HİÇBİR etkisi yoktur (aynı sebeple: kübik ana kilit adresi sabit).
  ///
  /// İkisi de opsiyonel + varsayılan null/0 — mevcut çağıranlar (dolum/
  /// sayım/boşaltma) hiçbir şey geçmediği için davranışları DEĞİŞMEZ, her
  /// zaman tam açılış olur.
  Stream<DrawerSessionEvent> call({
    required MedicineAssignment assignment,
    double requestedQuantity = 0.0,
    int? explicitTargetStep,
  }) async* {
    final isKubik = assignment.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;
    final isSerum = assignment.drawerUnit?.drawerSlot?.drawerConfig?.isSerum ?? false;
    final address = calculateAddressFromAssignment(
      assignment,
      requestedQuantity: requestedQuantity,
      explicitTargetStep: explicitTargetStep,
    );
    final portName = assignment.cabin?.comPort?.name;

    // 1. Yönetim kartını bul
    yield const DrawerOpeningWithStep(step: MasterDrawerOpeningStep.devicePreparing);

    final ManagementCard manager;
    try {
      manager = await _scanManager(targetPort: portName);
    } on CabinConnectionException catch (e) {
      yield DrawerFailed(
        failure: e.failure == CabinConnectionFailure.managerNotFound
            ? MasterDrawerFailure.managerNotFound
            : MasterDrawerFailure.managerConnectFailed,
        detail: e.detail,
      );
      return;
    }

    // 2. Açma komutunu gönder
    // Kübik için hedef adres HER ZAMAN DrawerAddress.cubicMaster(row) —
    // hangi göz/step olduğuna bakılmaksızın sabit ana kilit adresidir.
    yield const DrawerOpeningWithStep(step: MasterDrawerOpeningStep.lockOpening);

    try {
      if (isSerum) {
        await _cabinOps.openMasterSerumDrawer(manager: manager, row: address.row);
      } else if (isKubik) {
        final monitorAddress = DrawerAddress.cubicMaster(address.row);
        await _cabinOps.openMasterDrawer(
          manager: manager,
          row: monitorAddress.row,
          port: monitorAddress.port,
          drawer: monitorAddress.index,
        );
      } else {
        await _cabinOps.openMasterDrawer(manager: manager, row: address.row, port: address.port, drawer: address.index);
      }
    } catch (e) {
      // openMasterDrawer/openMasterSerumDrawer donanımdan olumsuz yanıt
      // (no/nc/ht/hz) aldığında throw eder — komut baştan reddedildi demektir.
      yield DrawerFailed(failure: MasterDrawerFailure.lockOpenFailed, detail: e.toString());
      return;
    }

    // 3. Fiziksel açılmayı sensörden doğrula
    // Komut kabul edilmiş olması ("ok") çekmecenin FİZİKSEL olarak
    // tamamen açıldığı anlamına gelmez — bu adım o doğrulamayı yapar.
    yield const DrawerWaitingForPull();

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

    try {
      await for (final status in sensorStream.timeout(_fullyOpenTimeout)) {
        // Donanımla iletişim koptuysa (bkz. CabinOperationService.
        // streamMasterDrawerStatus - art arda başarısız poll sonrası) hedef
        // duruma hiçbir zaman ulaşamayacağız - 10sn'lik dış limiti beklemeden
        // hemen hata veriyoruz.
        if (status == DrawerPhysicalStatus.timeoutError) {
          yield DrawerFailed(
            failure: MasterDrawerFailure.sensorCommunicationLost,
            detail: contextlessL10n().hw_cabinOps_sensorLostDuringOpenDetail,
          );
          return;
        }

        // Kübikte SADECE tam açık ("h3") kabul edilir - yarım açık ("h2")
        // durumda kapaklar donanım tarafından reddedilir (bkz. protokol:
        // "Çekmece açık değil iken kübik aç komutu gelirse açılamaz").
        // Standartta ise kısmi açılma da işlem yapılabilir sayılır.
        final isTargetReached = isKubik
            ? status == DrawerPhysicalStatus.fullyOpen
            : (status == DrawerPhysicalStatus.fullyOpen || status == DrawerPhysicalStatus.halfOpen);

        if (isTargetReached) break;
      }
    } on TimeoutException {
      // sensorStream 10 saniye boyunca HİÇ olay yaymadıysa (beklenmedik -
      // normalde streamMasterDrawerStatus her zaman bir şey yield eder,
      // ama bu son bir güvenlik ağı) buraya düşer.
      yield DrawerFailed(
        failure: MasterDrawerFailure.lockOpenTimeout,
        detail: contextlessL10n().hw_cabinOps_fullyOpenTimeoutDetail(_fullyOpenTimeout),
      );
      return;
    }

    yield const DrawerOpened();
  }
}
