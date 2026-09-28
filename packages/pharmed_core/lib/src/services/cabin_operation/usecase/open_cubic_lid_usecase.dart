// [SWREQ-CLI-CABIN-OP-012] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Kübik çekmecede TEK bir gözün kapağını açar (lid-by-lid akış).
///
/// **Ön koşul:** Ana çekmece (kübik master kilit — bkz.
/// [StartMasterDrawerSessionUseCase]) FİZİKSEL olarak tam açık ("h3")
/// olmalıdır. Bu use case bunu kendisi DOĞRULAMAZ — çağıran, session'ın
/// [MasterDrawerOpened] stage'ine geçtiğini gördükten sonra çağırmalıdır.
/// Ana çekmece tam açık değilken donanım "ht" ile reddeder; bu use case
/// bunu [MasterDrawerFailure.lidDrawerNotOpen] olarak sarmalar.
///
/// **Otomatik tekrar deneme:** Donanımın reddi ([CubicLidException]) önce
/// burada nedenine göre birkaç kez sessizce tekrar denenir; kullanıcıya
/// yalnızca denemeler tükendiğinde [MasterDrawerException] ulaşır:
///   - `ht` (drawerNotOpen)   → 1 tekrar, 500ms sonra (çekmece yerine oturuyor olabilir)
///   - `hz` (slaveNoResponse) → 2 tekrar, 200ms arayla
///   - `nc`/`no`/yanıt yok    → 1 tekrar, 200ms sonra
///
/// **Adres hesabı — neden master kilit adresinden FARKLI:**
/// [StartMasterDrawerSessionUseCase], kübik ana kilidi açarken SABİT bir
/// adres kullanır ([DrawerAddress.cubicMaster]). Burada ise [cellAssignment]
/// üzerinden [calculateAddressFromAssignment] ile GERÇEK göz adresi hesaplanır:
///   - `row`      → aynı fiziksel birim, master kilitle aynı satır
///   - `port`     → `cellAssignment.drawerUnit.compartmentNo` (1-4)
///   - `lidIndex` → `cellAssignment.drawerUnit.orderNo` (donanımdaki adı `index`)
/// Aynı hesap [MonitorCubicLidUseCase]'te de kullanılır — ikisi AYRIŞMAMALI.
class OpenCubicLidUseCase {
  const OpenCubicLidUseCase(this._scanManager, this._cabinOps);

  final ScanManagerUseCase _scanManager;
  final ICabinOperationService _cabinOps;

  /// Throws [CabinConnectionException] manager edinilemezse (bağlantı
  /// sorunu — kapak-özel değil, [MasterDrawerException]'a sarmalanmaz).
  /// Throws [MasterDrawerException] tekrar denemeler tükendiğinde:
  /// `lidDrawerNotOpen` ("ht") veya `lidOpenFailed` (diğer tüm nedenler).
  Future<void> call({required MedicineAssignment cellAssignment}) async {
    final manager = await _scanManager(targetPort: cellAssignment.cabin?.comPort?.name);
    final address = calculateAddressFromAssignment(cellAssignment);

    for (var attempt = 0; ; attempt++) {
      try {
        await _cabinOps.openMasterCubicDrawer(
          manager: manager,
          row: address.row,
          port: address.port,
          lidIndex: address.index,
        );
        return;
      } on CubicLidException catch (e) {
        final maxRetries = _autoRetryCount(e.failure);
        if (attempt >= maxRetries) {
          throw MasterDrawerException(_mapLidFailure(e.failure), detail: e.toString());
        }

        MedLogger.warn(
          unit: 'OpenCubicLid',
          swreq: 'SWREQ-CLI-CABIN-OP-012',
          message: 'Kübik kapak açılamadı, tekrar deneniyor',
          context: {
            'failure': e.failure.name,
            'detail': e.detail,
            'attempt': attempt + 1,
            'maxRetries': maxRetries,
            'row': address.row,
            'port': address.port,
            'lidIndex': address.index,
          },
        );
        await Future.delayed(_retryDelay(e.failure));
      } on CabinConnectionException {
        rethrow;
      } catch (e) {
        // Beklenmeyen hata (seri port vb.) — tekrar denenmez.
        throw MasterDrawerException(MasterDrawerFailure.lidOpenFailed, detail: e.toString());
      }
    }
  }

  static MasterDrawerFailure _mapLidFailure(CubicLidFailure failure) => switch (failure) {
    CubicLidFailure.drawerNotOpen => MasterDrawerFailure.lidDrawerNotOpen,
    CubicLidFailure.slaveNoResponse ||
    CubicLidFailure.protocolError ||
    CubicLidFailure.noResponse => MasterDrawerFailure.lidOpenFailed,
  };

  static int _autoRetryCount(CubicLidFailure failure) => switch (failure) {
    CubicLidFailure.drawerNotOpen => 1,
    CubicLidFailure.slaveNoResponse => 2,
    CubicLidFailure.protocolError || CubicLidFailure.noResponse => 1,
  };

  static Duration _retryDelay(CubicLidFailure failure) => switch (failure) {
    CubicLidFailure.drawerNotOpen => const Duration(milliseconds: 500),
    _ => const Duration(milliseconds: 200),
  };
}

class MasterDrawerException implements Exception {
  const MasterDrawerException(this.failure, {this.detail});

  final MasterDrawerFailure failure;
  final String? detail;
}
