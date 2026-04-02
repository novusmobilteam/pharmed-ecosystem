// ═════════════════════════════════════════════════════════════════
// SessionTimeoutBanner
// [SWREQ-UI-AUTH-002] [HAZ-009]
// Oturum dolmak üzere — sağ alt köşede floating banner.
// ═════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class SessionTimeoutBanner extends StatelessWidget {
  const SessionTimeoutBanner({super.key, required this.secondsRemaining, required this.onExtend});

  final int secondsRemaining;
  final VoidCallback onExtend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: const Color(0xFFF5D79E)),
        borderRadius: MedRadius.mdAll,
        boxShadow: MedShadows.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, size: 20, color: MedColors.amber),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Oturum süreniz dolmak üzere.',
                style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
              ),
              RichText(
                text: TextSpan(
                  style: MedTextStyles.bodySm(color: MedColors.text2),
                  children: [
                    const TextSpan(text: 'Oturumunuz '),
                    TextSpan(
                      text: '$secondsRemaining',
                      style: TextStyle(
                        fontFamily: MedFonts.title,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MedColors.red,
                      ),
                    ),
                    const TextSpan(text: ' saniye içinde kapanacak.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onExtend,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.smAll),
              child: Text(
                'Devam Et',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// LockedBanner
// [SWREQ-UI-NAV-002]
// Oturum zaman aşımı sonrası gösterilir.
// ═════════════════════════════════════════════════════════════════

class LockedBanner extends StatelessWidget {
  const LockedBanner({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFEF9EC), Color(0xFFFFFDF7), Color(0xFFFEF9EC)]),
        border: Border(bottom: BorderSide(color: const Color(0xFFF5D79E))),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 14, color: MedColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: MedTextStyles.bodySm(color: MedColors.text2),
                children: [
                  TextSpan(
                    text: 'Oturumunuz ',
                    style: TextStyle(color: MedColors.text2),
                  ),
                  const TextSpan(
                    text: 'zaman aşımı',
                    style: TextStyle(color: MedColors.amber, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: ' nedeniyle kapatıldı. İşlem yapmak için giriş yapın.',
                    style: TextStyle(color: MedColors.text2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onLoginTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: MedColors.amber, borderRadius: MedRadius.smAll),
              child: Text(
                'Giriş Yap',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
