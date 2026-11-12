import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
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

  /// Çekmece açıkken oluşan hata dialogda kalır (Tekrar Dene). Dolumdaki gibi
  /// yalnız dialog dışındaki hata snackbar ile gösterilip kapatılır. Önceden
  /// her hata hemen kapatılıyor, açık çekmecenin oturumu durduruluyordu.
  void _handleError(BuildContext context, MobileIntakeState state, MobileIntakeNotifier notifier) {
    if (state is! MobileIntakeError) return;
    final stage = ref.read(mobileDrawerSessionProvider).stage;
    if (state.shouldKeepDialog(stage)) return;
    MessageUtils.showErrorSnackbar(context, state.message);
    notifier.dismissError();
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
      // Dialogda gösterilen hata, çekmece kapanınca dialogla birlikte kapanır;
      // kullanıcı ekranda takılı kalmasın diye snackbar'a düşürülür.
      _handleError(context, ref.read(mobileIntakeNotifierProvider), notifier);
    });

    // Error/Success snackbar
    ref.listen(mobileIntakeNotifierProvider, (_, next) {
      if (next is MobileIntakeError) {
        _handleError(context, next, notifier);
      } else if (next is MobileIntakeFatalError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
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
