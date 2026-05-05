// [SWREQ-HW-002] [IEC 62304 §5.5]
// Mobil kabin port keşfi sonucu.
//
// [discoverMobileDrawerPorts] metodunun dönüş tipidir.
// Aktif port listesini ve henüz kapatılmayı bekleyen portları taşır.
//
// Sınıf: Class B

/// Mobil kabin port keşfi sonucu.
///
/// KULLANIM:
///   final result = await service.discoverMobileDrawerPorts(manager: mgr);
///
///   // Kaç aktif port bulundu?
///   print(result.activePorts.length);  // örn. 4
///
///   // Tüm portlar kapatıldı mı?
///   if (result.allClosed) {
///     // Wizard'da bir sonraki adıma geç
///   }
class PortDiscoveryResult {
  const PortDiscoveryResult({required this.activePorts, required this.pendingClosePorts});

  /// Açma komutuna '.ok' yanıtı veren port numaraları.
  /// Sıralı liste (1'den küçüğe doğru).
  final List<int> activePorts;

  /// Açıldı fakat henüz kullanıcı tarafından kapatılmadı.
  /// Keşif tamamlandıktan sonra bu liste boşalana kadar
  /// kullanıcıdan çekmeceleri kapatması beklenir.
  final List<int> pendingClosePorts;

  /// Aktif port sayısı.
  int get activePortCount => activePorts.length;

  /// Tüm açılan portlar kapatıldı mı?
  bool get allClosed => pendingClosePorts.isEmpty;

  /// Hiç aktif port bulunamadı mı?
  bool get isEmpty => activePorts.isEmpty;

  @override
  String toString() => 'PortDiscoveryResult(active: $activePorts, pendingClose: $pendingClosePorts)';
}
