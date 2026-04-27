import '../../model/control_card.dart';
import '../../model/drawer_status.dart';
import '../../model/management_card.dart';

// apps/pharmed-client/lib/core/hardware/service/i_cabin_operation_service.dart
// [SWREQ-HW-001] Kabin donanım operasyon servisi arayüzü

/// KABİN OPERASYON SERVİSİ INTERFACE'İ
/// ------------------------------------
/// Fiziksel kabin donanımıyla (seri port üzerinden) tüm etkileşimi soyutlar.
/// Yönetim/kontrol kartı tarama, çekmece açma/kapama ve sensör izleme
/// işlemlerini tanımlar.
///
/// İKİ İMPLEMENTASYON:
///   - CabinOperationService: Gerçek seri port haberleşmesi (prod/dev)
///   - MockCabinOperationService: Simülasyon (mock flavor)
///
/// KABİN TİPLERİ:
///   - Master kabin: ManagementCard + slave ControlCard'lar
///     unlockSerum / monitorSerumStatus  →  eski master akışı
///   - Mobil kabin: Bağımsız serum kartı (master gibi davranır)
///     unlockSerumPort / monitorSerumPortStatus  →  yeni mobil akış
abstract interface class ICabinOperationService {
  /// Devam eden bir sensör izleme akışını dışarıdan keser.
  void triggerManualClose();

  /// Yönetim kartını getirir.
  /// Cache'te varsa onu döner, yoksa tarama yapıp cache'ler.
  /// [targetPort]: Bağlanılacak COM port (varsayılan: "COM3")
  Future<ManagementCard?> getOrScanManager({String? targetPort});

  /// 1'den 16'ya kadar (a-p) tüm adresleri tarayarak yönetim kartını bulur.
  /// Serum kartı da aynı protokole yanıt verdiği için bu metod onu da bulur.
  Future<ManagementCard?> findManagementCard();

  /// Yönetim kartına bağlı tüm kontrol kartlarını tarar.
  Future<List<ControlCard>> findControlCards(ManagementCard manager);

  /// Cihaza ham komut gönderir (satır seçimi + payload).
  Future<String?> sendCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  });

  // ── Master Kabin — Standart Çekmece ───────────────────────────

  /// Standart çekmece kilidini açar.
  Future<void> unlockDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  });

  /// Kübik çekmece kapağını açar.
  Future<void> openCubic({required ManagementCard manager, required int row, required int port, required int lidIndex});

  /// Standart çekmece sensör durumunu izler.
  Stream<DrawerPhysicalStatus> monitorDrawerStatus({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  });

  // ── Master Kabin — Serum (Eski Akış) ──────────────────────────

  /// Master kabinde serum çekmecesini açar.
  /// Serum kartı master'a slave olarak bağlıdır.
  Future<void> unlockSerum({required ManagementCard manager, required int row});

  /// Master kabinde serum sensör durumunu izler.
  Stream<DrawerPhysicalStatus> monitorSerumStatus({required ManagementCard manager, required int row});

  // ── Mobil Kabin — Bağımsız Serum Kartı (Yeni Akış) ────────────

  /// Mobil kabinde serum kartının belirtilen portundaki kilidi açar.
  ///
  /// Serum kartı standalone modda master gibi davranır:
  ///   1. row=26 ile slave moda alınır  →  :Y{addr}26{chk};
  ///   2. drawer=0 ile port açılır      →  :TO{port}00{chk};
  ///
  /// [manager]: findManagementCard() ile bulunan serum kartı
  /// [port]:    Açılacak port numarası (1-4)
  Future<void> unlockSerumPort({required ManagementCard manager, required int port});

  /// Mobil kabinde serum kartı port durumunu izler.
  ///
  /// Fiziksel kapanma polling ile yakalanır — kapat komutu gönderilmez.
  /// h3 → açık (kullanıcı henüz kapatmadı)
  /// h4 → kapatıldı ✅
  /// h0 → kilitlendi ✅
  ///
  /// [manager]: findManagementCard() ile bulunan serum kartı
  /// [port]:    İzlenecek port numarası (1-4)
  Stream<DrawerPhysicalStatus> monitorSerumPortStatus({required ManagementCard manager, required int port});
}
