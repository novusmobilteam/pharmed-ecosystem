part of 'mobile_refill_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UNEXPECTED banner — Dolum'a özel blokaj (kırmızı)
// ─────────────────────────────────────────────────────────────────────────────

class _UnexpectedBanner extends StatelessWidget {
  const _UnexpectedBanner({required this.epcs});

  final Set<String> epcs;

  @override
  Widget build(BuildContext context) {
    return _BannerShell(
      bg: MedColors.redLight,
      fg: MedColors.red,
      icon: PhosphorIcons.prohibit(PhosphorIconsStyle.bold),
      title: 'Kabine ait olmayan etiket(ler) tespit edildi',
      message: 'Devam edebilmek için aşağıdaki ${epcs.length} etiketi çekmeceden çıkartın.',
      epcs: epcs,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTRA PLACEMENT banner — seçili olmayan ilacın etiketi yerleştirildi
// ─────────────────────────────────────────────────────────────────────────────

class _ExtraPlacementBanner extends StatelessWidget {
  const _ExtraPlacementBanner({required this.epcs});

  final Set<String> epcs;

  @override
  Widget build(BuildContext context) {
    return _BannerShell(
      bg: MedColors.amberLight,
      fg: MedColors.amber,
      icon: PhosphorIcons.warning(PhosphorIconsStyle.bold),
      title: 'Fazladan etiket yerleştirildi',
      message:
          'Seçili ilaçların dışında ${epcs.length} etiket kabine konuldu. Devam edebilmek için bunları çekmeceden çıkartın.',
      epcs: epcs,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UNPLANNED hareket banner'ı (kırmızı, bildirim oluşacak)
// ─────────────────────────────────────────────────────────────────────────────

class _UnplannedBanner extends StatelessWidget {
  const _UnplannedBanner({required this.epcs});

  final Set<String> epcs;

  @override
  Widget build(BuildContext context) {
    return _BannerShell(
      bg: MedColors.redLight,
      fg: MedColors.red,
      icon: PhosphorIcons.warning(PhosphorIconsStyle.bold),
      title: 'Plan dışı hareket algılandı',
      message: 'Dolum hedefleri dışında ${epcs.length} etiket kabinden çıkarıldı. Eczaneye bildirim oluşturulacak.',
      epcs: epcs,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR banner — complete fail sonrası
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _BannerShell(
      bg: MedColors.redLight,
      fg: MedColors.red,
      icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
      title: 'İşlem tamamlanamadı',
      message: message,
    );
  }
}

class _BannerShell extends StatelessWidget {
  const _BannerShell({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.title,
    required this.message,
    this.epcs,
  });

  final Color bg;
  final Color fg;
  final IconData icon;
  final String title;
  final String message;
  final Set<String>? epcs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                Text(
                  title,
                  style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(message, style: MedTextStyles.bodySm(color: fg)),
                if (epcs != null && epcs!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...epcs!.map(
                    (epc) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: MedColors.surface, borderRadius: MedRadius.mdAll),
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.tag(), size: 13, color: MedColors.text3),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(_formatEpc(epc), style: MedTextStyles.monoXs(color: MedColors.text3)),
                            ),
                          ],
                        ),
                      ),
                    ),
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
