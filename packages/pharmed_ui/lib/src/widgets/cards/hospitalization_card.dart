import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Bir [Hospitalization] kaydını liste satırı olarak gösteren genel
/// amaçlı widget.
///
/// Hasta adı, avatar monogramı, servis, oda ve yatak bilgisini bir arada
/// sunar. Seçili / yükleniyor durumlarını destekler; dokunma davranışı
/// tamamen çağırana bırakılır.
///
/// ## Kullanım alanları
/// - `RefundPatientList` — iade ekranı hasta listesi
/// - `CabinPatientPickerList` — kabin işlemleri hasta seçici
/// - İleride oluşturulacak her türlü hasta listeleme ekranı
///
/// ## Örnek
///
/// ```dart
/// HospitalizationCard(
///   hospitalization: h,
///   isSelected: state.selectedPatient?.id == h.id,
///   isLoading: isSelected && state.isPatientLoading,
///   onTap: () => notifier.onPatientTap(h),
/// )
/// ```
///
/// Sağ uçtaki trailing slot'u özelleştirmek için [trailing] kullanılır;
/// verilmezse varsayılan olarak sağ ok ikonu gösterilir.
/// [showChevron] false yapılırsa ok ikonu da gizlenir.
class HospitalizationCard extends StatelessWidget {
  const HospitalizationCard({
    super.key,
    required this.hospitalization,
    required this.onTap,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.showChevron = true,
  });

  /// Gösterilecek yatış kaydı.
  final Hospitalization hospitalization;

  /// Dokunma callback'i.
  final VoidCallback onTap;

  /// Satırın seçili görünüp görünmeyeceği.
  final bool isSelected;

  /// Hasta verisi yüklenirken spinner gösterir.
  ///
  /// Genellikle `isSelected && state.isPatientLoading` olarak geçilir.
  final bool isLoading;

  /// Sağ uca yerleştirilen özel widget.
  ///
  /// Null ise [showChevron]'a göre ok ikonu veya hiçbir şey gösterilir.
  final Widget? trailing;

  /// [trailing] null olduğunda sağ ok ikonunun gösterilip
  /// gösterilmeyeceğini belirler. Varsayılan: true.
  final bool showChevron;

  // ── Meta bilgi yardımcıları ─────────────────────────────────────

  /// Servis adı; physicalService → inpatientService → null sıralamasıyla
  /// ilk bulunanı döner.
  String? get _service => hospitalization.physicalService?.name ?? hospitalization.inpatientService?.name;

  /// "Oda · Yatak" formatında konum satırı.
  ///
  /// Sadece biri mevcutsa tek başına gösterilir.
  String? get _location {
    final room = hospitalization.bed?.room?.name ?? hospitalization.room?.name;
    final bed = hospitalization.bed?.name;
    if (room != null && bed != null) return '$room · $bed';
    return room ?? bed;
  }

  /// Servis ve konumu birleştiren tek meta satırı.
  ///
  /// Her ikisi de varsa `Servis  ·  Oda · Yatak` biçiminde döner.
  String? get _metaLine {
    final s = _service;
    final l = _location;
    if (s != null && l != null) return '$s  ·  $l';
    return s ?? l;
  }

  @override
  Widget build(BuildContext context) {
    final patient = hospitalization.patient;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: MedSpacing.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md + 2),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : Colors.transparent,
          border: Border.all(color: isSelected ? MedColors.blue : Colors.transparent, width: 1.5),
          borderRadius: MedRadius.smAll,
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────
            MedAvatar(
              initials: patient?.initials ?? '?',
              palette: isSelected ? AvatarPalette.blue : AvatarPalette.blue,
              size: 36,
            ),
            const SizedBox(width: MedSpacing.lg),
            // ── İsim + meta ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient?.fullName ?? '—',
                    style: MedTextStyles.bodyMd(
                      color: isSelected ? MedColors.blue : MedColors.text,
                      weight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_metaLine != null)
                    Text(
                      _metaLine!,
                      style: MedTextStyles.monoXs(color: isSelected ? MedColors.blue.withAlpha(178) : MedColors.text3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: MedSpacing.md),
            // ── Trailing ────────────────────────────────────────────
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: isSelected ? MedColors.blue : MedColors.text3),
              )
            else if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(PhosphorIcons.caretRight(), size: 14, color: isSelected ? MedColors.blue : MedColors.text4),
          ],
        ),
      ),
    );
  }
}
