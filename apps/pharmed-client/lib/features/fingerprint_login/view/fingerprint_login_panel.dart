// pharmed-client/lib/features/fingerprint_login/view/fingerprint_login_panel.dart
//
// [SWREQ-FP-103] [SWREQ-FP-105]
// Giriş penceresinin altındaki parmak izi bölümü (LoginModal.footer).
// Pencere açık olduğu sürece okuyucu dinlenir; pencere kapanınca okuma iptal edilir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'package:pharmed_client/features/fingerprint_enrollment/view/fingerprint_labels.dart';

import '../notifier/fingerprint_login_notifier.dart';

class FingerprintLoginPanel extends ConsumerStatefulWidget {
  const FingerprintLoginPanel({super.key, this.onLoggedIn});

  /// Parmak iziyle giriş başarılı olunca çağrılır (örn. pencereyi kapatmak için).
  final VoidCallback? onLoggedIn;

  @override
  ConsumerState<FingerprintLoginPanel> createState() => _FingerprintLoginPanelState();
}

class _FingerprintLoginPanelState extends ConsumerState<FingerprintLoginPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(fingerprintLoginNotifierProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(fingerprintLoginNotifierProvider.select((n) => n.status), (prev, next) {
      if (next == FingerprintLoginStatus.success && prev != next) widget.onLoggedIn?.call();
    });

    final n = ref.watch(fingerprintLoginNotifierProvider);
    final l = context.l10n;

    final (Color color, String text) = switch (n.status) {
      FingerprintLoginStatus.opening => (MedColors.text3, l.fingerprint_login_opening),
      FingerprintLoginStatus.unavailable => (
        MedColors.text3,
        n.scannerFailure == null ? l.fingerprint_login_scannerUnavailable : n.scannerFailure!.label(context),
      ),
      FingerprintLoginStatus.waitingLift => (MedColors.amber, l.fingerprint_enroll_liftFinger),
      FingerprintLoginStatus.listening => (MedColors.blue, l.fingerprint_login_hint),
      FingerprintLoginStatus.checking => (MedColors.blue, l.fingerprint_login_checking),
      FingerprintLoginStatus.cooldown => (MedColors.red, l.fingerprint_login_cooldown(n.cooldownSecondsLeft)),
      FingerprintLoginStatus.idle => (MedColors.text3, l.fingerprint_login_idle),
      FingerprintLoginStatus.success => (MedColors.green, l.fingerprint_login_success),
    };

    final canRetry = n.status == FingerprintLoginStatus.unavailable || n.status == FingerprintLoginStatus.idle;
    final busy = n.status == FingerprintLoginStatus.opening || n.status == FingerprintLoginStatus.checking;
    final hint = n.lastCaptureFailure?.label(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: MedColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md),
              child: Text(l.fingerprint_login_divider, style: MedTextStyles.bodySm(color: MedColors.text3)),
            ),
            const Expanded(child: Divider(color: MedColors.border)),
          ],
        ),
        const SizedBox(height: MedSpacing.md),
        Container(
          padding: MedSpacing.insetLg,
          decoration: BoxDecoration(
            color: MedColors.surface2,
            border: Border.all(color: MedColors.border),
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: busy
                    ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2))
                    : _PulsingIcon(color: color, pulse: n.status == FingerprintLoginStatus.listening),
              ),
              const SizedBox(width: MedSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(text, style: MedTextStyles.bodySm(color: color, weight: FontWeight.w600)),
                    if (n.message != null && n.status != FingerprintLoginStatus.checking) ...[
                      const SizedBox(height: 4),
                      Text(n.message!, style: MedTextStyles.bodySm(color: MedColors.red)),
                    ] else if (hint != null && n.status == FingerprintLoginStatus.listening) ...[
                      const SizedBox(height: 4),
                      Text(hint, style: MedTextStyles.bodySm(color: MedColors.amber)),
                    ],
                  ],
                ),
              ),
              if (canRetry)
                MedButton(
                  label: n.status == FingerprintLoginStatus.idle
                      ? l.fingerprint_login_resumeButton
                      : l.fingerprint_enroll_scannerRetryButton,
                  size: MedButtonSize.sm,
                  variant: MedButtonVariant.ghost,
                  onPressed: n.retry,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dinleme sırasında hafifçe nefes alan parmak izi simgesi.
class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.color, required this.pulse});
  final Color color;
  final bool pulse;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _PulsingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) _sync();
  }

  void _sync() {
    if (widget.pulse) {
      _c.repeat(reverse: true);
    } else {
      _c
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_c),
      child: Icon(Icons.fingerprint, size: 32, color: widget.color),
    );
  }
}
