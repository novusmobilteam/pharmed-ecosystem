// lib/features/prescription/widgets/hospitalization_detail_banner.dart
//
// Sağ panelin üst kısmında yer alan, seçili yatışa ait özet bilgi şeridi.
//
// [SWREQ-UI-RX-DETAIL-BANNER-001]
// Sınıf : Class A (görüntüleme)
//
// Tasarım referansı: panel-detail > detail-head (HTML prototipi)
//
// ┌──────────────────────────────────────────────────────────────────┐
// │ [AY]  Ayşe Yılmaz                         Yatış  12.05.2026     │
// │       Dahiliye · Oda 304 · Yatak A         P-2024-08821         │
// └──────────────────────────────────────────────────────────────────┘

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart'; // Hospitalization, Bed, Room
import 'package:pharmed_ui/pharmed_ui.dart'; // MedColors, MedSpacing, MedTextStyles, MedRadius

// ─────────────────────────────────────────────────────────────────────────────
// HospitalizationDetailBanner
// ─────────────────────────────────────────────────────────────────────────────

/// Seçili yatışın (hospitalization) özet bilgilerini tek satırlık bir banner
/// olarak gösterir.
///
/// Genellikle [RxDrugPanel] içinde `hospitalization` parametresiyle kullanılır;
/// `null` geçilirse widget render edilmez ([SizedBox.shrink]).
///
/// ```dart
/// HospitalizationDetailBanner(hospitalization: selectedHospitalization)
/// ```
class HospitalizationDetailBanner extends StatelessWidget {
  const HospitalizationDetailBanner({super.key, required this.hospitalization});

  final Hospitalization? hospitalization;

  /// Servis adı; physicalService → inpatientService → null sıralamasıyla
  /// ilk bulunanı döner.
  String? get _service => hospitalization?.physicalService?.name ?? hospitalization?.inpatientService?.name;

  /// "Oda · Yatak" formatında konum satırı.
  ///
  /// Sadece biri mevcutsa tek başına gösterilir.
  String? get _location {
    final room = hospitalization?.bed?.room?.name ?? hospitalization?.room?.name;
    final bed = hospitalization?.bed?.name;
    if (room != null && bed != null) return '· $room $bed';
    return room ?? bed;
  }

  @override
  Widget build(BuildContext context) {
    final h = hospitalization;
    final initials = h?.patient?.initials;
    if (h == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border(bottom: BorderSide(color: MedColors.border2, width: 1)),
      ),
      child: Row(
        children: [
          if (initials != null) MedAvatar(initials: initials, palette: AvatarPalette.blue, size: 55),
          const SizedBox(width: MedSpacing.lg),

          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İsim
                Text(
                  h.patient?.fullName ?? '',
                  style: MedTextStyles.titleLg(color: MedColors.text).copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  spacing: 6,
                  children: [
                    if (_service != null)
                      Text(
                        _service!,
                        style: MedTextStyles.monoMd(
                          color: MedColors.blue.withAlpha(178),
                        ).copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (_location != null)
                      Text(
                        _location!,
                        style: MedTextStyles.monoMd().copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: MedSpacing.lg),
          Text('Yatış Tarihi | ${hospitalization?.admissionDate.formattedDate}', style: MedTextStyles.monoMd()),
        ],
      ),
    );
  }
}
