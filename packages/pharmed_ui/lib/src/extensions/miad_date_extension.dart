/// SKT (miad) tarihleriyle ilgili ortak yardımcılar.
///
/// `DateTime.now()` saat bilgisi taşıdığı için doğrudan karşılaştırma iki
/// soruna yol açıyordu:
///   1. `showDatePicker`'a `firstDate: DateTime.now()` verilip `initialDate`
///      olarak geçmişte kalmış (zaten süresi dolmuş) bir miad geçildiğinde
///      "initialDate must be on or after firstDate" hatası fırlatıyordu —
///      var olan stoktan yüklenen bir tarih bugünden önce olabilir, bu
///      geçerli bir durum, hataya düşmemeli.
///   2. Saat bazlı karşılaştırma, BUGÜNÜN tarihini bile (gece yarısından
///      sonraki her an) "süresi geçmiş" gibi işaretleyebiliyordu.
///
/// Bu yüzden her yerde gün-bazlı (saat sıfırlanmış) karşılaştırma kullanıyoruz.
library;

/// Bugünün başlangıcı (saat/dakika/saniye sıfırlanmış). Picker'ın
/// `firstDate`'i ve "initialDate clamp" için kullanılır.
DateTime todayDateOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

extension MiadExpiryX on DateTime? {
  /// Bugünden önceki bir gün ise süresi geçmiş sayılır. Bugünün kendisi
  /// (saat farketmeksizin) süresi geçmiş SAYILMAZ.
  bool get isExpiredMiad {
    final value = this;
    if (value == null) return false;
    return value.isBefore(todayDateOnly());
  }

  /// `showDatePicker`'ın `initialDate`'i her zaman `firstDate`'in (bugün)
  /// üzerinde/eşit olmalı. Var olan tarih geçmişteyse bugüne kenetler,
  /// yoksa mevcut tarihi (veya bugünü) kullanır.
  DateTime clampedForPicker() {
    final value = this;
    final today = todayDateOnly();
    if (value == null || value.isBefore(today)) return today;
    return value;
  }
}
