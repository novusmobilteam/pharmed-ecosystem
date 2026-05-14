import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

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
    if (room != null && bed != null) return '· $room $bed';
    return room ?? bed;
  }

  @override
  Widget build(BuildContext context) {
    final patient = hospitalization.patient;
    print(hospitalization.room);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        height: 85,
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : Colors.transparent,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
          borderRadius: MedRadius.lgAll,
        ),
        child: Row(
          children: [
            Opacity(
              opacity: isSelected ? 1 : 0,
              child: Container(
                width: 4,
                height: 55,
                decoration: BoxDecoration(
                  color: MedColors.blue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(MedRadius.sm.x),
                    bottomRight: Radius.circular(MedRadius.sm.x),
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
            MedAvatar(initials: patient?.initials ?? '?', palette: AvatarPalette.blue, size: 42),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    patient?.fullName ?? '—',
                    style: MedTextStyles.titleMd(color: isSelected ? MedColors.blue : MedColors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      if (_service != null)
                        Text(
                          _service!,
                          style: MedTextStyles.monoSm(
                            color: MedColors.blue.withAlpha(178),
                          ).copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (_location != null)
                        Text(
                          _location!,
                          style: MedTextStyles.monoSm().copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
