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
///
/// ### 1. `onAdd` — yeşil `+` butonu (sol liste, henüz eklenmemiş hasta)
/// ```dart
/// HospitalizationCard(
///   hospitalization: h,
///   onAdd: () => notifier.addPatient(h),
/// )
/// ```
///
/// ### 2. `onRemove` — kırmızı `—` butonu (sağ liste, eklenmiş hasta)
/// ```dart
/// HospitalizationCard(
///   hospitalization: h,
///   onRemove: () => notifier.removePatient(h),
/// )
/// ```
///
/// ### 3. `showCheckmark` — yeşil ✓ ikonu (sol liste, seçili/eklenmiş hasta)
/// ```dart
/// HospitalizationCard(
///   hospitalization: h,
///   isSelected: true,
///   showCheckmark: true,
/// )
/// ```
///
/// ### 4. `trailing` — tamamen özel widget
/// ```dart
/// HospitalizationCard(
///   hospitalization: h,
///   trailing: MyCustomWidget(),
/// )
/// ```
///
/// Öncelik sırası: `trailing` > `onAdd`/`onRemove` > `showCheckmark` > `showChevron`
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

  /// Sağ uca yerleştirilen tamamen özel widget.
  ///
  /// Verildiğinde diğer tüm trailing seçenekleri ([onAdd], [onRemove],
  /// [showCheckmark], [showChevron]) devre dışı kalır.
  final Widget? trailing;

  /// [trailing] ve diğer aksiyon seçenekleri yoksa sağ ok ikonunu gösterir.
  ///
  /// Varsayılan: true.
  final bool showChevron;

  /// `true` ise sağa yeşil ✓ ikonu yerleştirilir.
  ///
  /// Sol liste "seçili/eklendi" durumu için kullanılır.
  /// [trailing] veya [onAdd]/[onRemove] varsa gösterilmez.
  final bool showCheckmark;

  /// Null olmayan değer verildiğinde sağa **yeşil `+` butonu** eklenir.
  ///
  /// Sol listede henüz eklenmemiş hastalar için kullanılır.
  /// [trailing] varsa gösterilmez.
  final VoidCallback? onAdd;

  /// Null olmayan değer verildiğinde sağa **kırmızı `—` butonu** eklenir.
  ///
  /// Sağ listede mevcut hastayı çıkarmak için kullanılır.
  /// [trailing] varsa gösterilmez.
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
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(MedColors.blue)),
      );
    }

    // 3. + butonu
    if (onAdd != null) return _ActionButton.add(onTap: onAdd!);

    // 4. — butonu
    if (onRemove != null) return _ActionButton.remove(onTap: onRemove!);

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
            SizedBox(width: 15),
            // Avatar
            MedAvatar(initials: patient?.initials ?? '?', palette: AvatarPalette.blue, size: 42),
            SizedBox(width: 10),
            // İsim + meta bilgi
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
            // Trailing
            if (resolvedTrailing != null) ...[Padding(padding: EdgeInsets.all(24.0), child: resolvedTrailing)],
          ],
        ),
      ),
    );
  }
}

// ── Dahili aksiyon butonu ────────────────────────────────────────────────────

/// `+` ve `—` aksiyon butonları için dahili yardımcı widget.
///
/// Doğrudan `HospitalizationCard` dışında kullanılmaz; bunun yerine
/// [HospitalizationCard.onAdd] ve [HospitalizationCard.onRemove]
/// parametrelerini kullanın.
class _ActionButton extends StatelessWidget {
  const _ActionButton._({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  factory _ActionButton.add({required VoidCallback onTap}) => _ActionButton._(
    icon: Icons.add_rounded,
    color: MedColors.green,
    backgroundColor: MedColors.greenLight,
    borderColor: MedColors.green.withAlpha(77),
    onTap: onTap,
  );

  factory _ActionButton.remove({required VoidCallback onTap}) => _ActionButton._(
    icon: Icons.remove_rounded,
    color: MedColors.text3,
    backgroundColor: MedColors.surface,
    borderColor: MedColors.text3,
    onTap: onTap,
  );

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MedSpacing.touchTarget, // 44px
        height: MedSpacing.touchTarget, // 44px
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: MedRadius.mdAll,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
