import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../features/auth/notifier/session_countdown_notifier.dart';

import '../features/auth/auth.dart';

// ═════════════════════════════════════════════════════════════════
// SessionTimeoutBanner
// [SWREQ-UI-AUTH-002] [HAZ-009]
// Oturum dolmak üzere — sağ alt köşede floating banner. Geri sayım
// sessionCountdownProvider'dan okunur; null ise hiçbir şey çizilmez.
// Dashboard Stack'inde HER ZAMAN aynı konumda durmalıdır (bkz. HAZ-009
// remount regresyonu) — görünürlüğü kendisi yönetir.
// ═════════════════════════════════════════════════════════════════

class SessionTimeoutBanner extends ConsumerWidget {
  const SessionTimeoutBanner({super.key});

  /// Dokunmatik HMI minimum hedef yüksekliği.
  static const double _minTouchTarget = 44;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(sessionCountdownProvider);
    if (remaining == null) return const SizedBox.shrink();

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
                context.l10n.session_timeout_warning,
                style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
              ),
              RichText(
                text: TextSpan(
                  style: MedTextStyles.bodySm(color: MedColors.text2),
                  children: [
                    TextSpan(text: context.l10n.session_timeout_prefix),
                    TextSpan(
                      text: '$remaining',
                      style: const TextStyle(
                        fontFamily: MedFonts.title,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MedColors.red,
                      ),
                    ),
                    TextSpan(text: context.l10n.session_timeout_suffix),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Banner, route içeriğini saran activity Listener'ının dışında
            // olabileceği için uzatma açıkça tetiklenir.
            onTap: () => ref.read(authNotifierProvider.notifier).onUserActivity(),
            child: Container(
              constraints: const BoxConstraints(minHeight: _minTouchTarget),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.smAll),
              child: Text(
                context.l10n.session_timeout_continueButton,
                style: const TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 13,
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
// Oturum zaman aşımı sonrası gösterilir. Giriş aksiyonu appbar'dadır.
// ═════════════════════════════════════════════════════════════════

class LockedBanner extends StatelessWidget {
  const LockedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFEF9EC), Color(0xFFFFFDF7), Color(0xFFFEF9EC)]),
        border: Border(bottom: BorderSide(color: Color(0xFFF5D79E))),
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
                  TextSpan(text: context.l10n.session_locked_prefix),
                  TextSpan(
                    text: context.l10n.session_locked_reason,
                    style: const TextStyle(color: MedColors.amber, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: context.l10n.session_locked_suffix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
