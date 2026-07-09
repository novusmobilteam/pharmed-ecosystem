// pharmed-client/lib/core/cabin_operation/widget/master_drawer_operation_wrapper.dart
//
// [SWREQ-CLI-CABIN-OP-014] [IEC 62304 §5.5]
// Master kabin operasyonlarını saran görsel widget.
//
// Tüm master kabin feature'ları (refill, count, fault) bu wrapper'ı kullanır.
// Sol alt köşede MasterDrawerStatusBanner gösterir.
//
// MobileDrawerOperationWrapper ile paralel tasarım.
//
// Sınıf: Class A (görsel; karar üretmez)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../cabin_operation.dart';

// ── Wrapper ───────────────────────────────────────────────────────────────────

class MasterDrawerOperationWrapper extends ConsumerWidget {
  const MasterDrawerOperationWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = ref.watch(masterDrawerSessionProvider).stage;

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(left: 20, bottom: 20, child: MasterDrawerStatusBanner(stage: stage)),
      ],
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────

/// Master kabin çekmece oturumunun durumunu sol alt köşede gösteren banner.
/// Modal değil — kullanıcı arka plandaki ekranı kullanmaya devam edebilir.
///
/// Sınıf: Class A (görsel; karar üretmez)
class MasterDrawerStatusBanner extends StatelessWidget {
  const MasterDrawerStatusBanner({super.key, required this.stage});

  final MasterDrawerStage stage;

  @override
  Widget build(BuildContext context) {
    if (stage is MasterDrawerIdle) return const SizedBox.shrink();

    final spec = _resolveSpec(context, stage);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(spec.runtimeKey),
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: MedColors.border),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: MedShadows.sm,
        ),
        child: IntrinsicHeight(
          child: Row(
            spacing: 10.0,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: spec.leading),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        spec.title,
                        style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (spec.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            spec.subtitle!,
                            style: MedTextStyles.monoXs(color: spec.subtitleColor ?? MedColors.text3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _BannerSpec _resolveSpec(BuildContext context, MasterDrawerStage stage) => switch (stage) {
    MasterDrawerIdle() => const _BannerSpec(
      runtimeKey: 'idle',
      accentColor: MedColors.text3,
      title: '',
      leading: SizedBox.shrink(),
    ),

    MasterDrawerOpening(:final message) => _BannerSpec(
      runtimeKey: 'opening',
      accentColor: MedColors.blue,
      title: context.l10n.common_action_drawerOpening,
      subtitle: message,
      leading: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: MedColors.blue),
      ),
    ),

    MasterDrawerWaitingForPull() => _BannerSpec(
      runtimeKey: 'waiting_pull',
      accentColor: MedColors.amber,
      title: context.l10n.common_action_pullDrawerTitle,
      subtitle: context.l10n.common_action_pullDrawerSubtitle,
      leading: _CircleIcon(
        color: MedColors.amber,
        bg: MedColors.amberLight,
        icon: PhosphorIcons.arrowFatLineRight(PhosphorIconsStyle.bold),
      ),
    ),

    MasterDrawerOpeningLid() => _BannerSpec(
      runtimeKey: 'opening_lid',
      accentColor: MedColors.blue,
      title: context.l10n.masterDrawer_openingLidTitle,
      subtitle: context.l10n.masterDrawer_openingLidSubtitle,
      leading: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: MedColors.blue),
      ),
    ),

    MasterDrawerOpened() => _BannerSpec(
      runtimeKey: 'opened',
      accentColor: MedColors.green,
      title: context.l10n.refill_status_drawerOpen,
      subtitle: context.l10n.masterDrawer_readySubtitle,
      leading: _CircleIcon(
        color: MedColors.green,
        bg: MedColors.greenLight,
        icon: PhosphorIcons.check(PhosphorIconsStyle.bold),
      ),
    ),

    MasterDrawerWaitingForClose() => _BannerSpec(
      runtimeKey: 'waiting_close',
      accentColor: MedColors.amber,
      title: context.l10n.common_action_closeDrawerTitle,
      subtitle: context.l10n.common_action_closeDrawerSubtitle,
      leading: _CircleIcon(
        color: MedColors.amber,
        bg: MedColors.amberLight,
        icon: PhosphorIcons.arrowFatLineLeft(PhosphorIconsStyle.bold),
      ),
    ),

    MasterDrawerClosed() => _BannerSpec(
      runtimeKey: 'closed',
      accentColor: MedColors.green,
      title: context.l10n.common_action_drawerClosed,
      subtitle: context.l10n.common_action_operationCompletedSubtitle,
      leading: _CircleIcon(
        color: MedColors.green,
        bg: MedColors.greenLight,
        icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      ),
    ),

    MasterDrawerFailed(:final message) => _BannerSpec(
      runtimeKey: 'failed',
      accentColor: MedColors.red,
      title: context.l10n.common_action_drawerError,
      subtitle: message,
      subtitleColor: MedColors.red,
      leading: _CircleIcon(
        color: MedColors.red,
        bg: MedColors.redLight,
        icon: PhosphorIcons.x(PhosphorIconsStyle.bold),
      ),
    ),
  };
}

// ── Internal helpers ──────────────────────────────────────────────────────────

class _BannerSpec {
  const _BannerSpec({
    required this.runtimeKey,
    required this.accentColor,
    required this.title,
    required this.leading,
    this.subtitle,
    this.subtitleColor,
  });

  final String runtimeKey;
  final Color accentColor;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget leading;
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.color, required this.bg, required this.icon});

  final Color color;
  final Color bg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
