import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Item durum rozeti — küçük renkli kapsül (ikon + etiket).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.bg, required this.fg, required this.icon, required this.label});

  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.mdAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Ortak "eksik bildirildi" rozeti (sayım/boşaltmada manuel eksik sonrası).
StatusBadge reportedMissingBadge(BuildContext context) => StatusBadge(
  bg: MedColors.amberLight,
  fg: MedColors.amber,
  icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
  label: context.l10n.operationStatus_reportedMissingLabel,
);
