import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum BannerTone {
  error, // kırmızı
  warning, // amber
  info, // mavi
  success; // yeşil

  /// Renk kaynağı artık tek: MedSemanticColors. Eşleme burada değil orada.
  (Color bg, Color fg) get colors {
    final c = MedSemanticColors.of(_tone);
    return (c.background, c.foreground);
  }

  MedTone get _tone => switch (this) {
    BannerTone.error => MedTone.error,
    BannerTone.warning => MedTone.warning,
    BannerTone.info => MedTone.info,
    BannerTone.success => MedTone.success,
  };
}

/// Tüm kabin işlem dialog'larında ortak banner kabuğu.
/// - [title] opsiyonel: verilirse iki satırlı (başlık + mesaj), yoksa tek satır.
/// - [epcs] opsiyonel: verilirse altında etiket listesi gösterilir (MedChip fullWidth).
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
      margin: const EdgeInsets.only(bottom: 12.0),
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
                  Column(
                    children: [
                      for (final epc in epcs!)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: MedChip(
                            label: formatEpc(epc),
                            icon: PhosphorIcons.tag(),
                            background: MedColors.surface,
                            foreground: MedColors.text3,
                            showBorder: false,
                            fullWidth: true,
                          ),
                        ),
                    ],
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
