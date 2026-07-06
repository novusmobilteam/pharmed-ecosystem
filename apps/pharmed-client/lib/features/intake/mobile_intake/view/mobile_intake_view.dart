import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../../../widgets/widgets.dart';
import '../../intake.dart';
import 'mobile_intake_dialog.dart';

class MobileIntakeView extends ConsumerStatefulWidget {
  const MobileIntakeView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileIntakeViewState();
}

class _MobileIntakeViewState extends ConsumerState<MobileIntakeView> {
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MobileIntakeView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mobileIntakeNotifierProvider.notifier).init(data);
    });
  }

  void _syncDialog(BuildContext context) {
    final state = ref.read(mobileIntakeNotifierProvider);
    final stage = ref.read(mobileDrawerSessionProvider).stage;
    final shouldBeOpen = state.shouldKeepDialog(stage);

    if (shouldBeOpen && !_isDialogOpen) {
      _isDialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const MobileIntakeDialog(),
      ).then((_) => _isDialogOpen = false);
    } else if (!shouldBeOpen && _isDialogOpen) {
      _isDialogOpen = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final notifier = ref.read(mobileIntakeNotifierProvider.notifier);

    // Drawer session stage'i panel'e geçirilecek; ayrıca _RefillActionBar
    // buton seçiminde kullanır.
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

    ref.listen<MobileIntakeState>(mobileIntakeNotifierProvider, (_, _) {
      _syncDialog(context);
    });
    ref.listen<MobileDrawerSessionState>(mobileDrawerSessionProvider, (_, _) {
      _syncDialog(context);
    });

    // Error/Success snackbar
    ref.listen(mobileIntakeNotifierProvider, (_, next) {
      if (next is MobileIntakeError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is MobileIntakeFatalError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is MobileIntakeSuccess) {
        MessageUtils.showSuccessSnackbar(context, context.l10n.intake_success_completed);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MobileIntakeUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return CabinOperationScaffold(
      leftPanel: MobileCabinOverviewPanel(
        slots: state.slots,
        selectedSlotId: state.selectedSlotId,
        mode: CabinOperationMode.intake,
        onSlotTap: notifier.onSlotTap,
      ),
      centerPanel: MobileCabinDrawerPanel(
        mode: CabinOperationMode.intake,
        slot: state.selectedSlot,
        selectedCell: state.selectedCell,
        onCellTap: notifier.onCellTap,
        assignmentByCoord: state.assignmentByCoord,
      ),
      rightPanel: MobileIntakePanel(
        notifier: notifier,
        state: state,
        drawerStage: drawerStage,
        onStartIntake: notifier.startIntake,
        onCompleteIntake: notifier.completeIntake,
        onSelectAssignment: notifier.selectAssignment,
        onChangePatient: notifier.clearPatientSelection,
        onToggleItem: notifier.toggleItemSelection,
      ),
    );
  }
}
