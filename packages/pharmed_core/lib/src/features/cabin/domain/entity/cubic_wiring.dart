// [SWREQ-CORE-CABIN-CUBIC-001] [IEC 62304 §5.5]
// Kübik çekmece kart / göz adreslemesi ve kablolama kuralı (#275).
//
// Komut `:Zkattc;` → a = SIRA KARTI (slave), tt = o karttaki GÖZ.
//   - DrawerUnit.compartmentNo = sütun = sıra kartı (soldan sağa)
//   - DrawerUnit.orderNo       = satır = göz (alttan üste)
//   16 göz = 4 kart × 4 göz, 20 göz = 5 kart × 4 göz.
//
// Kablolama: üretilen BÜTÜN 20 gözlü kübiklerde 4. ve 5. sütun çapraz
// bağlıdır — 4. sütundaki göz için 5. karta, 5. sütundaki göz için 4. karta
// komut gönderilir (hw-test ile sahada doğrulandı, #274). Kayıtlı veri
// (compartmentNo) değişmez; çeviri yalnızca donanım adresi üretilirken
// uygulanır.
//
// Sınıf: Class B

/// Çapraz bağlı 4 ↔ 5 sütun kuralının geçerli olduğu kübik göz sayısı.
const int cubicCrossWired45CompartmentCount = 20;

/// Görsel sütunu ([column] = compartmentNo) donanımdaki sıra kartına
/// (komuttaki `a`) çevirir. [compartmentCount] çekmece tipinin göz sayısıdır.
int cubicCardForColumn(int column, {required int? compartmentCount}) {
  if (compartmentCount != cubicCrossWired45CompartmentCount) return column;
  return switch (column) {
    4 => 5,
    5 => 4,
    _ => column,
  };
}
