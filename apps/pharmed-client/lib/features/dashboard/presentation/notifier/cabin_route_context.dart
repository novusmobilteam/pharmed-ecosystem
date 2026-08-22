import 'package:pharmed_core/pharmed_core.dart';

/// Kabin-scoped route'lara (dolum, sayım, alım, iade, fire/imha, arıza vb.)
/// geçilen ortak bağlam. `DashboardContentFactory`'nin switch bloğunda her
/// operasyon view'ına tek tek menu/cabinData/deviceMode/cabin geçmek yerine
/// bu sınıf kullanılır — yeni bir ortak alan gerektiğinde (örn. istasyon
/// bilgisi) TÜM view constructor'larını değiştirmek yerine sadece burası
/// güncellenir.
class CabinRouteContext {
  const CabinRouteContext({required this.menu, required this.cabinData, required this.deviceMode});

  final MenuItem menu;
  final CabinVisualizerData? cabinData;

  /// Bu FİZİKSEL CİHAZIN kendi tipi (master/mobile) — navigasyon kararları
  /// için kullanılır (bkz. DashboardNotifier.navigateTo mobile-skip mantığı).
  /// cabinData.cabin.type İLE KARIŞTIRILMAMALI: o, o an SEÇİLİ olan kabinin
  /// tipidir (örn. bir master istasyondan "Buzdolabı-1" seçilmiş olabilir),
  /// deviceMode ise cihazın kendisinin sabit tipidir.
  final CabinType? deviceMode;

  /// cabinData artık Cabin'i kendi içinde taşıdığı için ayrı bir `cabin`
  /// parametresi geçmeye gerek yok.
  Cabin? get cabin => cabinData?.cabin;
}
