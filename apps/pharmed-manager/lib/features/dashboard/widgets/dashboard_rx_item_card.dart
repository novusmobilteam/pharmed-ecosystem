import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../widgets/widgets.dart';

// [SWREQ-MGR-DASH-011]
// Dashboard — PrescriptionItem tabanlı ortak kart.
// Eksik stok, uygulanmamış reçete ve yaklaşan tedavi panelleri kullanır.
// Sınıf: Class A

class DashboardRxItemCard extends StatelessWidget {
  const DashboardRxItemCard({
    super.key,
    required this.item,
    required this.infoRows,
    this.showFlags = false,
    this.showStatusChip = false,
    this.showTimeChip = false,
    this.actions,
  });

  final PrescriptionItem item;

  /// Karta gösterilecek etiketli bilgi satırları (hasta, servis, doktor...).
  final List<MedInfoRow> infoRows;

  /// firstDoseEmergency / askDoctor / inCaseOfNecessity chip'leri.
  final bool showFlags;

  /// Alt kısımda durum chip'i (item.status).
  final bool showStatusChip;

  /// Başlıkta uygulama zamanı chip'i (item.time).
  final bool showTimeChip;

  /// Alt kısımda aksiyon alanı (onayla/reddet gibi). null → gösterilmez.
  final Widget? actions;

  String get _doseText {
    final piece = item.dosePiece?.formatFractional ?? '-';
    final unit = item.medicine?.operationUnit ?? 'Adet';
    return '$piece $unit';
  }

  bool get _hasAnyFlag => item.firstDoseEmergency == true || item.askDoctor == true || item.inCaseOfNecessity == true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: MedSpacing.md, right: MedSpacing.md, left: MedSpacing.md),
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık: ilaç adı + (zaman chip / doz)
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
                  _doseText,
                  style: MedTextStyles.monoSm(color: MedColors.text2, weight: FontWeight.w600),
                ),
            ],
          ),

          // Zaman chip'i gösterildiyse doz ayrı satırda (kaybolmasın)
          if (showTimeChip && item.time != null) ...[
            const SizedBox(height: 4),
            Text(
              _doseText,
              style: MedTextStyles.monoSm(color: MedColors.text3, weight: FontWeight.w600),
            ),
          ],

          // Barkod
          if (item.medicine?.barcode != null) ...[
            const SizedBox(height: 2),
            Text(item.medicine!.barcode!, style: MedTextStyles.bodySm(color: MedColors.text4)),
          ],

          // Bayraklar
          if (showFlags && _hasAnyFlag) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: MedSpacing.xs,
              runSpacing: MedSpacing.xs,
              children: [
                if (item.firstDoseEmergency == true)
                  const MedInfoChip(
                    info: 'İlk Doz Acil',
                    backgroundColor: MedColors.redLight,
                    foregroundColor: MedColors.red,
                  ),
                if (item.askDoctor == true)
                  const MedInfoChip(
                    info: 'Doktora Sor',
                    backgroundColor: MedColors.amberLight,
                    foregroundColor: MedColors.amber,
                  ),
                if (item.inCaseOfNecessity == true)
                  const MedInfoChip(
                    info: 'Gerektiğinde',
                    backgroundColor: MedColors.blueLight,
                    foregroundColor: MedColors.blue,
                  ),
              ],
            ),
          ],

          // Ayraç + bilgi satırları
          if (infoRows.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: MedColors.border2),
            const SizedBox(height: 12),
            for (int i = 0; i < infoRows.length; i++) ...[if (i > 0) const SizedBox(height: 6), infoRows[i]],
          ],

          // Durum chip'i
          if (showStatusChip && item.status != null) ...[
            const SizedBox(height: 12),
            MedRxMovementChip(status: item.status!),
          ],

          // Aksiyonlar
          if (actions != null) ...[const SizedBox(height: 12), actions!],
        ],
      ),
    );
  }
}
