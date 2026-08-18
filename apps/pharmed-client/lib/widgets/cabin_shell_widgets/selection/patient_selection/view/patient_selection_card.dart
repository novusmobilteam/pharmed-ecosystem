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
/// ## Aksiyon Buton Kullanımı
///
/// Sağ uca üç farklı yöntemle aksiyon eklenebilir:
/// - `onAdd`      → yeşil `+` butonu (henüz eklenmemiş hasta)
/// - `onRemove`   → nötr `—` butonu (eklenmiş hastayı çıkar)
/// - `showCheckmark` → yeşil ✓ ikonu
/// - `trailing`   → tamamen özel widget
///
/// Öncelik: `trailing` > `onAdd`/`onRemove` > `showCheckmark` > `showChevron`
class PatientSelectionCard extends StatelessWidget {
  const PatientSelectionCard({
    super.key,
    required this.hospitalization,
    required this.onTap,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.showChevron = false,
    this.showCheckmark = false,
    this.onAdd,
    this.onRemove,
  });

  final Hospitalization hospitalization;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isLoading;
  final Widget? trailing;
  final bool showChevron;
  final bool showCheckmark;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  Widget? get _resolvedTrailing {
    // 1. Özel trailing her şeyin önünde gelir
    if (trailing != null) return trailing;

    // 2. Yüklenme spinner'ı
    if (isLoading) {
      return const MedLoadingIndicator();
    }

    // 3. + butonu (yeşil)
    if (onAdd != null) {
      return MedRectangleIconButton(
        iconData: Icons.add_rounded,
        color: MedColors.greenLight,
        iconColor: MedColors.green,
        borderColor: MedColors.green.withValues(alpha: 0.3),
        size: MedSpacing.touchTarget, // 44
        iconSize: 20,
        onPressed: onAdd,
      );
    }

    // 4. — butonu
    // NOT: Belge "kırmızı — butonu" diyor ama orijinal kod NÖTR (gri) idi
    // (color: text3, bg: surface). Mevcut davranış korundu. Kırmızı istenirse
    // color: MedColors.redLight, iconColor: MedColors.red yapılmalı.
    if (onRemove != null) {
      return MedRectangleIconButton(
        iconData: Icons.remove_rounded,
        color: MedColors.surface,
        iconColor: MedColors.text3,
        borderColor: MedColors.text3,
        size: MedSpacing.touchTarget,
        iconSize: 20,
        onPressed: onRemove,
      );
    }

    // 5. Checkmark ikonu
    if (showCheckmark) {
      return Icon(Icons.check_rounded, color: MedColors.green, size: 22);
    }

    // 6. Şevron
    if (showChevron) {
      return Icon(Icons.chevron_right_rounded, color: MedColors.text3, size: 20);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final patient = hospitalization.patient;
    final bed = hospitalization.bed;
    final room = bed?.room?.name;
    final service = hospitalization.physicalService;
    final protocolNo = patient?.protocolNo;
    final admissionDate = hospitalization.admissionDate;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
          borderRadius: MedRadius.lgAll,
          boxShadow: MedShadows.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: MedSpacing.insetXl,
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
                    if (protocolNo != null)
                      Text(
                        '${context.l10n.patient_fieldProtocolNo}: $protocolNo',
                        style: MedTextStyles.monoMd().copyWith(color: MedColors.text3),
                      ),
                    if (admissionDate != null)
                      Text(
                        '${context.l10n.hospitalization_fieldAdmissionDate}: ${admissionDate.formattedDate}',
                        style: MedTextStyles.monoMd().copyWith(color: MedColors.text3),
                      ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        spacing: 6.0,
                        children: [
                          if (service != null)
                            MedChip(
                              label: service.name ?? '',
                              background: MedColors.blueLight,
                              foreground: MedColors.blue,
                              showBorder: false,
                              shape: MedChipShape.pill,
                            ),
                          if (room != null)
                            MedChip(
                              label: room,
                              background: MedColors.blueLight,
                              foreground: MedColors.blue,
                              showBorder: false,
                              shape: MedChipShape.pill,
                            ),

                          if (bed?.name != null)
                            MedChip(
                              label: bed!.name!,
                              background: MedColors.blueLight,
                              foreground: MedColors.blue,
                              showBorder: false,
                              shape: MedChipShape.pill,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_resolvedTrailing != null) ...[Padding(padding: const EdgeInsets.all(24.0), child: _resolvedTrailing)],
          ],
        ),
      ),
    );
  }
}
