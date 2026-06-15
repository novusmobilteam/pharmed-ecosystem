// [SWREQ-CLI-UI-DIALOG-001] [IEC 62304 §5.5]
// MediCab tasarım sistemine uygun generic modal kabuğu.
//
// Tasarım sistemi §12 (Modal Kuralları) referansı:
//   - overlay: rgba(15,25,45,0.5) + blur(6px)
//   - modal: surface bg, 16px radius, shadow-lg, giriş animasyonu
//   - header: linear-gradient(135deg, #f4f7ff, #eef2fb) + başlık + alt başlık + kapat
//
// pharmed_ui'a taşınmaya adaydır; şimdilik client'ta yaşar.
//
// Kullanım:
//   showMedDialog(context: context, builder: (_) => MedDialog(
//     title: 'Hasta Seçimi', subtitle: 'İşlem için bir hasta seçin',
//     icon: PhosphorIcons.userList(), child: ...,
//   ));
//
// Sınıf: Class A (görsel)

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Tasarım dilinde modal açar. [barrierDismissible] dışına dokununca kapanır.
Future<T?> showMedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x800F192D), // rgba(15,25,45,0.5)
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, _, _) => builder(context),
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: const Cubic(0.34, 1.56, 0.64, 1));
      return FadeTransition(
        opacity: anim,
        child: Transform.translate(
          offset: Offset(0, (1 - curved.value) * 12),
          child: Transform.scale(scale: 0.97 + 0.03 * curved.value, child: child),
        ),
      );
    },
  );
}

class MedDialog extends StatelessWidget {
  const MedDialog({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.width,
    this.maxHeightFactor = 0.85,
    this.padded = true,
    this.onClose,
    this.headerTrailing,
  });

  /// Gövde içeriği.
  final Widget child;

  final String? title;
  final String? subtitle;
  final IconData? icon;

  /// Sabit genişlik. null → ekranın %80'i (maks 1100).
  final double? width;

  /// Maks yükseklik ekran oranı.
  final double maxHeightFactor;

  /// Gövdeye iç padding uygula.
  final bool padded;

  /// Kapat butonu davranışı. null → Navigator.maybePop.
  final VoidCallback? onClose;

  /// Header sağına eklenecek opsiyonel aksiyon (kapat butonunun solunda).
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = width ?? (size.width * 0.8).clamp(360.0, 1100.0);
    final maxHeight = size.height * maxHeightFactor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: MedColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MedColors.border),
              boxShadow: MedShadows.md,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  _Header(
                    title: title!,
                    subtitle: subtitle,
                    icon: icon,
                    trailing: headerTrailing,
                    onClose: onClose ?? () => Navigator.of(context).maybePop(),
                  ),
                Flexible(
                  child: Padding(padding: padded ? MedSpacing.insetXl : EdgeInsets.zero, child: child),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle, this.icon, this.trailing, required this.onClose});

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: const BoxDecoration(
        // §12: linear-gradient(135deg, #f4f7ff, #eef2fb)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F7FF), Color(0xFFEEF2FB)],
        ),
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        spacing: 12,
        children: [
          if (icon != null)
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(title, style: MedTextStyles.titleMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MedColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MedColors.border),
              ),
              child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 16, color: MedColors.text2),
            ),
          ),
        ],
      ),
    );
  }
}
