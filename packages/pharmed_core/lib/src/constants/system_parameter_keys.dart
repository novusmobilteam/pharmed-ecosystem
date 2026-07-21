/// Backend'deki `SystemParameter.key` değerlerinin tek toplandığı yer.
/// Görünümlerde ("GeneralSettingsView" vb.) ham string yerine bu sabitler
/// kullanılır — yazım hatalarını derleme zamanında yakalamak ve tüm
/// kullanım yerlerini tek noktadan izleyebilmek için.
abstract final class SystemParameterKeys {
  /// Order Detay Listeleme işleminde kullanılan zaman aralığı (+- saat).
  static const collectOrderTime = 'CollectOrderTime';

  /// İlaç alımından sonra Fire/İmha yapma süresi (+- saat).
  static const wasteDestructionTime =
      'WasteDescrutionTime'; // NOT: backend'deki yazım hatası ("Descrution") korunmuştur.

  /// Fire yapılan malzemenin ilgili order'a tekrar düşüp düşmeyeceği. 1: düşsün, 0: düşmesin.
  static const wasteOrderMayItFall = 'WasteOrderMayItFall';

  /// Birim doz çekmecelerde hücre bazlı SKT girişi. 1: açık, 0: kapalı.
  static const miadDate = 'MiadDate';

  /// Yönetici kartı ile girişte şifre istenip istenmeyeceği. 1: istensin, 0: istenmesin.
  static const manageCard = 'ManageCard';
}
