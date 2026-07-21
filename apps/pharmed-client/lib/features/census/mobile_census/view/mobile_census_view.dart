import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../census.dart';
import 'mobile_census_dialog.dart';

class MobileCensusView extends ConsumerStatefulWidget {
  const MobileCensusView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MobileCensusView> createState() => _MobileCensusViewState();
}

class _MobileCensusViewState extends ConsumerState<MobileCensusView> {
  /// Dialog şu an ekranda mı? Çift açma / yanlış pop'lamayı engeller.
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MobileCensusView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mobileCensusNotifierProvider.notifier).init(data);
    });
  }

  /// Dialog sync — sadece AÇMA. Kapama dialog'un kendi sorumluluğu
  /// (shouldKeepDialog false olunca kendini pop eder). Manuel pop yok →
  /// hızlı state geçişlerinde dialog birikmesi yapısal olarak imkansız.
  void _syncDialog(BuildContext context) {
    final state = ref.read(mobileCensusNotifierProvider);
    final stage = ref.read(mobileDrawerSessionProvider).stage;
    final shouldBeOpen = state.shouldKeepDialog(stage);

    if (shouldBeOpen && !_isDialogOpen) {
      _isDialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const MobileCensusDialog(),
      ).then((_) => _isDialogOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileCensusNotifierProvider);
    final notifier = ref.read(mobileCensusNotifierProvider.notifier);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

    // Dialog sync — notifier veya drawer session değişimi her ikisini de tetikler
    ref.listen<MobileCensusState>(mobileCensusNotifierProvider, (_, _) {
      _syncDialog(context);
    });
    ref.listen<MobileDrawerSessionState>(mobileDrawerSessionProvider, (_, _) {
      _syncDialog(context);
    });

    // Error: Dialog açıksa snackbar gösterme — dialog kendi banner'ını ve
    // "Tekrar Dene" butonunu içeride sunar. Dialog kapalıyken (init / baseline
    // scan fail) snackbar fallback olarak çalışır.
    // Success: snackbar + dismissSuccess.
    ref.listen(mobileCensusNotifierProvider, (_, next) {
      if (next is MobileCensusError) {
        final stage = ref.read(mobileDrawerSessionProvider).stage;
        if (!next.shouldKeepDialog(stage)) {
          MessageUtils.showErrorSnackbar(context, next.message);
          notifier.dismissError();
        }
      } else if (next is MobileCensusFatalError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      } else if (next is MobileCensusSuccess) {
        MessageUtils.showSuccessSnackbar(context, context.l10n.census_success_completed);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MobileCensusUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (widget.data == null || state is MobileCensusUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return CabinOperationScaffold(
      leftPanel: MobileCabinOverviewPanel(
        slots: state.slots,
        selectedSlotId: state.selectedSlotId,
        mode: CabinOperationMode.census,
        onSlotTap: notifier.onSlotTap,
      ),
      centerPanel: MobileCabinDrawerPanel(
        mode: CabinOperationMode.census,
        slot: state.selectedSlot,
        selectedCell: state.selectedCell,
        onCellTap: notifier.onCellTap,
        assignmentByCoord: state.assignmentByCoord,
      ),
      rightPanel: MobileCensusPanel(
        notifier: notifier,
        state: state,
        drawerStage: drawerStage,
        onStartCensus: notifier.startCensus,
        onSelectAssignment: notifier.selectAssignment,
        onChangePatient: notifier.clearPatientSelection,
        onToggleItem: notifier.toggleItemSelection,
      ),
    );
  }
}
