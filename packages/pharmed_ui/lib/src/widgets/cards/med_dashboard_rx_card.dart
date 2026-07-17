import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

// [SWREQ-MGR-DASH-011]
// Dashboard — PrescriptionItem tabanlı ortak kart.
// Eksik stok, uygulanmamış reçete ve yaklaşan tedavi panelleri kullanır.
// Sınıf: Class A

/// infoLines: MedInfoRow yerine geçen, karta özel veri satırı.
class DashboardRxInfoLine {
  const DashboardRxInfoLine(this.label, this.value);
  final String label;
  final String value;
}

class MedDashboardRxCard extends StatelessWidget {
  const MedDashboardRxCard({
    super.key,
    required this.item,
    required this.tone,
    required this.infoLines,
    this.showFlags = false,
    this.showStatusChip = false,
    this.showTimeChip = false,
    this.bottomBadgeLabel,
    this.actionButtons = const [],
  });

  final PrescriptionItem item;

  /// Kart kategorisinin tonu (Eksik Stok→error, Uygulanmamış Reçete→warning,
  /// Yaklaşan Tedavi→info). Üst şerit ve kategori rozeti buradan besleniyor.
  final MedTone tone;

  /// Divider altındaki label/value satırları (MedInfoRow'un yerine geçti).
  final List<DashboardRxInfoLine> infoLines;

  final bool showFlags;
  final bool showStatusChip;
  final bool showTimeChip;

  /// "Kritik Seviye" / "Planlandı" gibi alt rozet — null ise gösterilmez.
  final String? bottomBadgeLabel;

  /// Kart bunları eşit genişlikte (Expanded), 8px aralıklı bir Row'a diziyor.
  /// Boşsa aksiyon alanı hiç render edilmiyor.
  final List<Widget> actionButtons;

  String _doseText(BuildContext context) {
    final piece = item.dosePiece?.formatFractional ?? '-';
    final unit = item.medicine?.operationUnit ?? context.l10n.common_defaultUnitFallback;
    return '$piece $unit';
  }

  bool get _hasAnyFlag => item.firstDoseEmergency == true || item.askDoctor == true || item.inCaseOfNecessity == true;

  @override
  Widget build(BuildContext context) {
    final tone_ = MedSemanticColors.of(tone);

    return Container(
      margin: const EdgeInsets.only(bottom: MedSpacing.md, right: MedSpacing.md, left: MedSpacing.md),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MedSpacing.insetXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.medicine?.name ?? '-',
                        style: MedTextStyles.titleSm(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (showTimeChip && item.time != null)
                      MedTimeChip(time: item.time!)
                    else
                      Text(
                        _doseText(context),
                        style: MedTextStyles.monoSm(color: MedColors.text2, weight: FontWeight.w600),
                      ),
                  ],
                ),
                if (showTimeChip && item.time != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _doseText(context),
                    style: MedTextStyles.monoSm(color: MedColors.text3, weight: FontWeight.w600),
                  ),
                ],

                if (item.medicine?.barcode != null) ...[
                  const SizedBox(height: 2),
                  Text(item.medicine!.barcode!, style: MedTextStyles.bodySm(color: MedColors.text4)),
                ],

                if (showFlags && _hasAnyFlag) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: MedSpacing.xs,
                    runSpacing: MedSpacing.xs,
                    children: [
                      if (item.firstDoseEmergency == true)
                        MedInfoChip(
                          info: context.l10n.common_flagFirstDoseEmergency,
                          backgroundColor: MedColors.redLight,
                          foregroundColor: MedColors.red,
                        ),
                      if (item.askDoctor == true)
                        MedInfoChip(
                          info: context.l10n.common_flagAskDoctor,
                          backgroundColor: MedColors.amberLight,
                          foregroundColor: MedColors.amber,
                        ),
                      if (item.inCaseOfNecessity == true)
                        MedInfoChip(
                          info: context.l10n.common_flagInCaseOfNecessity,
                          backgroundColor: MedColors.blueLight,
                          foregroundColor: MedColors.blue,
                        ),
                    ],
                  ),
                ],

                if (infoLines.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: MedColors.border2),
                  const SizedBox(height: 12),
                  for (int i = 0; i < infoLines.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    MedInfoRow(label: infoLines[i].label, value: infoLines[i].value),
                  ],
                ],

                if (showStatusChip && item.status != null) ...[
                  const SizedBox(height: 12),
                  MedRxMovementChip(status: item.status!),
                ],

                if (bottomBadgeLabel != null) ...[
                  const SizedBox(height: 12),
                  MedChip(
                    label: '●  $bottomBadgeLabel',
                    background: tone_.background,
                    foreground: tone_.foreground,
                    mono: true,
                    shape: MedChipShape.pill,
                  ),
                ],

                if (actionButtons.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (int i = 0; i < actionButtons.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(child: actionButtons[i]),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
