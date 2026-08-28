import 'package:pharmed_core/pharmed_core.dart';

/// ÇEKMECE YUVASI ENTITY'Sİ
/// -------------------------
/// Kabindeki fiziksel bir çekmece pozisyonunu temsil eder.
/// Tarama sonucu veya manuel tanım ile oluşturulur.
/// DB'ye kaydedilen birincil entity budur.
///
/// İLİŞKİLER:
///   DrawerSlot.drawerConfigId → DrawerConfig.id
///   DrawerSlot.cabinId → Cabin.id
///   DrawerUnit.drawerSlotId → DrawerSlot.id
///
/// KULLANIM:
///   - Tarama sonucu: address + orderNumber + config otomatik atanır
///   - Kayıt: SaveCabinDesignUseCase slot listesini DB'ye yazar
///   - Layout: GetCabinLayoutUseCase slot'ları çekip DrawerGroup'a birleştirir
class DrawerSlot {
  const DrawerSlot({
    this.id,
    this.drawerConfigId,
    this.cabinId,
    this.orderNumber,
    this.address,
    this.compartmentNo,
    this.drawerOrderNumber,
    this.drawerConfig,
    this.cabin,
    this.isReturnDrawerHere,
    this.isPortReversed,
  });

  final int? id;
  final int? drawerConfigId; // DrawerConfig.id ile eşleşir
  final int? cabinId;
  final int? orderNumber; // Kabin içindeki dikey sıra (1, 2, 3, ...)
  final String? address; // Fiziksel haberleşme adresi ("01", "02", ...)
  final int? compartmentNo; // Bölme numarası
  final int? drawerOrderNumber; // Çekmece içi sıralama
  final DrawerConfig? drawerConfig; // İlişkili donanım konfigürasyonu (nested)
  final Cabin? cabin; // Bağlı olduğu kabin (nested, opsiyonel)

  /// Bu fiziksel çekmece (DrawerSlot) iade çekmecesi olarak tanımlı mı.
  /// true ise: alttaki tüm DrawerUnit'ler (gözler) artık bireysel
  /// ilaç ataması/dolum hedefi DEĞİLDİR — çekmece tek bir sanal iade
  /// kutusu olarak görselleştirilir ve açılışta kübik lid komutu
  /// GÖNDERİLMEZ, sadece çekmece açılır (bkz. master-drawer-operation).
  final bool? isReturnDrawerHere;

  /// Bu fiziksel çekmecenin (DrawerSlot) port kablolaması TERS bağlı mı.
  ///
  /// Normalde port numarası soldan sağa 1,2,3... artar. Bazı kurulumlarda
  /// (gözlemlenen: belirli birim doz kartları) fiziksel kablolama bunun
  /// TERSİNE yapılmış olabilir — port=1 komutu fiziksel olarak EN SAĞDAKİ
  /// gözü açar. Bu kurulum-özgü bir donanım gerçeğidir (aynı DrawerType/
  /// DrawerConfig farklı kabinlerde farklı yönde kablolanmış olabilir),
  /// bu yüzden DrawerType/DrawerConfig'te DEĞİL, burada (fiziksel slot
  /// seviyesinde) tutulur.
  ///
  /// true ise [calculateAddressFromAssignment], donanıma gönderilecek
  /// gerçek port numarasını `compartmentCount + 1 - rawPort` formülüyle
  /// çevirir — kullanıcı ekranda soldan sağa doğal sırayla görür/tıklar,
  /// donanıma giden komut kablolamaya göre otomatik düzeltilir.
  ///
  /// null/false → normal (ters çevirmeden).
  final bool? isPortReversed;

  DrawerSlot copyWith({
    int? id,
    int? drawerConfigId,
    int? cabinId,
    int? orderNumber,
    String? address,
    int? compartmentNo,
    int? drawerOrderNumber,
    DrawerConfig? drawerConfig,
    Cabin? cabin,
    bool? isReturnDrawerHere,
    bool? isPortReversed,
  }) {
    return DrawerSlot(
      id: id ?? this.id,
      drawerConfigId: drawerConfigId ?? this.drawerConfigId,
      cabinId: cabinId ?? this.cabinId,
      orderNumber: orderNumber ?? this.orderNumber,
      address: address ?? this.address,
      compartmentNo: compartmentNo ?? this.compartmentNo,
      drawerOrderNumber: drawerOrderNumber ?? this.drawerOrderNumber,
      drawerConfig: drawerConfig ?? this.drawerConfig,
      // cabin: cabin ?? this.cabin,
      isReturnDrawerHere: isReturnDrawerHere ?? this.isReturnDrawerHere,
      isPortReversed: isPortReversed ?? this.isPortReversed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DrawerSlot && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DrawerSlot(id: $id, cabinId: $cabinId, order: $orderNumber, address: $address)';
}
