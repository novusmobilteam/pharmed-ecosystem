// [SWREQ-HW-001] [IEC 62304 §5.5]
// Kabin donanım operasyonları interface'i.
//
// KAPSAM:
//   Bu interface fiziksel kabin donanımıyla olan TÜM etkileşimi soyutlar.
//   Seri port üzerinden yönetim kartı + kontrol kartlarıyla haberleşir.
//
// DONANIM MİMARİSİ:
//   ┌─────────────────────────────────────────────────────┐
//   │  Yönetim Kartı (ManagementCard)                     │
//   │  • RS485 bus üzerinde 1-16 arası adreslenebilir     │
//   │  • Kontrol kartlarını satır (row) bazında seçer     │
//   │  • row=0  → tarama/ping komutu                      │
//   │  • row=N  → N. satırdaki kontrol kartını aktif et   │
//   │  • row=26 → serum kartını slave moda al             │
//   └─────────────────┬───────────────────────────────────┘
//                     │ RS485
//         ┌───────────┴────────────┐
//         ▼                        ▼
//   ┌───────────────┐      ┌───────────────────┐
//   │ Kontrol Kartı │      │ Serum Kartı        │
//   │ (Master Kabin)│      │ (Mobil Kabin)      │
//   │ • port 1-8    │      │ • port 1-8         │
//   │ • drawer 1-N  │      │ • drawer sabit = 0 │
//   └───────────────┘      └───────────────────┘
//
// KABİN TİPİ BAĞLANTISI:
//   Master kabin → Kontrol kartı → openMasterDrawer / streamMasterDrawerStatus
//   Mobil kabin  → Serum kartı   → openMobileDrawer / streamMobileDrawerStatus
//
// PROTOKOL ÖZETI:
//   Yönetim komutu : :Y{addr}{row:02d}{chk};   chk = (Y+addr+row) % 10
//   Çekmece komutu : :T{action}{port}{drwr:02d}{chk};  chk = (T+action+port+drawer) % 10
//   Action kodları : O=aç, S=durum, M=ping/tip
//   Cevaplar       : .ok / .no / .h0 / .h3 / .h4
//
// Sınıf: Class B

import '../../model/control_card.dart';
import '../../model/drawer_status.dart';
import '../../model/management_card.dart';

abstract interface class ICabinOperationService {
  // ════════════════════════════════════════════════════════════════
  // BAĞLANTI YÖNETİMİ
  // ════════════════════════════════════════════════════════════════

  /// Seri port bağlantısını tetikler.
  ///
  /// AMAÇ: Kabin donanımıyla haberleşmeden önce bağlantının
  /// kurulmasını sağlar. Zaten bağlıysa tekrar bağlanmaz.
  ///
  /// BAĞIMLILIK: Diğer tüm metodlar çağrılmadan önce bu metod
  /// veya [getOrScanManager] çağrılmış olmalıdır.
  void triggerManualClose();

  // ════════════════════════════════════════════════════════════════
  // YÖNETİM KARTI
  // ════════════════════════════════════════════════════════════════

  /// Yönetim kartını cache'den döner, yoksa RS485 bus'ı tarayarak bulur.
  ///
  /// AMAÇ: Tüm çekmece operasyonlarında gerekli olan [ManagementCard]
  /// referansını edinmek için kullanılır. Sonuç önbelleğe alınır.
  ///
  /// PROTOKOL:
  ///   1. [_serialService.isConnected] false ise [targetPort] üzerinden bağlanır
  ///   2. Cache doluysa direkt döner
  ///   3. Cache boşsa [scanManagementCard] çağırır
  ///
  /// [targetPort]: Bağlantı denemesi yapılacak COM port (örn. 'COM3').
  ///   null gelirse 'COM3' varsayılan olarak kullanılır.
  ///
  /// Returns: Bulunan [ManagementCard], bulunamazsa null.
  Future<ManagementCard?> getOrScanManager({String? targetPort});

