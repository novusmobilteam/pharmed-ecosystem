// [SWREQ-CLI-CABINEXEC-002] [IEC 62304 §5.5]
// Serum avadanlığında Al-Ver doğrulaması: kilit kartındaki Al-Ver tuş
// değerini beklenen adetle birlikte gösterir. Eşleşme kuralı kuyruk
// mixin'inde (isTakeGiveSatisfied) — bu widget yalnızca durumu yansıtır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinTakeGiveVerificationBar extends StatelessWidget {
  const CabinTakeGiveVerificationBar({super.key, required this.expected, required this.reading});

  /// Kullanıcının Al-Ver tuşlarıyla girmesi gereken adet.
  final int expected;

  /// Son okunan tuş değeri — ilk okuma gelene kadar null.
  final TrayKeypadReading? reading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reading = this.reading;
    final isMatched = reading?.matches(expected) ?? false;

    // Önceki işlemden kalan değer beklenenle aynı olabilir — dokunulmadıkça geçerli değil.
    final isStale = reading != null && !reading.hasChanged && reading.value == expected;

    final (Color accent, Color background, IconData icon) = isMatched
        ? (MedColors.green, MedColors.greenLight, PhosphorIcons.checkCircle(PhosphorIconsStyle.fill))
        : (MedColors.amber, MedColors.amberLight, PhosphorIcons.warning());

    final String status = reading == null
        ? l10n.cabinExecution_takeGive_reading
        : isMatched
        ? l10n.cabinExecution_takeGive_matched
        : isStale
        ? l10n.cabinExecution_takeGive_staleValue
        : l10n.cabinExecution_takeGive_instruction(expected);

    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: accent, width: 1.5),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.cabinExecution_takeGive_title, style: MedTextStyles.titleSm(color: MedColors.text)),
                const SizedBox(height: 2),
                Text(status, style: MedTextStyles.bodySm(color: MedColors.text2)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${reading?.value ?? '—'} / $expected',
            style: MedTextStyles.titleMd(color: accent).copyWith(fontFamily: MedFonts.mono),
          ),
        ],
      ),
    );
  }
}
