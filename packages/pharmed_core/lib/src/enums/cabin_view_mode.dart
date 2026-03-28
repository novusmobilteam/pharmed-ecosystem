// İlaç Atama, Kabin Dizayn, Arıza Bildirimi gibi durumlarda aynı [CabinDrawerView] widgetını
// çiziyoruz fakat farklı [DrawerCell] kullanıyoruz.
enum CabinViewMode {
  /// Stok atama, düzenleme ve görüntüleme modu (Varsayılan).
  /// Hücreye tıklanınca ilaç eklenir/düzenlenir.
  assignment,

  /// Sadece kabin fiziksel yapısını gösterme modu.
  /// İçerik boştur, tıklama kapalıdır veya sadece "Burası X nolu göz" der.
  viewOnly,

  /// Arıza bildirim modu.
  /// Hücreye tıklanınca "Arıza Bildir" dialogu açılır.
  /// Görsel olarak arızalı olanlar farklı renkte (örn. kırmızı çizgili) görünür.
  maintenance,

  /// Stok sayım modu (Opsiyonel gelecek için).
  /// Sadece miktar girmeye odaklıdır.
  counting,

  /// Stok gösterim metodu
  stock,
}