  /// RS485 bus'ı 1-16 arası adresler tarayarak yönetim kartını bulur.
  ///
  /// AMAÇ: Cache'e bağımlı olmadan donanımdan taze yönetim kartı
  /// bilgisi edinmek. Genellikle setup wizard'ın ilk adımında kullanılır.
  ///
  /// PROTOKOL:
  ///   Her adres (1-16) için:
  ///     TX: :Y{addr}00{chk};   (row=0 → ping)
  ///     RX: 'ok' veya '+ok-' içeriyorsa → kart bulundu
  ///
  /// Returns: Bulunan [ManagementCard], hiçbir adreste yanıt yoksa null.
  ///
  /// HATA: Seri port bağlı değilse [SerialPortException] fırlatır.
  Future<ManagementCard?> scanManagementCard();

  // ════════════════════════════════════════════════════════════════
  // KONTROL KARTLARI (MASTER KABİN)
  // ════════════════════════════════════════════════════════════════

  /// Yönetim kartına bağlı tüm kontrol kartlarını keşfeder.
  ///
  /// AMAÇ: Master kabin kurulumunda fiziksel çekmece yapısını
  /// otomatik algılamak. Her kontrol kartı bir çekmece grubuna karşılık gelir.
  ///
  /// PROTOKOL:
  ///   Her satır (row=1..26) için:
  ///     1. TX: :Y{addr}{row:02d}{chk};  → satırı seç
  ///     2. RX: 'ok' içeriyorsa → satırda kart var
  ///     3. TX: :TM0101{chk};  → kart tipini sorgula (ping/type)
  ///     4. RX: '.{typeCode},' formatında → [ControlCard] oluştur
  ///
  /// AKIŞ:
  ///   • Her satır için 2 deneme yapılır (donanım gecikmeleri için)
  ///   • Tip sorgusunda 3 deneme yapılır
  ///   • Yanıt gelmeyen satırlar atlanır
  ///
  /// Returns: Bulunan [ControlCard] listesi. Boş liste dönebilir.
  ///
  /// BAĞIMLILIK: [scanManagementCard] veya [getOrScanManager] ile
  ///   [ManagementCard] edinilmiş olmalıdır.
  Future<List<ControlCard>> discoverControlCards(ManagementCard manager);

  // ════════════════════════════════════════════════════════════════
  // MOBİL KABİN — ÇEKMECE OPERASYONLARI
  // ════════════════════════════════════════════════════════════════

  /// Mobil kabindeki belirtilen portu açar (solenoid kilidi serbest bırakır).
  ///
  /// AMAÇ: Dolum/boşaltma işlemi sırasında kullanıcının ilgili
  /// çekmeceye fiziksel erişimini sağlamak.
  ///
  /// DONANIM: Serum kartı, row=26 (slave mod), drawer=0 sabit.
  ///
  /// PROTOKOL:
  ///   1. Serum kartını slave moda al:
  ///        TX: :Y{addr}26{chk};
  ///        RX: 'ok' içermiyorsa → [SerialPortException]
  ///   2. Port kilidini aç:
  ///        TX: :TO{port}00{chk};   (O=aç, drawer=00)
  ///        RX: '.ok' veya 'ok' → başarılı
  ///            diğer            → [SerialPortException]
  ///
  /// [manager]: Yönetim kartı referansı ([getOrScanManager] ile edinilir).
  /// [port]: Açılacak port numarası (1-8 arası).
  ///
  /// HATA:
  ///   • Slave mod seçimi başarısız → [SerialPortException]
  ///   • Açma komutuna '.ok' dışı yanıt → [SerialPortException]
  ///   • Seri port bağlı değil → [SerialPortException]
  Future<void> openMobileDrawer({required ManagementCard manager, required int port});

  /// Mobil kabin çekmece durumunu tek seferlik sorgular.
  ///
  /// AMAÇ: [DiscoverMobilePortsUseCase] gibi use case katmanında
  /// polling döngüsü kurmak için kullanılır. Stream versiyonundan
  /// farklı olarak tek bir istek/cevap döngüsü yapar.
  ///
  /// PROTOKOL:
  ///   1. Serum kartını slave moda al: :Y{addr}26{chk};
  ///   2. Durum sorgula: :TS{port}00{chk};
  ///   RX: 'h3' → [DrawerPhysicalStatus.fullyOpen]
  ///       'h4' → [DrawerPhysicalStatus.locked]
  ///       'h0' → [DrawerPhysicalStatus.locked]
  ///
  /// [manager]: Yönetim kartı referansı.
  /// [port]: Sorgulanacak port numarası (1-8 arası).
  ///
  /// Returns: Anlık [DrawerPhysicalStatus]. Hata durumunda [unknown].
  Future<DrawerPhysicalStatus> getMobileDrawerStatus({required ManagementCard manager, required int port});

