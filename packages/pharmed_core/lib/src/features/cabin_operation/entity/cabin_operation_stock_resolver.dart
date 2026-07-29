// [SWREQ-CORE-CABINOP-001] [IEC 62304 §5.5]
//
// Bir MedicineAssignment'ın stok kayıtlarını (CabinStock listesi) okuyup
// CabinOperationTarget'ın başlangıç değerlerine çevirir. İki geometriyi
// bilir: kübik çekmece (tek stok kaydı, tek göz) ve birim doz çekmece
// (numberOfSteps kadar göz, her göz kendi stok kaydına `corpartmentNo`
// üzerinden eşlenir).
//
// Ham backend miktarını gösterim değerine çevirme işini KENDİSİ yapmaz —
// çağırandan bir `countConverter` fonksiyonu alır ve her okuduğu miktarı
// bu fonksiyondan geçirir. Böylece bu sınıf "hangi birim kullanılıyor"
// sorusundan tamamen bağımsız kalır, sadece "stoktan göze nasıl gidilir"
// sorusuna cevap verir.
//
// Miad kuralı: bir stok kaydının miad'ı, yalnızca o kayıtta pozitif miktar
// varsa anlamlıdır — sıfır/negatif miktarlı bir kayıttaki miad göz ardı
// edilir (boş bir gözün eski/anlamsız bir tarih taşımasını önler).
//
// Kullanım: kübik çekmece için `resolveKubik`, birim doz çekmece için
// `resolveSteps` çağrılır; `CabinOperationTarget.fromAssignment` ikisini de
// `isKubik` bayrağına göre seçer.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Kübik bir çekmecenin tek gözü için çözümlenmiş stok değeri.
class CabinOperationKubikStock {
  const CabinOperationKubikStock({required this.count, required this.miadDate});

  /// Gösterim birimine çevrilmiş miktar (`countConverter` sonrası).
  final double count;
  final DateTime? miadDate;
}

/// Birim doz çekmecesinin tek bir gözü için çözümlenmiş stok değeri.
class CabinOperationStepStock {
  const CabinOperationStepStock({required this.index, required this.count, required this.miadDate});

  /// Gözün 0 tabanlı index'i (`CabinOperationStepEntry` listesindeki yeri).
  final int index;

  /// Gösterim birimine çevrilmiş miktar (`countConverter` sonrası).
  final double count;
  final DateTime? miadDate;
}

abstract final class CabinOperationStockResolver {
  /// Kübik çekmecenin tek stok kaydını okur. Assignment'ın hiç stok kaydı
  /// yoksa ya da toplam miktar sıfırsa miad `null` döner (gösterilecek
  /// anlamlı bir SKT yok).
  static CabinOperationKubikStock resolveKubik({
    required MedicineAssignment assignment,
    required double Function(double raw) countConverter,
  }) {
    final stocks = assignment.stocks ?? const <CabinStock>[];
    final hasStock = stocks.isNotEmpty;
    final rawQty = assignment.totalQuantity.toDouble();
    final miad = rawQty > 0 ? (hasStock ? stocks.first.miadDate : null) : null;
    return CabinOperationKubikStock(count: countConverter(rawQty), miadDate: miad);
  }

  /// Birim doz çekmecesinin tüm stok kayıtlarını gözlere dağıtır
  /// (`corpartmentNo - 1` → göz index'i). `numberOfSteps` sınırının dışına
  /// düşen kayıtlar atlanır (tutarsız/eski veri koruması). Ayrıca, pozitif
  /// miktarlı kayıtlar arasındaki EN ERKEN miad'ı da döner — bu değer,
  /// tek-SKT (`singleMiad`) fallback'inin başlangıç değeri olarak kullanılır.
  static (List<CabinOperationStepStock> steps, DateTime? earliestMiad) resolveSteps({
    required MedicineAssignment assignment,
    required int numberOfSteps,
    required double Function(double raw) countConverter,
  }) {
    final stocks = assignment.stocks ?? const <CabinStock>[];
    final result = <CabinOperationStepStock>[];
    DateTime? earliestMiad;

    for (final stock in stocks) {
      final index = (stock.corpartmentNo ?? 0) - 1;
      if (index < 0 || index >= numberOfSteps) continue;

      final rawQty = (stock.quantity ?? 0).toDouble();
      final miad = (stock.quantity ?? 0) > 0 ? stock.miadDate : null;

      result.add(CabinOperationStepStock(index: index, count: countConverter(rawQty), miadDate: miad));

      if (miad != null && (stock.quantity ?? 0) != 0) {
        if (earliestMiad == null || miad.isBefore(earliestMiad)) earliestMiad = miad;
      }
    }

    return (result, earliestMiad);
  }
}
