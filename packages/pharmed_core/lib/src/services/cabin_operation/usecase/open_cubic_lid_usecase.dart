// [SWREQ-CLI-CABIN-OP-012] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Kübik çekmecede TEK bir gözün kapağını açar (lid-by-lid akış).
///
/// **Ön koşul:** Ana çekmece (kübik master kilit — bkz.
/// [StartMasterDrawerSessionUseCase]) FİZİKSEL olarak tam açık ("h3")
/// olmalıdır. Bu use case bunu kendisi DOĞRULAMAZ — çağıran, session
/// notifier'ın [MasterDrawerOpened] stage'ine geçtiğini gördükten sonra bu
/// fonksiyonu çağırmalıdır (bkz. `master-drawer-operation` skill §4-5).
/// Ana çekmece tam açık değilken kapak açma denenirse donanım "ht" (Çekmece
/// açık değilken kübik aç komutu gelirse açılamaz) ile reddeder; bu durumda
/// [openMasterCubicDrawer] artık throw eder ve bu fonksiyon bunu
/// [MasterDrawerFailure.lidOpenFailed] olarak sarmalar.
///
/// **Adres hesabı — neden master kilit adresinden FARKLI:**
/// [StartMasterDrawerSessionUseCase], kübik ana kilidi açarken SABİT bir
/// adres kullanır ([DrawerAddress.cubicMaster] — port=[DeviceConstants.
/// masterLockPort], drawer=[DeviceConstants.cubicMasterDrawerId]); hangi
/// gözde işlem yapılacağının o adımda önemi yoktur, tek bir fiziksel kilit
/// vardır. Burada ise [cellAssignment] üzerinden [calculateAddressFromAssignment]
/// çağrılır ve GERÇEK göz adresi hesaplanır:
///   - `row`  → aynı fiziksel birim, master kilitle aynı satır
///   - `port` → `cellAssignment.drawerUnit.compartmentNo` (kübik ünitenin
///     kendi port numarası, 1-4 arası — [DeviceConstants.masterLockPort]
///     ile KARIŞTIRILMAMALI, farklı bir adres alanı)
///   - `lidIndex` (donanımdaki adı `index`) → `cellAssignment.drawerUnit.orderNo`
///     (açılacak GÖZÜN kendi sıra no'su, 0-4 arası)
/// `requestedQuantity`/`explicitTargetStep` parametreleri kübik dalında hiç
/// kullanılmaz (bkz. [calculateAddressFromAssignment] — `isKubik` dalı
/// doğrudan `orderNo`'yu kullanır), bu yüzden burada hiç geçilmiyor.
class OpenCubicLidUseCase {
  const OpenCubicLidUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  /// [cellAssignment]: açılacak GÖZE ait atama (drawer'ın kendisine değil —
  /// çoklu göz senaryosunda her göz için bu fonksiyon ayrı ayrı, ayrı
  /// [cellAssignment] ile çağrılır).
  ///
  /// Throws [CabinConnectionException] manager edinilemezse (yönetim
  /// kartına hiç ulaşılamadı — bu, kapak-özel bir hata değil, bağlantı
  /// sorunudur, bu yüzden [MasterDrawerException]'a sarmalanmaz).
  /// Throws [MasterDrawerException] (failure: lidOpenFailed) kapak açma
  /// komutu donanım tarafından reddedilirse (örn. ana çekmece tam açık
  /// değilken — "ht" — veya checksum/iletişim hatası — "no"/"nc"/"hz").
  Future<void> call({required MedicineAssignment cellAssignment}) async {
    final manager = await _scanManager(targetPort: cellAssignment.cabin?.comPort?.name);

    final address = calculateAddressFromAssignment(cellAssignment);
    try {
      await _cabinOps.openMasterCubicDrawer(
        manager: manager,
        row: address.row,
        port: address.port,
        lidIndex: address.index,
      );
    } catch (e) {
      throw MasterDrawerException(MasterDrawerFailure.lidOpenFailed, detail: e.toString());
    }
  }
}

class MasterDrawerException implements Exception {
  const MasterDrawerException(this.failure, {this.detail});

  final MasterDrawerFailure failure;
  final String? detail;
}
