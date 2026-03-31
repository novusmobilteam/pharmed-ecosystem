// apps/pharmed-client/lib/core/hardware/service/i_cabin_operation_service.dart

import '../../model/control_card.dart';
import '../../model/drawer_status.dart';
import '../../model/management_card.dart';

/// KABİN OPERASYON SERVİSİ INTERFACE'İ
/// ------------------------------------
/// Fiziksel kabin donanımıyla (seri port üzerinden) tüm etkileşimi soyutlar.
/// Yönetim/kontrol kartı tarama, çekmece açma/kapama ve sensör izleme
/// işlemlerini tanımlar.
///
/// İKİ İMPLEMENTASYON:
///   - CabinOperationService: Gerçek seri port haberleşmesi (prod/dev)
///   - MockCabinOperationService: Simülasyon (mock flavor)
abstract interface class ICabinOperationService {
  /// Devam eden bir sensör izleme akışını dışarıdan keser.
  /// UI'dan "Kapat" / "Kaydet" aksiyonu tetiklendiğinde çağrılır.
  void triggerManualClose();

  /// Yönetim kartını getirir.
  /// Cache'te varsa onu döner, yoksa tarama yapıp cache'ler.
  /// [targetPort]: Bağlanılacak COM port (varsayılan: "COM3")
  Future<ManagementCard?> getOrScanManager({String? targetPort});

  /// 1'den 16'ya kadar (a-p) tüm adresleri tarayarak
  /// yönetim kartını bulur.
  Future<ManagementCard?> findManagementCard();

  /// Yönetim kartına bağlı tüm kontrol kartlarını tarar.
  /// Her satır (1-26) için tip sorgusu gönderir.
  Future<List<ControlCard>> findControlCards(ManagementCard manager);

  /// Cihaza ham komut gönderir (satır seçimi + payload).
  Future<String?> sendCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  });

  /// Standart çekmece kilidini açar.
  Future<void> unlockDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  });

  /// Kübik çekmece kapağını açar.
  Future<void> openCubic({required ManagementCard manager, required int row, required int port, required int lidIndex});

  /// Serum kabini kilidini açar.
  Future<void> unlockSerum({required ManagementCard manager, required int row});

  /// Standart çekmece sensör durumunu izler.
  /// Polling ile periyodik olarak durum sorgular.
  Stream<DrawerPhysicalStatus> monitorDrawerStatus({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  });

  /// Serum kabini sensör durumunu izler.
  Stream<DrawerPhysicalStatus> monitorSerumStatus({required ManagementCard manager, required int row});
}
