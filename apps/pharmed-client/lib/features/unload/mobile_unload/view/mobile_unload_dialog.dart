import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../widgets/cabin_operation_dialog/cabin_operation_dialog.dart';
import '../../unload.dart';

part 'item_list.dart';
part 'footer.dart';

class MobileUnloadDialog extends ConsumerWidget {
  const MobileUnloadDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileUnloadNotifierProvider);
    final notifier = ref.watch(mobileUnloadNotifierProvider.notifier);
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
    if (ready == null) return const SizedBox.shrink();

    final isRollback = state is MobileUnloadRollbackInProgress;
    final errorMessage = state is MobileUnloadError ? (state).message : null;

    return CabinOperationDialog(
      type: CabinInventoryType.unload,
      statusInput: OperationStatusInput(
        phase: _unloadPhase(state),
        drawerStage: drawerStage,
        baselineCompleted: ready.baselineCompleted,
        canComplete: ready.canComplete,
        rollbackSettling: state is MobileUnloadRollbackInProgress && ready.rfidReadEpcs.isEmpty,
      ),
      stats: [
        StatCellData(label: 'Seçili', value: '${ready.selectedItemIds.length} ilaç'),
        StatCellData(label: 'Kabinde Okunan', value: '${ready.rfidReadEpcs.length} etiket'),
        StatCellData(
          label: 'Plan Dışı',
          value: '${ready.unplannedMovements.length}',
          valueColor: ready.unplannedMovements.isNotEmpty ? MedColors.red : null,
          icon: ready.unplannedMovements.isNotEmpty ? PhosphorIcons.warning(PhosphorIconsStyle.bold) : null,
        ),
      ],
      banners: [
        if (errorMessage != null) OperationErrorBanner(message: errorMessage),
        if (isRollback)
          const RollbackBanner(
            message:
                'Boşaltma tamamlanamadı. Çıkardığınız ilaçları kabine geri koyun '
                've çekmeceyi kapatarak işlemi sonlandırın.',
          ),
        if (!isRollback && ready.unplannedMovements.isNotEmpty)
          UnplannedMovementBanner(
            epcs: ready.unplannedMovements,
            message:
                'Boşaltma hedefleri dışında ${ready.unplannedMovements.length} etiket kabinden çıkarıldı. '
                'Eczaneye bildirim oluşturulacak.',
          ),
        if (!isRollback && ready.unexpectedEpcs.isNotEmpty) UnexpectedTagBanner(epcs: ready.unexpectedEpcs),
      ],
      footerContent: _unloadFooter(state, drawerStage, ready, notifier),
      child: _ItemsList(),
    );
  }
}

OperationPhase _unloadPhase(MobileUnloadState s) {
  if (s is MobileUnloadFatalError) return OperationPhase.fatal;
  if (s is MobileUnloadSaving) return OperationPhase.saving;
  if (s is MobileUnloadError) return OperationPhase.error;
  if (s is MobileUnloadRollbackInProgress) return OperationPhase.rollback;
  return OperationPhase.normal;
}
