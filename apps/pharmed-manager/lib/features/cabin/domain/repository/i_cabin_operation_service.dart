import '../../../../core/core.dart';
import '../entity/management_card.dart';

abstract class ICabinOperationService {
  void triggerManualClose();

  /// Master kartı getirir.
  /// Eğer cache'te varsa onu döner, yoksa tarama yapıp bulduğunu cache'ler.
  Future<ManagementCard?> getOrScanManager({String? targetPort});

  /// 1'den 16'ya kadar (a-p) tüm adresleri dener.
  /// Satır 0 (boş seçim) göndererek sadece yönetim kartının
  /// orada olup olmadığını kontrol eder.
  Future<ManagementCard?> findManagementCard();

  /// Master karta bağlı slave kartları bulur
  Future<List<ControlCard>> findControlCards(ManagementCard manager);

  /// Cihaza komut gönderir
  Future<String?> sendCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  });

  Future<void> unlockDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  });

  Future<void> openCubic({
    required ManagementCard manager,
    required int row,
    required int port,
    required int lidIndex,
  });

  Future<void> unlockSerum({
    required ManagementCard manager,
    required int row,
  });

  Stream<DrawerPhysicalStatus> monitorDrawerStatus({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  });

  Stream<DrawerPhysicalStatus> monitorSerumStatus({
    required ManagementCard manager,
    required int row,
  });
}
