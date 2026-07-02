// [SWREQ-CLI-INTAKE-010] [IEC 62304 §5.5]
// Mobil ilaç alım işlemi tam ekran dialog'u.
//
// Çekmece açıldığında otomatik gösterilir, alım tamamlanınca kapanır.
// State değişiklikleri ref.watch ile yansır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../widgets/cabin_operation_dialog/cabin_operation_dialog.dart';
import '../../intake.dart';

part 'items_list.dart';
part 'footer.dart';

class MobileIntakeDialog extends ConsumerWidget {
  const MobileIntakeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final notifier = ref.read(mobileIntakeNotifierProvider.notifier);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

    if (!state.shouldKeepDialog(drawerStage)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    final ready = state.readyContext;

    if (ready == null) {
      return const SizedBox.shrink();
    }

    final errorMessage = state is MobileIntakeError ? state.message : null;

    return CabinOperationDialog(
      type: CabinInventoryType.intake,
      statusInput: OperationStatusInput(
        phase: _intakePhase(state),
        drawerStage: drawerStage,
        baselineCompleted: ready.baselineCompleted,
        canComplete: ready.canComplete,
      ),
      stats: [
        StatCellData(label: 'Seçili', value: '${ready.selectedItemIds.length} ilaç'),
        StatCellData(label: 'Kabinde Okunan', value: '${ready.totalReadCount} etiket'),
        StatCellData(label: 'Alınan', value: '${ready.takenEpcs.length}'),
        StatCellData(
          label: 'İzinsiz Alım',
          value: '${ready.unplannedMovements.length}',
          valueColor: ready.unplannedMovements.isNotEmpty ? MedColors.amber : null,
          icon: ready.unplannedMovements.isNotEmpty ? PhosphorIcons.warning(PhosphorIconsStyle.bold) : null,
        ),
      ],
      banners: [
        if (errorMessage != null)
          const OperationErrorBanner(
            message: 'Tekrar deneyebilir ya da yerleştirdiğiniz ilaçları alarak işleminizi sonlandırabilirsiniz.',
          ),
        if (ready.hasUnplannedMovement) UnplannedMovementBanner(epcs: ready.unplannedMovements),
        if (ready.hasUnexpectedEpc) UnexpectedTagBanner(epcs: ready.placedEpcs),
      ],
      footerContent: _intakeFooter(state, drawerStage, ready, notifier),
      child: _ItemsList(),
    );
  }
}

OperationPhase _intakePhase(MobileIntakeState s) {
  if (s is MobileIntakeFatalError) return OperationPhase.fatal;
  if (s is MobileIntakeSaving) return OperationPhase.saving;
  if (s is MobileIntakeError) return OperationPhase.error;
  return OperationPhase.normal;
}
