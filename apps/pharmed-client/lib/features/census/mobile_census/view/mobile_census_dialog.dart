import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';
import '../../census.dart';

part 'footer.dart';
part 'extra_stock_summary_card.dart';

class MobileCensusDialog extends ConsumerWidget {
  const MobileCensusDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileCensusNotifierProvider);
    final notifier = ref.read(mobileCensusNotifierProvider.notifier);
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

    final errorMessage = state is MobileCensusError ? (state).message : null;

    return CabinOperationDialog(
      type: CabinInventoryType.census,
      statusInput: OperationStatusInput(
        phase: _censusPhase(state),
        drawerStage: drawerStage,
        baselineCompleted: ready.baselineCompleted,
        canComplete: ready.canComplete,
      ),
      stats: [
        StatCellData(
          label: context.l10n.census_label_counted,
          value: '${ready.censusCountedTotal} / ${ready.censusTotalCount}',
          valueColor:
              ready.baselineCompleted &&
                  ready.missingEpcs.isEmpty &&
                  ready.markedMissingItemIds.isEmpty &&
                  ready.censusTotalCount > 0
              ? MedColors.green
              : null,
        ),
        StatCellData(
          label: context.l10n.rfidStatus_missing,
          value: '${ready.totalMissingCount}',
          valueColor: ready.totalMissingCount > 0 ? MedColors.red : null,
        ),
        StatCellData(
          label: context.l10n.census_label_excess,
          value: '${ready.extraStocks.length}',
          valueColor: ready.extraStocks.isNotEmpty ? MedColors.amber : null,
        ),
        StatCellData(
          label: context.l10n.cabinOperation_label_unexpectedTag,
          value: '${ready.placedEpcs.length}',
          valueColor: ready.placedEpcs.isNotEmpty ? MedColors.red : null,
        ),
      ],
      banners: [
        if (errorMessage != null) OperationErrorBanner(message: errorMessage),
        if (ready.placedEpcs.isNotEmpty) UnexpectedTagBanner(epcs: ready.placedEpcs, blocking: true),
        if (ready.missingEpcs.isNotEmpty) MissingStockBanner(count: ready.missingEpcs.length),
      ],
      footerContent: _censusFooter(context, state, drawerStage, ready, notifier),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ready.extraStocks.isNotEmpty) ...[
            _ExtraStockSummaryCard(extraStocks: ready.extraStocks, onRemove: notifier.removeExtraStock),
            const SizedBox(height: MedSpacing.xl),
          ],

          // ── Grup listesi ────────────────────────────────────────────
          Flexible(
            child: ready.groups.isEmpty
                ? const EmptyStateWidget(variant: EmptyStateVariant.noPrescription)
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 4),
                    itemCount: ready.groups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                    itemBuilder: (context, i) {
                      final group = ready.groups[i];
                      return RxCensusGroupCard(
                        group: group,
                        baselineCompleted: ready.baselineCompleted,
                        onToggleMissing: ref.read(mobileCensusNotifierProvider.notifier).toggleMissingMark,
                      );
                    },
                  ),
          ),

          const SizedBox(height: MedSpacing.md),
          _ReportExtraStockButton(onReport: ref.read(mobileCensusNotifierProvider.notifier).addExtraStock),
        ],
      ),
    );
  }
}

OperationPhase _censusPhase(MobileCensusState s) {
  if (s is MobileCensusSaving) return OperationPhase.saving;
  if (s is MobileCensusError) return OperationPhase.error;
  return OperationPhase.normal;
}

class _ReportExtraStockButton extends StatelessWidget {
  const _ReportExtraStockButton({required this.onReport});

  final void Function({required Medicine medicine, required double quantity}) onReport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MedButton(
        label: context.l10n.census_action_reportExtraStock,
        size: MedButtonSize.md,
        variant: MedButtonVariant.danger,

        onPressed: () async {
          final result = await ReportExtraStockDialog.show(context);
          if (result != null) {
            onReport(medicine: result.medicine, quantity: result.quantity);
          }
        },
      ),
    );
  }
}
