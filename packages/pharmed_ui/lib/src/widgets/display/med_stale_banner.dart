import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// StaleBanner
// [SWREQ-UI-007] [HAZ-007]
// Veri güncel değilse ekranın üstünde sabit gösterilir.
//
// KRİTİK KURALLAR:
// 1. dismissible: false — kullanıcı kapatamaz, kapatma butonu YOK.
// 2. canProceed: false → ekrandaki aksiyon butonları disabled olmalı.
//    Bu widget canProceed bilgisini dışarı expose eder,
//    aksiyon disable'ı CabinActionBar.isEnabled üzerinden uygulanır.
// 3. lastUpdated her zaman gösterilir — belirsizlik bırakılmaz.
//
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────

class MedStaleBanner extends StatelessWidget {
  const MedStaleBanner({super.key, required this.lastUpdated, required this.canProceed});

  final DateTime lastUpdated;

  /// false → bağlı organism'lerdeki aksiyon butonları disabled edilmeli
  final bool canProceed;

  @override
  Widget build(BuildContext context) {
    final minutesAgo = DateTime.now().difference(lastUpdated).inMinutes;
    final timeLabel = minutesAgo < 1
        ? context.l10n.staleBanner_justNow
        : minutesAgo < 60
        ? context.l10n.staleBanner_minutesAgo(minutesAgo)
        : context.l10n.staleBanner_hoursAgo((minutesAgo / 60).floor());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: MedColors.amberLight,
      child: Row(
        children: [
          // Uyarı ikonu
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: MedColors.amber.withAlpha(38), shape: BoxShape.circle),
            child: Icon(Icons.warning_amber_rounded, size: 13, color: MedColors.amber),
          ),

          const SizedBox(width: 10),

          // Mesaj
          Expanded(
            child: RichText(
              text: TextSpan(
                style: MedTextStyles.bodySm(color: MedColors.amber),
                children: [
                  TextSpan(
                    text: canProceed
                        ? context.l10n.staleBanner_dataStaleMessage
                        : context.l10n.staleBanner_dataUnavailableMessage,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: context.l10n.staleBanner_lastUpdatedLabel(timeLabel)),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // canProceed durumu badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: canProceed ? MedColors.amber.withAlpha(38) : MedColors.redLight,
              borderRadius: MedRadius.xlAll,
              border: Border.all(color: canProceed ? MedColors.amber : MedColors.red, width: 0.5),
            ),
            child: Text(
              canProceed ? context.l10n.session_timeout_continueButton : context.l10n.staleBanner_blockedBadge,
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: canProceed ? MedColors.amber : MedColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
