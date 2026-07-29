import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

part 'rx_operation_card_models.dart';
part 'rx_operation_card_sections.dart';

// ─────────────────────────────────────────────────────────────────
// RxOperationCard2
// [SWREQ-UI-CARD-RX-002]
// Kullanım: Mobil ve master kabin işlem ekranlarında (dolum, alım,
//           sayım, boşaltma, iade, fire/imha) reçete kalemi kartı.
//           RefundOperationCard, IntakeOperationCard,
//           WasteOperationCard, OperationItemCard ve RxItemCard'ın
//           tek bileşende birleşimidir.
// Sınıf  : Class A
// Tasarım: "Reçete Kartı v2 — Birleşik" (dc tasarım dosyası)
// ─────────────────────────────────────────────────────────────────

/// Kabin işlem ekranlarının ortak reçete kalemi kartı.
///
/// Kart hangi işlemde (dolum/alım/sayım/boşaltma/iade/fire-imha)
/// kullanıldığını **bilmez** — mode'a özgü tüm metinler, tonlar ve
/// görünürlük kararları çağıran panelde çözülür ve view-model
/// nesneleri ([RxCardStatusRow], [RxCardWitness], [RxCardMovement],
/// [RxCardNote], [RxCardStepper]) üzerinden karta verilir.
///
/// Yapı (yukarıdan aşağı, tüm bölümler opsiyonel):
///
/// ```
/// ┌ Header: [✓] İlaç adı            [durum chip'i] ┐  ← her zaman
/// │         doz · barkod                           │
/// ├ Hasta satırı (ad + oda chip'i)                 │
/// ├ Durum satırı (EPC / uygunluk kontrolü)         │
/// ├ Şahit satırı (gerekli → buton / onaylı → ad)   │
/// ├ Son Hareketler bloğu                           │
/// ├ Not bloğu (örn. iade notu)                     │
/// ├ [extras — ekrana özgü ek widget'lar]           │
/// ├ Miktar satırı (MedDoseStepper.compact)         │
/// └ Meta: saat ────────────────────── konum        ┘
/// ```
///
/// ## Örnek — iade ekranı
///
/// ```dart
/// RxOperationCard2(
///   title: item.medicine?.name ?? item.medicineName,
///   subtitle: doseText,
///   barcode: item.medicine?.barcode,
///   isSelected: isSelected,
///   onTap: onTap, // null → kart kilitli
///   statusChip: RxCardChip(label: statusLabel, tone: statusTone),
///   statusRow: switch (checkStatus) {
///     RefundCheckIdle() => null,
///     RefundCheckLoading() => RxCardStatusRow(
///       leadingText: context.l10n.refund_status_checking,
///       indicator: RxCardIndicator.spinner,
///     ),
///     ...
///   },
///   note: returnNote == null
///       ? null
///       : RxCardNote(
///           label: context.l10n.refund_field_returnNote,
///           text: returnNote,
///         ),
///   stepper: isSelected
///       ? RxCardStepper(
///           value: currentAmount,
///           max: maxAmount,
///           unit: unitLabel,
///           onChanged: onAmountChanged,
///         )
///       : null,
/// )
/// ```
class RxOperationCard2 extends StatelessWidget {
  const RxOperationCard2({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.barcode,
    this.statusChip,
    this.patient,
    this.statusRow,
    this.witness,
    this.movements = const [],
    this.note,
    this.stepper,
    this.metaTime,
    this.metaLocation,
    this.extras = const [],
    this.isDanger = false,
    this.isDimmed = false,
    this.showCheckbox = true,
  });

  /// İlaç/malzeme adı — tek satır, taşarsa ellipsis.
  final String title;

  /// Doz metni — örn. "2 Tablet", "1 Ampul (08:00)".
  final String? subtitle;

  /// Barkod — [subtitle] ile aynı satırda nokta ayracıyla gösterilir.
  final String? barcode;

  /// Kartın seçili görünümü. Header checkbox'ı ve vurgu kenarını yönetir.
  final bool isSelected;

  /// Dokunma callback'i — seçim toggle'ı çağıranda yönetilir.
  /// `null` ise kart kilitlidir (check/submit sürüyor).
  final VoidCallback? onTap;

  /// Sağ üst durum chip'i (örn. "Planlandı", "Tamamlandı", "Kritik").
  final RxCardChip? statusChip;

  /// Hasta bağlam satırı (alım/iade gibi hasta bağlamlı ekranlar).
  final RxCardPatient? patient;

  /// RFID / uygunluk kontrolü durum satırı.
  final RxCardStatusRow? statusRow;

  /// Şahit satırı (kontrollü ilaç akışları).
  final RxCardWitness? witness;

  /// "Son Hareketler" bloğu — boşsa blok çizilmez.
  final List<RxCardMovement> movements;

  /// Etiketli not bloğu (örn. iade notu).
  final RxCardNote? note;

  /// Miktar satırı — genelde yalnızca seçili kartta verilir.
  final RxCardStepper? stepper;

  /// Alt meta satırı, sol: göreli zaman etiketi (örn. "2 dk önce").
  final String? metaTime;

  /// Alt meta satırı, sağ: konum etiketi (örn. "Çek. B-08").
  final String? metaLocation;

  /// Ekrana özgü ek widget'lar (örn. `RxFlagChips`, "Eksik Stok
  /// Bildir" butonu). Not bloğu ile miktar satırı arasında çizilir.
  final List<Widget> extras;

  /// Kenarı kırmızıya zorlar (alım: kabinde değil, iade: kontrol
  /// başarısız). Çağıran statü eşlemesinden türetir.
  final bool isDanger;

  /// Kartı soluklaştırır (örn. stok yok). Kilitlemek için ayrıca
  /// [onTap]'ı null geçirin.
  final bool isDimmed;

  /// Header'daki seçim kutusu. Salt-okunur listelerde (reçete
  /// görüntüleme) kapatılabilir.
  final bool showCheckbox;

  Color get _borderColor {
    if (isDanger) return MedColors.red;
    return isSelected ? MedColors.blue : MedColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final hasMeta = metaTime != null || metaLocation != null;

    return Opacity(
      opacity: isDimmed ? 0.6 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: MedRadius.midAll,
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: isSelected ? MedShadows.md : MedShadows.sm,
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CardHeader(
                title: title,
                subtitle: subtitle,
                barcode: barcode,
                isSelected: isSelected,
                statusChip: statusChip,
                showCheckbox: showCheckbox,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: MedSpacing.md,
                  children: [
                    if (patient != null) _PatientRow(patient: patient!),
                    if (statusRow != null) _StatusRow(data: statusRow!),
                    if (witness != null) _WitnessRow(data: witness!),
                    if (movements.isNotEmpty) _MovementsBlock(movements: movements),
                    if (note != null) _NoteBlock(note: note!),
                    ...extras,
                    if (stepper != null) _StepperRow(data: stepper!),
                    if (hasMeta) _MetaRow(time: metaTime, location: metaLocation),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
