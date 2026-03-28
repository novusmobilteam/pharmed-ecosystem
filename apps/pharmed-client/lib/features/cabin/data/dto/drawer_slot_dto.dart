import 'cabin_dto.dart';
import 'drawer_config_dto.dart';

/// [ESKİ İSİM: CabinDesignDTO]
///
/// ÇEKMECE YUVASI / SLOT TANIMLAMASI
/// ----------------------------------------
/// Fiziksel kabin içerisindeki her bir çekmece pozisyonunu (slot) temsil eder.
/// Bu model, kabinin dikey dizilimindeki her bir satırı ve o satıra atanmış
/// teknik donanımı bir araya getirir.
///
/// BU MODEL NE İŞE YARAR?
/// 1. Kabin içindeki çekmecelerin sırasını (orderNumber) belirler.
/// 2. Belirli bir slottaki çekmecenin fiziksel adresini (address) tutar.
/// 3. O yuvaya takılı olan çekmecenin donanım konfigürasyonunu (drawerDetail) bağlar.
///
/// ANAHTAR ALANLAR:
/// - orderNumber: Kabindeki yukarıdan aşağıya dizilim sırası (1. çekmece, 2. çekmece vb.)
/// - address: Seri port üzerinden haberleşirken kullanılan fiziksel adres
/// - drawerDetail: Bu slotta bulunan çekmecenin motor ve step ayarları (DrawerHardwareDTO)
/// - compartmentNo: Eğer slot içinde alt bölümlendirme varsa onun sıra numarası
///
/// TABLO VERİLERİNE GÖRE ÖRNEKLER:
/// - orderNumber: 1, address: "1-1" → Kabinin en üstündeki ilk çekmece yuvası.
/// - drawerDetailId: 5 → Bu yuvada 5 ID'li donanım konfigürasyonu çalışıyor.
class DrawerSlotDTO {
  final int? id;
  final int? drawerConfigId; // DrawerHardwareDTO.id ile eşleşir
  final int? cabinId;
  final int? orderNumber; // Kabin içindeki dikey sıra numarası
  final String? address; // Fiziksel haberleşme adresi
  final int? compartmentNo; // Bölme numarası
  final int? drawrOrderNumber; // Çekmece içi sıralama
  final DrawerConfigDTO? drawerConfig; // İlişkili donanım ayarları (nested)
  final CabinDTO? cabin; // Bağlı olduğu kabin bilgisi
  final bool? isDeleted;
  final DateTime? createdDate;

  DrawerSlotDTO({
    this.id,
    this.drawerConfigId,
    this.cabinId,
    this.orderNumber,
    this.address,
    this.compartmentNo,
    this.drawrOrderNumber,
    this.drawerConfig,
    this.cabin,
    this.isDeleted,
    this.createdDate,
  });

  DrawerSlotDTO copyWith({
    int? id,
    int? drawerConfigId,
    int? cabinId,
    int? orderNumber,
    String? address,
    int? compartmentNo,
    int? drawrOrderNumber,
    DrawerConfigDTO? drawerConfig,
    CabinDTO? cabin,
  }) {
    return DrawerSlotDTO(
      id: id,
      drawerConfigId: drawerConfigId,
      cabinId: cabinId,
      orderNumber: orderNumber,
      address: address,
      compartmentNo: compartmentNo,
      drawrOrderNumber: drawrOrderNumber,
      drawerConfig: drawerConfig,
      cabin: cabin,
    );
  }

  factory DrawerSlotDTO.fromJson(Map<String, dynamic> json) {
    return DrawerSlotDTO(
      id: json['id'] as int?,
      drawerConfigId: json['drawrDetailId'] as int?,
      cabinId: json['cabinId'] as int?,
      orderNumber: json['orderNumber'] as int?,
      address: json['address'] as String?,
      compartmentNo: json['compartmentNo'] as int?,
      drawrOrderNumber: json['drawrOrderNumber'] as int?,
      drawerConfig: json['drawrDetail'] != null ? DrawerConfigDTO.fromJson(json['drawrDetail']) : null,
      cabin: json['cabin'] != null ? CabinDTO.fromJson(json['cabin']) : null,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
      isDeleted: json['isDeleted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'id': id,
      'drawrDetailId': drawerConfigId,
      'cabinId': cabinId,
      'orderNumber': orderNumber,
      'address': address,
      // 'compartmentNo': compartmentNo,
      // 'drawrOrderNumber': drawrOrderNumber,
      // 'drawerDetail': drawerConfig?.toJson(),
      // 'cabin': cabin?.toJson(),
    };
  }
}
