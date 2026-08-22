import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

/// İstasyon genelinde, TEK bir kabine bağlı olmayan route'lara (reçete
/// inceleme, uygulanmamış reçeteler, günlük iş listesi) geçilen bağlam.
///
/// CabinRouteContext'ten FARKI: o, kullanıcının kabin seçim ekranında
/// SEÇTİĞİ tek bir kabini taşır (_cabinScopedRoutes). Bu sınıf ise hiç
/// kabin seçimi yapılmayan route'lar için — buradaki ekranların her
/// satırı/kartı FARKLI bir fiziksel kabine ait olabilir (örn. bir reçete
/// kalemi Buzdolabı-1'den, bir diğer kalem Narkotik Kabinden çıkabilir),
/// bu yüzden TEK kabin verisi yeterli değil — istasyondaki TÜM kabinlerin
/// haritası geçilir, ekran her item'ın kendi cabinId'siyle haritadan ilgili
/// veriyi kendi içinde çözer.
class StationCabinsContext {
  const StationCabinsContext({
    required this.menu,
    required this.cabinDataByCabinId,
    required this.cabins,
    this.station,
    this.deviceMode,
  });

  final MenuItem menu;
  final Map<int, CabinVisualizerData> cabinDataByCabinId;
  final List<Cabin> cabins;
  final Station? station;
  final CabinType? deviceMode;

  /// Verilen cabinId için görselleştirme verisi — bulunamazsa null
  /// (henüz yüklenmemiş / o kabin başarısız olmuş olabilir, çağıran taraf
  /// item bazında "kabin verisi yok" göstermeli, TÜM EKRANI BLOKLAMAMALI).
  CabinVisualizerData? dataFor(int? cabinId) => cabinId != null ? cabinDataByCabinId[cabinId] : null;

  Cabin? cabinFor(int? cabinId) => cabinId != null ? cabins.firstWhereOrNull((c) => c.id == cabinId) : null;

  Cabin? get masterCabin => cabins.firstWhereOrNull((c) => c.type == CabinType.master);
}