  /// Mobil kabin çekmece durumunu sürekli izleyen stream.
  ///
  /// AMAÇ: Dolum işlemi sırasında çekmeceyi fiziksel olarak
  /// kapatan kullanıcıyı tespit etmek. "Dolumu Tamamla" butonu
  /// ancak çekmece kapandıktan sonra aktif hale gelir.
  ///
  /// DONANIM: Serum kartı, row=26, drawer=0 sabit.
  ///
  /// PROTOKOL (her polling döngüsünde):
  ///   1. Serum kartını slave moda al:
  ///        TX: :Y{addr}26{chk};
  ///        RX: 'ok' içermiyorsa → [DrawerPhysicalStatus.unknown] yayınla
  ///   2. Durum sorgula:
  ///        TX: :TS{port}00{chk};  (S=durum, drawer=00)
  ///        RX: 'h3' → açık      → [DrawerPhysicalStatus.fullyOpen]
  ///            'h4' → kapatıldı → [DrawerPhysicalStatus.locked]
  ///            'h0' → kilitlendi → [DrawerPhysicalStatus.locked]
  ///            diğer → [DrawerPhysicalStatus.unknown]
  ///
  /// POLLING ARALIĞI: [DeviceConstants.statusPollingInterval] (varsayılan 500ms)
  ///
  /// ⚠️ Stream SONLANMAZ — caller tarafında iptal edilmelidir.
  ///   Notifier dispose edildiğinde StreamSubscription.cancel() çağrılmalıdır.
  ///
  /// [manager]: Yönetim kartı referansı.
  /// [port]: İzlenecek port numarası (1-8 arası).
  ///
  /// Yields: Durum değiştikçe [DrawerPhysicalStatus] değerleri.
  Stream<DrawerPhysicalStatus> streamMobileDrawerStatus({required ManagementCard manager, required int port});

  // ════════════════════════════════════════════════════════════════
  // MASTER KABİN — ÇEKMECE OPERASYONLARI
  // ════════════════════════════════════════════════════════════════

