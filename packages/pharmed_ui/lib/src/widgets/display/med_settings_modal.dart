import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Kullanım (özet):
/// ```dart
/// MedSettingsModal.show(
///   context: context,
///   title: 'Ayarlar',
///   subtitle: 'SİSTEM YAPILANDIRMASI',
///   icon: Icons.settings_outlined,
///   navGroups: [
///     MedSettingsNavGroup(items: [genelItem, gorunumItem]),
///     MedSettingsNavGroup(items: [kabinItem, receteItem]), // manager-only ise sadece manager bu grubu yollar
///   ],
///   activeSectionId: activeSectionId,
///   onSectionSelected: (id) => ...,
///   content: _buildSectionContent(activeSectionId), // caller switch/case yapar
///   isDirty: isDirty,
///   onCancel: () => ...,
///   onSave: () => ...,
/// );
/// ```
class MedSettingsModal extends StatelessWidget {
  const MedSettingsModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.navGroups,
    required this.activeSectionId,
    required this.onSectionSelected,
    required this.content,
    this.onClose,
    this.footerLeading,
    this.isDirty = false,
    this.dirtyLabel = 'Kaydedilmemiş değişiklikler',
    required this.onCancel,
    required this.onSave,
    this.cancelLabel = 'İptal',
    this.saveLabel = 'Kaydet',
    this.width = 840,
  });

  final String title;
  final String? subtitle;

  final List<MedSettingsNavGroup> navGroups;
  final String activeSectionId;
  final ValueChanged<String> onSectionSelected;

  /// Aktif section'a karşılık gelen içerik. Hangi widget'ın gösterileceğine
  /// çağıran karar verir (activeSectionId'e göre switch/case).
  final Widget content;

  final VoidCallback? onClose;

  /// Footer'da sol tarafta gösterilen ek eylem (tasarımdaki "İzinleri Yenile"
  /// linki gibi). Section'a özel olabileceği için opsiyonel + dışarıdan verilir.
  final Widget? footerLeading;

  final bool isDirty;
  final String dirtyLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String cancelLabel;
  final String saveLabel;

  final double width;

  /// Modal'ı overlay + blur + slide-up animasyonuyla açar.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String barrierLabel = 'Ayarlar',
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: const Color.fromRGBO(15, 25, 45, 0.5),
      pageBuilder: (ctx, _, __) {
        return Builder(builder: builder);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
          child: Container(
            width: width,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: MedColors.surface,
              border: Border.all(color: MedColors.border),
              borderRadius: MedRadius.xl2All,
              boxShadow: const [
                BoxShadow(color: Color.fromRGBO(30, 50, 90, 0.12), blurRadius: 32, offset: Offset(0, 12)),
                BoxShadow(color: Color.fromRGBO(30, 50, 90, 0.06), blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(icon: PhosphorIcons.gear(), title: title, subtitle: subtitle, onClose: onClose),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SidebarNav(groups: navGroups, activeSectionId: activeSectionId, onSelected: onSectionSelected),
                      Expanded(
                        child: Container(
                          color: MedColors.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
                          child: SingleChildScrollView(
                            child: KeyedSubtree(key: ValueKey(activeSectionId), child: content),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _Footer(
                  footerLeading: footerLeading,
                  isDirty: isDirty,
                  dirtyLabel: dirtyLabel,
                  onCancel: onCancel,
                  onSave: onSave,
                  cancelLabel: cancelLabel,
                  saveLabel: saveLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sidebar'da tek bir nav satırı (ör. "Genel", "Kabin Ayarları").
class MedSettingsNavItem {
  const MedSettingsNavItem({required this.id, required this.label, required this.icon, this.badge});

  /// [activeSectionId] ile eşleşen benzersiz kimlik.
  final String id;
  final String label;
  final IconData icon;

  /// "ADMIN" / "DEV" gibi sağda gösterilen küçük rozet. Opsiyonel.
  final MedSettingsNavBadge? badge;
}

/// Sidebar'daki gruplar arasına otomatik ayraç (divider) çizilir.
/// Manager-only section'lar için: o grubu client tarafında hiç oluşturmayın.
class MedSettingsNavGroup {
  const MedSettingsNavGroup({required this.items});

  final List<MedSettingsNavItem> items;
}

class MedSettingsNavBadge {
  const MedSettingsNavBadge({required this.text, this.color = MedColors.blue, this.background = MedColors.blueLight});

  final String text;
  final Color color;
  final Color background;
}

class _Header extends StatelessWidget {
  const _Header({required this.icon, required this.title, this.subtitle, this.onClose});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F7FF), Color(0xFFEEF2FB)],
        ),
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          MedRectangleIconButton(
            size: 36,
            color: MedColors.blue,
            iconData: icon,
            iconColor: Colors.white,
            dimWhenDisabled: false,
          ),
          const SizedBox(width: MedSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: MedTextStyles.titleMd().copyWith(color: MedColors.text, fontWeight: FontWeight.w700),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(subtitle!, style: MedTextStyles.monoXs().copyWith(color: MedColors.text3, letterSpacing: 0.8)),
                ],
              ],
            ),
          ),
          if (onClose != null) CloseButton(),
        ],
      ),
    );
  }
}

class _SidebarNav extends StatelessWidget {
  const _SidebarNav({required this.groups, required this.activeSectionId, required this.onSelected});

  final List<MedSettingsNavGroup> groups;
  final String activeSectionId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 212,
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(right: BorderSide(color: MedColors.border2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, groupIndex) {
          final group = groups[groupIndex];
          final isLastGroup = groupIndex == groups.length - 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in group.items)
                _NavItemTile(item: item, active: item.id == activeSectionId, onTap: () => onSelected(item.id)),
              if (!isLastGroup)
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  color: MedColors.border2,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({required this.item, required this.active, required this.onTap});

  final MedSettingsNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? MedColors.blue : MedColors.text2;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.mdAll,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            color: active ? MedColors.blueLight : Colors.transparent,
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: color),
              const SizedBox(width: MedSpacing.md + 2),
              Expanded(
                child: Text(
                  item.label,
                  style: MedTextStyles.titleSm().copyWith(
                    color: color,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (item.badge != null) ...[const SizedBox(width: MedSpacing.sm), _NavBadge(badge: item.badge!)],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.badge});

  final MedSettingsNavBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: badge.background, borderRadius: BorderRadius.circular(20)),
      child: Text(badge.text, style: MedTextStyles.monoXs().copyWith(color: badge.color, letterSpacing: 0.3)),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.footerLeading,
    required this.isDirty,
    required this.dirtyLabel,
    required this.onCancel,
    required this.onSave,
    required this.cancelLabel,
    required this.saveLabel,
  });

  final Widget? footerLeading;
  final bool isDirty;
  final String dirtyLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String cancelLabel;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: const BoxDecoration(
        color: MedColors.surface,
        border: Border(top: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          if (footerLeading != null) footerLeading!,
          if (isDirty) ...[
            const SizedBox(width: MedSpacing.lg),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: MedColors.amber, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(dirtyLabel, style: MedTextStyles.bodySm().copyWith(fontSize: 11, color: MedColors.amber)),
          ],
          const Spacer(),
          MedButton(label: cancelLabel, onPressed: onCancel, variant: MedButtonVariant.ghost),
          const SizedBox(width: MedSpacing.md),
          MedButton(label: saveLabel, onPressed: onSave),
        ],
      ),
    );
  }
}
