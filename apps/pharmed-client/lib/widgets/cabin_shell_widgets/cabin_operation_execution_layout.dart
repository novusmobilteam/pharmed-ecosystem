// Master kabin işlem ekranlarının (dolum, sayım, alım...) ortak yürütme
// iskeleti. Top strip (progress + durdur), sol konum rehberi
// (CabinLocationGuide) + sağ içerik (form / çekmece durum ekranları) düzenini
// yönetir. MasterDrawerStage union'ının TAMAMINI (Idle/Opening/WaitingForPull/
// OpeningLid/Opened/WaitingForClose/Closed/Failed) ele alır — kullanıcı yalnızca
// Opened durumundayken forma erişebilir, diğer tüm durumlarda duruma özel bir
// bilgilendirme ekranı gösterilir.
//
// Çekmece durum mesajları (Açılıyor/Kilit açılıyor/Kapatın vb.) TAMAMEN
// donanımın fiziksel durumuna ait — hangi ekranda (dolum/sayım/alım)
// olduğumuzdan bağımsız. Bu yüzden dışarıdan callback olarak alınmaz,
// doğrudan burada, masterDrawer_* ARB key'leriyle render edilir.
//
// "Durdur" akışı: kullanıcı CabinOperationTopStrip'in kendi onay dialog'undan
// evet dediğinde, çekmece hâlâ açıksa (stage.isActive) notifier.stopQueue
// HEMEN çağrılmaz — "lütfen çekmeceyi kapatın" bekleme ekranı gösterilir,
// stage inaktif hale gelince (Closed/Idle/Failed) gerçek durdurma tetiklenir.
// Çekmece zaten kapalıysa doğrudan durdurulur.
//
// Bu widget hiçbir notifier/executing state tipini bilmiyor — çağıran panel
// (MasterRefillExecutionPanel vb.) kendi state'inden gerekli değerleri
// türetip buraya value/callback olarak verir (MasterCabinRootScaffold'daki
// "Option B" yaklaşımıyla aynı mantık).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/cabin_overview_panel.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../widgets.dart';

class CabinOperationExecutionLayout extends ConsumerStatefulWidget {
  const CabinOperationExecutionLayout({
    super.key,
    required this.progressLabel,
    required this.progress,
    required this.onStopConfirmed,
    required this.stopLabel,
    required this.stopConfirmTitle,
    required this.stopConfirmMessage,
    required this.stopConfirmYesLabel,
    required this.cancelLabel,
    required this.locationItems,
    required this.activeIndex,
    required this.openedBuilder,
  });

  final String progressLabel;
  final double progress;

  /// Kullanıcı durdurmayı ONAYLADIKTAN sonra (dialog CabinOperationTopStrip
  /// içinde zaten gösterildi) çağrılır — genelde notifier.stopQueue. Scaffold
  /// bunu çekmece kapanana kadar erteler, hemen çağırmaz.
  final Future<void> Function() onStopConfirmed;

  final String stopLabel;
  final String stopConfirmTitle;
  final String stopConfirmMessage;
  final String stopConfirmYesLabel;
  final String cancelLabel;

  /// Genelde `executing.toLocationItems(allGroups)`.
  final List<DrawerQueueItem> locationItems;

  /// Genelde `executing.currentIndex`.
  final int activeIndex;

  /// Çekmece Opened durumundayken gösterilecek form (ör. _FillForm, _CensusForm).
  final WidgetBuilder openedBuilder;

  @override
  ConsumerState<CabinOperationExecutionLayout> createState() => _MasterCabinExecutionScaffoldState();
}

class _MasterCabinExecutionScaffoldState extends ConsumerState<CabinOperationExecutionLayout> {
  bool _stopRequested = false;

  Future<void> _handleStopConfirmed() async {
    final stage = ref.read(masterDrawerSessionProvider).stage;
    if (!stage.isActive) {
      // Çekmece zaten kapalı/boşta/hata durumunda — hemen durdur.
      await widget.onStopConfirmed();
      return;
    }
    setState(() => _stopRequested = true);
  }

  @override
  Widget build(BuildContext context) {
    final drawerStage = ref.watch(masterDrawerSessionProvider).stage;

    // Durdurma bekleniyorken çekmece kapanırsa (isActive false olursa) gerçek
    // durdurmayı tetikle. addPostFrameCallback: build ortasında state
    // değiştirmemek için.
    if (_stopRequested && !drawerStage.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        setState(() => _stopRequested = false);
        await widget.onStopConfirmed();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabinExecutionTopStrip(
          progressLabel: widget.progressLabel,
          progress: widget.progress,
          onStop: _handleStopConfirmed,
          stopLabel: widget.stopLabel,
          stopConfirmTitle: widget.stopConfirmTitle,
          stopConfirmMessage: widget.stopConfirmMessage,
          stopConfirmYesLabel: widget.stopConfirmYesLabel,
          cancelLabel: widget.cancelLabel,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: CabinOperationSelectionLayout(
            left: CabinOverviewPanel.execution(items: widget.locationItems, activeIndex: widget.activeIndex),
            right: _buildContent(context, drawerStage),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, MasterDrawerStage stage) {
    // Durdurma bekleniyorsa (kullanıcı onayladı, çekmece hâlâ açık) her şeyin
    // önüne geçer — form dahi olsa artık gösterilmez, kapatma bekleniyor.
    if (_stopRequested) {
      return MasterDrawerStatusView(
        title: context.l10n.masterDrawer_stop_waitingCloseTitle,
        subtitle: context.l10n.masterDrawer_stop_waitingCloseSubtitle,
      );
    }

    if (stage is MasterDrawerOpened) {
      return widget.openedBuilder(context);
    }

    final (title, subtitle) = _stageInfo(context, stage);
    return MasterDrawerStatusView(title: title, subtitle: subtitle, isError: stage is MasterDrawerFailed);
  }

  /// Çekmecenin fiziksel durumuna ait, ekrandan bağımsız mesaj çifti.
  (String, String) _stageInfo(BuildContext context, MasterDrawerStage stage) {
    return switch (stage) {
      MasterDrawerOpening(step: MasterDrawerOpeningStep.lockOpening) => (
        context.l10n.masterDrawer_status_lockOpeningTitle,
        context.l10n.masterDrawer_status_lockOpeningSubtitle,
      ),
      MasterDrawerOpening() => (
        context.l10n.masterDrawer_status_devicePreparingTitle,
        context.l10n.masterDrawer_status_devicePreparingSubtitle,
      ),
      MasterDrawerWaitingForPull() => (
        context.l10n.masterDrawer_status_waitingPullTitle,
        context.l10n.masterDrawer_status_waitingPullSubtitle,
      ),
      MasterDrawerOpeningLid() => (
        context.l10n.masterDrawer_status_openingLidTitle,
        context.l10n.masterDrawer_status_openingLidSubtitle,
      ),
      MasterDrawerWaitingForClose() => (
        context.l10n.masterDrawer_status_waitingCloseTitle,
        context.l10n.masterDrawer_status_waitingCloseTitle,
      ),
      MasterDrawerFailed() => (
        context.l10n.masterDrawer_status_failedTitle,
        context.l10n.masterDrawer_status_failedSubtitle,
      ),
      // Idle/Closed — bu ekrana normalde hiç düşülmez (Idle: executing==null
      // iken panel zaten hiç build edilmiyor; Closed: hemen sıradaki job
      // açılıyor ya da kuyruk bitiyor, çok kısa ömürlü ara an).
      _ => (context.l10n.masterDrawer_status_openingTitle, context.l10n.masterDrawer_status_openingSubtitle),
    };
  }
}