  /// Master kabindeki standart çekmeceyi açar.
  ///
  /// AMAÇ: Master kabin dolum/boşaltma işlemlerinde ilgili
  /// çekmece gözünü fiziksel olarak açmak.
  ///
  /// DONANIM: Kontrol kartı, belirtilen row/port/drawer adresinde.
  ///
  /// PROTOKOL:
  ///   1. Satırı seç:
  ///        TX: :Y{addr}{row:02d}{chk};
  ///        RX: 'ok' içermiyorsa → [SerialPortException]
  ///   2. Çekmeceyi aç:
  ///        TX: :TO{port}{drawer:02d}{chk};
  ///        RX: [DeviceConstants.responseOk] içeriyorsa → başarılı
  ///            diğer → [SerialPortException]
  ///
  /// [manager]: Yönetim kartı referansı.
  /// [row]: Kontrol kartının satır adresi (1-26 arası).
  /// [port]: Kontrol kartındaki port numarası.
  /// [drawer]: Port altındaki çekmece numarası.
  ///
  /// HATA:
  ///   • Satır seçimi başarısız → [SerialPortException]
  ///   • Açma yanıtı beklenen değerde değil → [SerialPortException]
  Future<void> openMasterDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  });

  /// Master kabin kübik çekmeceyi açar.
  ///
  /// AMAÇ: Kübik çekmece tipindeki kapakları açmak.
  ///   Standart çekmeceden farklı bir komut yapısı kullanır.
  ///
  /// DONANIM: Kontrol kartı, kübik çekmece tipi.
  ///
  /// PROTOKOL:
  ///   1. Satırı seç (standart ile aynı)
  ///   2. Kübik aç komutu:
  ///        TX: [CommandBuilder.buildCubicCommand(O, port, lidIndex)]
  ///        150ms gecikme uygulanır (mekanik hareket için)
  ///
  /// [lidIndex]: Açılacak kapak indeksi (0-tabanlı).
  Future<void> openMasterCubicDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int lidIndex,
  });

  /// Master kabin çekmece durumunu sürekli izleyen stream.
  ///
  /// AMAÇ: Master kabin operasyonlarında çekmece fiziksel durumunu
  /// realtime izlemek. [streamMobileDrawerStatus] ile aynı kontratı paylaşır,
  /// yalnızca donanım adresleme ve yanıt parse mantığı farklıdır.
  ///
  /// DONANIM: Kontrol kartı, row/port/drawer ile adreslenir.
  ///
  /// PROTOKOL (her polling döngüsünde):
  ///   1. Satırı seç: :Y{addr}{row:02d}{chk};
  ///   2. Durum sorgula: :TS{port}{drawer:02d}{chk};
  ///   RX parse → [DeviceConstants] sabitlerinden eşleştirme:
  ///     rawFullyOpen / rawGeneralOpen → [DrawerPhysicalStatus.fullyOpen]
  ///     rawLocked / rawClosed        → [DrawerPhysicalStatus.locked]
  ///     rawUnlockedWaiting           → [DrawerPhysicalStatus.waitingPull]
  ///     rawHalfOpen                  → [DrawerPhysicalStatus.halfOpen]
  ///
  /// ⚠️ Stream SONLANMAZ — caller tarafında iptal edilmelidir.
  ///
  /// [row]: Kontrol kartının satır adresi.
  /// [port]: Port numarası.
  /// [drawer]: Çekmece numarası.
  Stream<DrawerPhysicalStatus> streamMasterDrawerStatus({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  });

  /// Master kabin serum çekmecesini açar.
  ///
  /// AMAÇ: Master kabine entegre serum çekmecesini açmak.
  ///   Mobil kabin serum kartından farklı olarak bu çekmece
  ///   kontrol kartı üzerinden adreslenir (port=1, drawer=0).
  ///
  /// DONANIM: Kontrol kartı, port=1, drawer=0 sabit.
  ///
  /// PROTOKOL:
  ///   1. Satırı seç
  ///   2. TX: :TO100{chk};  (port=1, drawer=00)
  ///   RX: 'ok' veya 'h3' içeriyorsa → başarılı
  ///
  /// [row]: Serum çekmecesinin bağlı olduğu satır adresi.
  Future<void> openMasterSerumDrawer({required ManagementCard manager, required int row});

  /// Master kabin serum çekmece durumunu izleyen stream.
  ///
  /// AMAÇ: Master kabindeki serum çekmecesinin açık/kapalı
  /// durumunu realtime izlemek.
  ///
  /// DONANIM: Kontrol kartı, port=1, drawer=0.
  ///
  /// PROTOKOL:
  ///   Her döngüde satır seç + :TS100{chk}; gönder
  ///   RX parse:
  ///     'h3' → [DrawerPhysicalStatus.fullyOpen]
  ///     'h4' → [DrawerPhysicalStatus.locked]
  ///     'h1' → [DrawerPhysicalStatus.waitingPull]
  ///
  /// ⚠️ Stream SONLANMAZ — caller tarafında iptal edilmelidir.
  Stream<DrawerPhysicalStatus> streamMasterSerumDrawerStatus({required ManagementCard manager, required int row});

  // ════════════════════════════════════════════════════════════════
  // GENEL KOMUT GÖNDERİMİ
  // ════════════════════════════════════════════════════════════════

  /// Belirli bir satıra seçim yapıp ham komut gönderir.
  ///
  /// AMAÇ: Standart operasyonlar dışında kalan özel komutlar için
  /// düşük seviyeli erişim noktası.
  ///
  /// PROTOKOL:
  ///   1. TX: :Y{addr}{row:02d}{chk};  → satır seç
  ///   2. TX: [commandPayload]          → komutu gönder
  ///
  /// [targetRow]: Hedef satır (0=ping, 1-26=kart satırları).
  /// [commandPayload]: Ham komut stringi (örn. ':TO1015;').
  ///
  /// Returns: Yanıt stringi, timeout veya hata durumunda null.
  Future<String?> sendRawCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  });
}
