part of 'rx_operation_card_2.dart';

// ─────────────────────────────────────────────────────────────────
// RxOperationCard — veri modelleri
// Kart hangi ekranda (dolum/alım/sayım/boşaltma/iade/fire-imha)
// olduğunu BİLMEZ. Mode'a özgü tüm metinler, tonlar ve callback'ler
// çağıran panelde çözülür ve bu modeller üzerinden karta verilir
// (bkz. cabin-shell-widgets prensibi).
// ─────────────────────────────────────────────────────────────────

/// Durum satırındaki sağ göstergenin türü.
enum RxCardIndicator {
  /// Gösterge yok — yalnızca sol metin.
  none,

  /// Dönen spinner (bekleniyor / kontrol ediliyor / kabinde-canlı).
  spinner,

  /// Dolu daire + check (okundu / alındı / kontrol tamam).
  check,

  /// Dolu daire + ünlem (kabinde değil / eksik / kontrol başarısız).
  warn,
}

/// Kart başlığındaki durum chip'i (sağ üst).
///
/// Örn: "Planlandı" (info), "Tamamlandı" (success), "Kritik" (error).
class RxCardChip {
  const RxCardChip({required this.label, required this.tone});

  final String label;
  final MedTone tone;
}

/// Hasta bağlam satırı (alım/iade gibi hasta bağlamlı ekranlar).
class RxCardPatient {
  const RxCardPatient({required this.name, this.room});

  final String name;

  /// Oda/yatak etiketi — null ise chip çizilmez.
  final String? room;
}

/// RFID / uygunluk kontrolü durum satırı.
///
/// - RFID'li akışlarda: [leadingIcon] = tag ikonu, [leadingText] = EPC
///   (çağıran `formatEpc` ile biçimlendirir), [tone] mode+status
///   eşlemesinden gelir (örn. alım+kabinde-değil → error).
/// - İade kontrol akışında: [leadingText] = "Uygunluk Kontrolü",
///   [trailingLabel] = check mesajı.
/// - [tone] null → nötr zemin (surface3), soluk metin (seçili olmayan
///   kartta RFID satırının pasif hali).
class RxCardStatusRow {
  const RxCardStatusRow({
    required this.leadingText,
    this.leadingIcon,
    this.tone,
    this.trailingLabel,
    this.indicator = RxCardIndicator.none,
  });

  final String leadingText;
  final IconData? leadingIcon;
  final MedTone? tone;
  final String? trailingLabel;
  final RxCardIndicator indicator;
}

/// Şahit satırı (kontrollü ilaç alımı / imha).
///
/// [isConfirmed] false iken [actionLabel] + [onTap] ile "Şahit Girişi"
/// butonu, true iken [confirmedName] ile onaylı görünüm çizilir.
/// Tüm metinler çağıran tarafından l10n üzerinden çözülür.
class RxCardWitness {
  const RxCardWitness({
    required this.isConfirmed,
    required this.label,
    this.confirmedName,
    this.actionLabel,
    this.onTap,
  });

  final bool isConfirmed;

  /// "Şahitli Alım Gerekli" / "Şahit Onaylandı" gibi durum etiketi.
  final String label;

  /// Onaylı şahidin adı — [isConfirmed] true iken gösterilir.
  final String? confirmedName;

  /// Onay bekleyen durumda buton etiketi (örn. "Şahit Girişi").
  final String? actionLabel;

  /// Buton callback'i — null ise buton pasif çizilir.
  final VoidCallback? onTap;
}

/// "Son Hareketler" bloğundaki tek satır.
class RxCardMovement {
  const RxCardMovement({
    required this.label,
    required this.tone,
    required this.performedBy,
    required this.quantity,
    required this.date,
  });

  /// Hareket tipi etiketi — örn. "ALIM", "DOLUM" (çağıran
  /// `PrescriptionMovementType.localizedLabel` ile çözer).
  final String label;

  final MedTone tone;
  final String performedBy;
  final String quantity;
  final String date;
}

/// Etiketli not bloğu (örn. iade notu, alım notu).
class RxCardNote {
  const RxCardNote({required this.label, required this.text});

  /// Blok başlığı — örn. `context.l10n.refund_field_returnNote`.
  final String label;

  final String text;
}

/// Miktar satırı — kartın altında "MİKTAR" etiketiyle
/// [MedDoseStepper.compact] barındıran kabuk.
///
/// Birim kuralları (medicine-unit-mode) çağıranın sorumluluğundadır:
/// adet-giren ekranlar (atama/dolum) adet, ml-giren ekranlar
/// (sayım/boşaltma/iade/fire-imha) ml değeri geçirir.
class RxCardStepper {
  const RxCardStepper({required this.value, required this.unit, required this.onChanged, this.max, this.step = 1.0});

  final double value;
  final String unit;
  final double? max;
  final double step;
  final ValueChanged<double> onChanged;
}
