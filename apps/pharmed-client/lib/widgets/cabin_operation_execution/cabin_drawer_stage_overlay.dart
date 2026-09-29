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
// KÜBİK KAPAK (awaitLidClose ile açılan gözler — şu an alım):
//   • WaitingForLidClose → "Kapağı kapatın" (kullanıcı eylemi).
//   • LidClosed          → kart GÖSTERİLMEZ: kayıt/QR anı; form zaten
//                          isSaving ile kilitli, QR dialog'u Navigator'da.
//   • LidFailed          → nedene özgü mesaj + eylem butonları (callback
//                          verilmişse). Callback verilmeyen ekranlarda eski
//                          genel hata kartı gösterilir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/hardware/hardware.dart';
import '../../core/hardware/cabin/master_drawer/master_drawer_failure_extension.dart';

class CabinDrawerStageOverlay extends StatelessWidget {
  const CabinDrawerStageOverlay({
    super.key,
    required this.stage,
    required this.child,
    this.isStopping = false,
    this.isLastJob = false,
    this.onRetryLid,
    this.onSkipLid,
    this.onAcknowledgeLidClosed,
  });

  final MasterDrawerStage stage;
  final Widget child;

  /// Durdurma onaylandı, kapanış bekleniyor — her stage'in önüne geçer.
  final bool isStopping;

  /// Idle/Closed ara anında "açılıyor" yerine "tamamlanıyor" göstermek için.
  final bool isLastJob;

  // ── Kübik kapak hatası (LidFailed) eylemleri ──
  // Verilmezse ilgili buton çizilmez; üçü de yoksa eski genel hata kartı.
  final VoidCallback? onRetryLid;
  final VoidCallback? onSkipLid;
  final VoidCallback? onAcknowledgeLidClosed;

  static const _fade = Duration(milliseconds: 180);

  bool get _isVisible => isStopping || (stage is! MasterDrawerOpened && stage is! MasterDrawerLidClosed);

  @override
  Widget build(BuildContext context) {
    final info = _isVisible
        ? _StageInfo.of(
            context,
            stage,
            isStopping: isStopping,
            isLastJob: isLastJob,
            onRetryLid: onRetryLid,
            onSkipLid: onSkipLid,
            onAcknowledgeLidClosed: onAcknowledgeLidClosed,
          )
        : null;

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
              child: _StageCard(key: ValueKey(info.key), info: info),
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

class _StageAction {
  const _StageAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class _StageInfo {
  const _StageInfo({
    required this.kind,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.hint,
    this.actions = const [],
  });

  final _StageKind kind;
  final IconData icon;
  final String title;
  final String subtitle;

  /// Alt metnin altında vurgulu ek bilgi (örn. sensör geri gelirse devam eder).
  final String? hint;

  final List<_StageAction> actions;

  /// AnimatedSwitcher anahtarı — aynı başlıklı farklı kapak hataları da
  /// geçiş animasyonu alsın.
  String get key => '$title|$subtitle';

  static _StageInfo of(
    BuildContext context,
    MasterDrawerStage stage, {
    required bool isStopping,
    required bool isLastJob,
    VoidCallback? onRetryLid,
    VoidCallback? onSkipLid,
    VoidCallback? onAcknowledgeLidClosed,
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
      MasterDrawerWaitingForLidClose() => _StageInfo(
        kind: _StageKind.action,
        icon: PhosphorIcons.lock(),
        title: l10n.masterDrawer_lid_waitingCloseTitle,
        subtitle: l10n.masterDrawer_lid_waitingCloseSubtitle,
      ),
      MasterDrawerWaitingForClose() => _StageInfo(
        kind: _StageKind.action,
        icon: PhosphorIcons.lock(),
        title: l10n.masterDrawer_status_waitingCloseTitle,
        subtitle: l10n.masterDrawer_status_waitingCloseSubtitle,
      ),
      MasterDrawerLidFailed(:final failure, :final detail)
          when onRetryLid != null || onSkipLid != null || onAcknowledgeLidClosed != null =>
        _lidFailedInfo(
          context,
          failure,
          detail,
          onRetryLid: onRetryLid,
          onSkipLid: onSkipLid,
          onAcknowledgeLidClosed: onAcknowledgeLidClosed,
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

  /// Neden → görünüm + buton seti:
  ///   lidDrawerNotOpen           → action (amber) · Tekrar Dene
  ///   lidNotOpened               → action (amber) · Bu Gözü Atla + Tekrar Dene
  ///   lidOpenFailed (ve diğer)   → error (kırmızı) · Bu Gözü Atla + Tekrar Dene
  ///   lidSensorLost              → error (kırmızı) · Kapağı Kapattım
  ///     (Tekrar Dene YOK: açma komutunu yeniden göndermek anlamsız; izleme
  ///     sürdüğü için bağlantı gelirse akış kendiliğinden devam eder.)
  static _StageInfo _lidFailedInfo(
    BuildContext context,
    MasterDrawerFailure failure,
    String? detail, {
    VoidCallback? onRetryLid,
    VoidCallback? onSkipLid,
    VoidCallback? onAcknowledgeLidClosed,
  }) {
    final l10n = context.l10n;
    final retry = onRetryLid == null
        ? null
        : _StageAction(label: l10n.masterDrawer_lid_retryButton, onPressed: onRetryLid);
    final skip = onSkipLid == null ? null : _StageAction(label: l10n.masterDrawer_lid_skipButton, onPressed: onSkipLid);
    final acknowledge = onAcknowledgeLidClosed == null
        ? null
        : _StageAction(label: l10n.masterDrawer_lid_acknowledgeClosedButton, onPressed: onAcknowledgeLidClosed);

    final message = failure.message(context, detail: detail);

    return switch (failure) {
      MasterDrawerFailure.lidDrawerNotOpen => _StageInfo(
        kind: _StageKind.action,
        icon: PhosphorIcons.arrowsOutLineVertical(),
        title: l10n.masterDrawer_status_failedTitle,
        subtitle: message,
        actions: [?retry],
      ),
      MasterDrawerFailure.lidNotOpened => _StageInfo(
        kind: _StageKind.action,
        icon: PhosphorIcons.handGrabbing(),
        title: l10n.masterDrawer_status_failedTitle,
        subtitle: message,
        actions: [?skip, ?retry],
      ),
      MasterDrawerFailure.lidSensorLost => _StageInfo(
        kind: _StageKind.error,
        icon: PhosphorIcons.wifiSlash(),
        title: l10n.masterDrawer_status_failedTitle,
        subtitle: message,
        hint: l10n.masterDrawer_lid_sensorLostHint,
        actions: [?acknowledge],
      ),
      _ => _StageInfo(
        kind: _StageKind.error,
        icon: PhosphorIcons.warningCircle(),
        title: l10n.masterDrawer_status_failedTitle,
        subtitle: message,
        actions: [?skip, ?retry],
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
            if (info.hint case final hint?)
              Text(
                hint,
                textAlign: TextAlign.center,
                style: MedTextStyles.bodySm(color: MedColors.blue),
              ),
            // Sadece sistem çalışırken — kullanıcı eylemi beklenen adımlarda
            // dönen gösterge "bekle" mesajı verip yanıltırdı.
            if (info.kind == _StageKind.working)
              const Padding(padding: EdgeInsets.only(top: 4), child: MedLoadingIndicator()),
            if (info.actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  spacing: MedSpacing.lg,
                  children: [
                    for (final action in info.actions)
                      Expanded(
                        child: MedButton(label: action.label, onPressed: action.onPressed),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
