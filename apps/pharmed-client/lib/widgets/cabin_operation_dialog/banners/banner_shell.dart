import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum BannerTone {
  error, // kırmızı
  warning, // amber
  info, // mavi
  success; // yeşil

  (Color bg, Color fg) get colors => switch (this) {
    BannerTone.error => (MedColors.redLight, MedColors.red),
    BannerTone.warning => (MedColors.amberLight, MedColors.amber),
    BannerTone.info => (MedColors.blueLight, MedColors.blue),
    BannerTone.success => (MedColors.greenLight, MedColors.green),
  };
}

/// Tüm kabin işlem dialog'larında ortak banner kabuğu.
/// - [title] opsiyonel: verilirse iki satırlı (başlık + mesaj), yoksa tek satır.
/// - [epcs] opsiyonel: verilirse altında etiket listesi gösterilir.
class OperationBanner extends StatelessWidget {
  const OperationBanner({
    super.key,
    required this.tone,
    required this.icon,
    required this.message,
    this.title,
    this.epcs,
    this.child,
  });

  final BannerTone tone;
  final IconData icon;
  final String message;
  final String? title;
  final Set<String>? epcs;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = tone.colors;

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: MedTextStyles.bodyMd(color: fg, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(message, style: MedTextStyles.bodySm(color: fg)),
                if (epcs != null && epcs!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    child: Column(children: epcs!.map((epc) => _EpcChip(epc: epc)).toList()),
                  ),
                ],
                if (child != null) ...[const SizedBox(height: 10), child!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EpcChip extends StatelessWidget {
  const _EpcChip({required this.epc});
  final String epc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: MedColors.surface, borderRadius: MedRadius.mdAll),
        child: Row(
          children: [
            Icon(PhosphorIcons.tag(), size: 13, color: MedColors.text3),
            const SizedBox(width: 6),
            Expanded(
              child: Text(formatEpc(epc), style: MedTextStyles.monoXs(color: MedColors.text3)),
            ),
          ],
        ),
      ),
    );
  }
}
