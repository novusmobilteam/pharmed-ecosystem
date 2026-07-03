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

    final errorMessage = state is MobileUnloadError ? (state).message : null;

    return CabinOperationDialog(
      type: CabinInventoryType.unload,
      statusInput: OperationStatusInput(
        phase: _unloadPhase(state),
        drawerStage: drawerStage,
        baselineCompleted: ready.baselineCompleted,
        canComplete: ready.canComplete,
      ),
      stats: [
        StatCellData(
          label: 'Boşaltıldı',
          value: '${ready.unloadCountedTotal} / ${ready.unloadTotalCount}',
          valueColor:
              ready.baselineCompleted &&
                  ready.missingEpcs.isEmpty &&
                  ready.markedMissingItemIds.isEmpty &&
                  ready.unloadTotalCount > 0
              ? MedColors.green
              : null,
        ),
        StatCellData(
          label: 'Eksik',
          value: '${ready.totalMissingCount}',
          valueColor: ready.totalMissingCount > 0 ? MedColors.red : null,
        ),
        StatCellData(
          label: 'Plan Dışı',
          value: '${ready.unplannedCount}',
          valueColor: ready.unplannedCount > 0 ? MedColors.red : null,
        ),
        StatCellData(
          label: 'Yabancı',
          value: '${ready.placedEpcs.length}',
          valueColor: ready.placedEpcs.isNotEmpty ? MedColors.red : null,
        ),
      ],
      banners: [
        if (errorMessage != null) OperationErrorBanner(message: errorMessage),
        if (ready.placedEpcs.isNotEmpty) UnexpectedTagBanner(epcs: ready.placedEpcs, blocking: true),
        if (ready.missingEpcs.isNotEmpty) MissingStockBanner(count: ready.missingEpcs.length),
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
  return OperationPhase.normal;
}
