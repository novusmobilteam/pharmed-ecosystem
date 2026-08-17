import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ═════════════════════════════════════════════════════════════════
// SessionTimeoutBanner
// [SWREQ-UI-AUTH-002] [HAZ-009]
// Oturum dolmak üzere — sağ alt köşede floating banner.
// ═════════════════════════════════════════════════════════════════

class SessionTimeoutBanner extends StatelessWidget {
  const SessionTimeoutBanner({super.key, required this.secondsRemaining, required this.onExtend});

  final int secondsRemaining;
  final VoidCallback onExtend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.red, width: 2),
        boxShadow: MedShadows.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.clock(), size: 20, color: MedColors.red),
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
                      text: '$secondsRemaining',
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
            onTap: onExtend,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: MedColors.blue),
              child: Text(
                context.l10n.session_timeout_continueButton,
                style: MedTextStyles.bodyMd(color: Colors.white, weight: FontWeight.bold),
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
                  TextSpan(
                    text: context.l10n.session_locked_prefix,
                    style: TextStyle(color: MedColors.text2),
                  ),
                  TextSpan(
                    text: context.l10n.session_locked_reason,
                    style: const TextStyle(color: MedColors.amber, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: context.l10n.session_locked_suffix,
                    style: TextStyle(color: MedColors.text2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
