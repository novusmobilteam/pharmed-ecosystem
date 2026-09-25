// widgets/cabin_shell_widgets/execution/cabin_drawer_stage_overlay.dart
//
// [SWREQ-CLI-CABINEXEC-002] [IEC 62304 §5.5]
// Çekmece Opened değilken (ya da durdurma bekleniyorken) içeriğin üstüne
// dialog görünümlü bir durum kartı çizer. Navigator KULLANMAZ — stage
// değiştikçe kart içeriği anında güncellenir; gerçek dialog'lar (hata, QR,
// şahit) Navigator'da olduğu için doğal olarak üstte açılır.
//
// Alttaki içerik her zaman ağaçta kalır (girişler kaybolmaz), sadece
// erişilemez. Mesajlar çekmecenin fiziksel durumuna aittir — hangi ekranda
// olunduğundan bağımsız (masterDrawer_* key'leri). Dolum/sayım/boşaltmanın
// yanında alım ve iade de kendi gövdelerini bununla sarar.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/hardware/hardware.dart';

class CabinDrawerStageOverlay extends StatelessWidget {
  const CabinDrawerStageOverlay({
    super.key,
    required this.stage,
    required this.child,
    this.isStopping = false,
    this.isLastJob = false,
  });

  final MasterDrawerStage stage;
  final Widget child;

  /// Durdurma onaylandı, kapanış bekleniyor — her stage'in önüne geçer.
  final bool isStopping;

  /// Idle/Closed ara anında "açılıyor" yerine "tamamlanıyor" göstermek için.
  final bool isLastJob;

  static const _fade = Duration(milliseconds: 180);

  bool get _isVisible => isStopping || stage is! MasterDrawerOpened;

  @override
  Widget build(BuildContext context) {
    final info = _isVisible ? _StageInfo.of(context, stage, isStopping: isStopping, isLastJob: isLastJob) : null;

    return Stack(
      children: [
        child,
        // Perde ve kart kısa bir geçişle gelir/gider — çekmeceler arasındaki
        // çok kısa Closed → Idle → Opening anlarında titreme olmasın.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_isVisible,
            child: AnimatedOpacity(
              opacity: _isVisible ? 1 : 0,
              duration: _fade,
              child: const ModalBarrier(dismissible: false, color: Colors.transparent),
            ),
          ),
        ),
        if (info != null)
          Center(
            child: AnimatedSwitcher(
              duration: _fade,
              child: _StageCard(key: ValueKey(info.title), info: info),
            ),
          ),
      ],
    );
  }
}

// ── Kart ──────────────────────────────────────────────────────────────

enum _StageKind {
  /// Sistem çalışıyor — kullanıcı bekler (dönen gösterge).
  working,

  /// Kullanıcıdan fiziksel bir eylem bekleniyor (çek / kapat).
  action,

  /// Donanım hatası.
  error,
}

class _StageInfo {
  const _StageInfo({required this.kind, required this.icon, required this.title, required this.subtitle});

  final _StageKind kind;
  final IconData icon;
  final String title;
  final String subtitle;

  static _StageInfo of(
    BuildContext context,
    MasterDrawerStage stage, {
    required bool isStopping,
    required bool isLastJob,
  }) {
    final l10n = context.l10n;

    if (isStopping) {
      return _StageInfo(
        kind: _StageKind.action,
        icon: PhosphorIcons.lock(),
        title: l10n.masterDrawer_stop_waitingCloseTitle,
        subtitle: l10n.masterDrawer_stop_waitingCloseSubtitle,
      );
    }

    // Çekmeceler arası geçiş ya da kuyruk bitişi — son işse "açılıyor" yanlış olur.
    if (stage is MasterDrawerIdle || stage is MasterDrawerClosed) {
      return isLastJob
          ? _StageInfo(
              kind: _StageKind.working,
              icon: PhosphorIcons.checkCircle(),
              title: l10n.masterDrawer_status_completingTitle,
              subtitle: l10n.masterDrawer_status_completingSubtitle,
            )
          : _StageInfo(
              kind: _StageKind.working,
              icon: PhosphorIcons.hourglass(),
              title: l10n.masterDrawer_status_openingTitle,
              subtitle: l10n.masterDrawer_status_openingSubtitle,
            );
    }

    return switch (stage) {
      MasterDrawerOpening(step: MasterDrawerOpeningStep.lockOpening) => _StageInfo(
        kind: _StageKind.working,
        icon: PhosphorIcons.lockOpen(),
        title: l10n.masterDrawer_status_lockOpeningTitle,
        subtitle: l10n.masterDrawer_status_lockOpeningSubtitle,
      ),
      MasterDrawerOpening() => _StageInfo(
        kind: _StageKind.working,
        icon: PhosphorIcons.hourglass(),
        title: l10n.masterDrawer_status_devicePreparingTitle,
        subtitle: l10n.masterDrawer_status_devicePreparingSubtitle,
      ),
      MasterDrawerWaitingForPull() => _StageInfo(
        kind: _StageKind.action,
        icon: PhosphorIcons.handGrabbing(),
        title: l10n.masterDrawer_status_waitingPullTitle,
        subtitle: l10n.masterDrawer_status_waitingPullSubtitle,
      ),
      MasterDrawerOpeningLid() => _StageInfo(
        kind: _StageKind.working,
        icon: PhosphorIcons.package(),
        title: l10n.masterDrawer_status_openingLidTitle,
        subtitle: l10n.masterDrawer_status_openingLidSubtitle,
      ),
      MasterDrawerWaitingForClose() => _StageInfo(
        kind: _StageKind.action,
        icon: PhosphorIcons.lock(),
        title: l10n.masterDrawer_status_waitingCloseTitle,
        subtitle: l10n.masterDrawer_status_waitingCloseSubtitle,
      ),
      MasterDrawerFailed() || MasterDrawerLidFailed() => _StageInfo(
        kind: _StageKind.error,
        icon: PhosphorIcons.warningCircle(),
        title: l10n.masterDrawer_status_failedTitle,
        subtitle: l10n.masterDrawer_status_failedSubtitle,
      ),
      _ => _StageInfo(
        kind: _StageKind.working,
        icon: PhosphorIcons.hourglass(),
        title: l10n.masterDrawer_status_openingTitle,
        subtitle: l10n.masterDrawer_status_openingSubtitle,
      ),
    };
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({super.key, required this.info});

  final _StageInfo info;

  @override
  Widget build(BuildContext context) {
    final (Color accent, Color tint) = switch (info.kind) {
      _StageKind.working => (MedColors.blue, MedColors.blueLight),
      _StageKind.action => (MedColors.amber, MedColors.amberLight),
      _StageKind.error => (MedColors.red, MedColors.redLight),
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        margin: MedSpacing.insetXl,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: MedRadius.lgAll,
          border: Border.all(color: accent.withValues(alpha: 0.4)),
          boxShadow: MedShadows.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(info.icon, size: 30, color: accent),
            ),
            Text(info.title, textAlign: TextAlign.center, style: MedTextStyles.titleMd()),
            Text(
              info.subtitle,
              textAlign: TextAlign.center,
              style: MedTextStyles.bodyMd(color: MedColors.text3),
            ),
            // Sadece sistem çalışırken — kullanıcı eylemi beklenen adımlarda
            // dönen gösterge "bekle" mesajı verip yanıltırdı.
            if (info.kind == _StageKind.working)
              const Padding(padding: EdgeInsets.only(top: 4), child: MedLoadingIndicator()),
          ],
        ),
      ),
    );
  }
}
