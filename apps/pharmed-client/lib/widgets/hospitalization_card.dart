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
class HospitalizationCard extends StatelessWidget {
  const HospitalizationCard({
    super.key,
    required this.hospitalization,
    required this.onTap,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.showChevron = true,
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

  // ── Meta bilgi yardımcıları ─────────────────────────────────────

  String? get _service => hospitalization.physicalService?.name ?? hospitalization.inpatientService?.name;

  String? get _location {
    final room = hospitalization.bed?.room?.name ?? hospitalization.room?.name;
    final bed = hospitalization.bed?.name;
    if (room != null && bed != null) return '$room $bed';
    return room ?? bed;
  }

  // ── Trailing widget çözümleyici ─────────────────────────────────

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
    final resolvedTrailing = _resolvedTrailing;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        height: 95,
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
          borderRadius: MedRadius.lgAll,
        ),
        child: Row(
          children: [
            // Seçim çubuğu
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
            const SizedBox(width: 15),
            MedAvatar(initials: patient?.initials ?? '?', palette: AvatarPalette.blue, size: 42),
            const SizedBox(width: 10),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
            if (resolvedTrailing != null) ...[Padding(padding: const EdgeInsets.all(24.0), child: resolvedTrailing)],
          ],
        ),
      ),
    );
  }
}
