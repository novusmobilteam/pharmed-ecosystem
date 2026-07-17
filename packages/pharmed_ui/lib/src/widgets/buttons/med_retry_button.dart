// [SWREQ-UI-RETRYBTN-001] [IEC 62304 §5.5]
// Yeniden dene butonu. İki boyut:
//   - normal → dolu mavi, dokunmatik hedef yüksekliği.
//   - compact → nötr yüzey + kenarlık, satır içi kullanıma uygun kısa yükseklik.
//
// Etiket dışarıdan verilir (pharmed_ui l10n bilmez).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../theme/med_tokens.dart';

class MedRetryButton extends StatelessWidget {
  const MedRetryButton({super.key, required this.label, required this.onTap, this.compact = false});

  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.mdAll,
        child: Container(
          height: compact ? 32 : MedSpacing.touchTarget,
          padding: EdgeInsets.symmetric(horizontal: compact ? MedSpacing.lg : MedSpacing.xl3),
          decoration: BoxDecoration(
            color: compact ? MedColors.surface2 : MedColors.blue,
            borderRadius: MedRadius.mdAll,
            border: compact ? Border.all(color: MedColors.border2) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.arrowClockwise(), size: 14, color: compact ? MedColors.text2 : Colors.white),
              const SizedBox(width: MedSpacing.sm),
              Text(
                label,
                style: MedTextStyles.bodySm(color: compact ? MedColors.text2 : Colors.white, weight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
