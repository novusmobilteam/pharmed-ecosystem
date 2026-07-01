// item_card/operation_item_card.dart
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Tüm kabin işlem dialog'larında ortak item kartı kabuğu.
/// - [leading]: solda opsiyonel (checkbox gibi)
/// - [trailing]: sağda opsiyonel (durum rozeti gibi)
/// - [footer]: altta opsiyonel (eksik bildir butonu gibi)
/// - [showEpc]: rfidTag varsa EPC satırı gösterir
class OperationItemCard extends StatelessWidget {
  const OperationItemCard({
    super.key,
    required this.item,
    required this.bg,
    required this.border,
    required this.textColor,
    required this.mutedColor,
    this.leading,
    this.trailing,
    this.footer,
    this.showEpc = true,
  });

  final PrescriptionItem item;
  final Color bg;
  final Color border;
  final Color textColor;
  final Color mutedColor;
  final Widget? leading;
  final Widget? trailing;
  final Widget? footer;
  final bool showEpc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: border, width: 1),
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: leading != null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: MedSpacing.md)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.medicine?.name ?? '-',
                      style: MedTextStyles.bodyMd(color: textColor, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(item.medicine?.barcode ?? '', style: MedTextStyles.monoXs(color: mutedColor)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (showEpc && item.rfidTag != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: border, width: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.tag(), size: 13, color: mutedColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(formatEpc(item.rfidTag!), style: MedTextStyles.monoXs(color: mutedColor)),
                  ),
                ],
              ),
            ),
          ],
          if (footer != null) ...[const SizedBox(height: 10), footer!],
        ],
      ),
    );
  }
}

class ItemCardColors {
  const ItemCardColors({required this.bg, required this.border, required this.text, required this.muted});
  final Color bg;
  final Color border;
  final Color text;
  final Color muted;

  /// Tema bazlı hazır paletler — durum→renk eşlemelerinde kullanılır.
  static ItemCardColors green = ItemCardColors(
    bg: MedColors.greenLight,
    border: MedColors.green.withValues(alpha: 0.3),
    text: MedColors.green,
    muted: MedColors.green.withValues(alpha: 0.8),
  );
  static ItemCardColors blue = ItemCardColors(
    bg: MedColors.blueLight,
    border: MedColors.blue.withValues(alpha: 0.3),
    text: MedColors.blue,
    muted: MedColors.blue.withValues(alpha: 0.8),
  );
  static ItemCardColors amber = ItemCardColors(
    bg: MedColors.amberLight,
    border: MedColors.amber.withValues(alpha: 0.3),
    text: MedColors.amber,
    muted: MedColors.amber.withValues(alpha: 0.8),
  );
  static ItemCardColors red = ItemCardColors(
    bg: MedColors.redLight,
    border: MedColors.red.withValues(alpha: 0.3),
    text: MedColors.red,
    muted: MedColors.red.withValues(alpha: 0.8),
  );
  static ItemCardColors neutral = ItemCardColors(
    bg: MedColors.bg,
    border: MedColors.border,
    text: MedColors.text,
    muted: MedColors.text3,
  );

  static ItemCardColors mutedNeutral = ItemCardColors(
    bg: MedColors.surface2,
    border: MedColors.border,
    text: MedColors.text3,
    muted: MedColors.text3,
  );
}
