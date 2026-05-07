// pharmed-client/lib/core/cabin_operation/widget/mobile_drawer_status_banner.dart
//
// [SWREQ-CLI-CABIN-OP-003] [IEC 62304 §5.5]
// Çekmece oturumunun durumunu sol alt köşede gösteren bilgilendirici banner.
// Modal değil — kullanıcı arka plandaki ekranı kullanmaya devam edebilir.
//
// RFID veya operasyon-spesifik metinler buradaki banner'a değil, isteyen
// feature'ın kendi UI'ına aittir. Bu banner sadece çekmece durumunu söyler.
//
// Sınıf: Class A (görsel; karar üretmez)

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MobileDrawerStatusBanner extends StatelessWidget {
  const MobileDrawerStatusBanner({super.key, required this.stage});

  final MobileDrawerStage stage;

  @override
  Widget build(BuildContext context) {
    if (stage is MobileDrawerIdle) return const SizedBox.shrink();

    final spec = _resolveSpec(stage);

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
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: MedColors.border, width: 1),
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

  _BannerSpec _resolveSpec(MobileDrawerStage stage) {
    return switch (stage) {
      MobileDrawerIdle() => const _BannerSpec(
        runtimeKey: 'idle',
        accentColor: MedColors.text3,
        title: '',
        leading: SizedBox.shrink(),
      ),

      MobileDrawerOpening(:final port) => _BannerSpec(
        runtimeKey: 'opening',
        accentColor: MedColors.blue,
        title: 'Çekmece açılıyor',
        subtitle: 'Çekmece $port',
        leading: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: MedColors.blue),
        ),
      ),

      MobileDrawerOpened() => _BannerSpec(
        runtimeKey: 'opened',
        accentColor: MedColors.green,
        title: 'Çekmece açık',
        subtitle: 'İşlemi tamamlamak için çekmeceyi kapatınız.',
        leading: _CircleIcon(
          color: MedColors.green,
          bg: MedColors.greenLight,
          icon: PhosphorIcons.check(PhosphorIconsStyle.bold),
        ),
      ),

      MobileDrawerClosed() => _BannerSpec(
        runtimeKey: 'closed',
        accentColor: MedColors.green,
        title: 'Çekmece kapatıldı',
        subtitle: 'İşlem onayınızı bekliyor',
        leading: _CircleIcon(
          color: MedColors.green,
          bg: MedColors.greenLight,
          icon: PhosphorIcons.check(PhosphorIconsStyle.bold),
        ),
      ),

      MobileDrawerFailed(:final message) => _BannerSpec(
        runtimeKey: 'failed',
        accentColor: MedColors.red,
        title: 'Çekmece hatası',
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
}

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
