// features/unload_drawer/view/unload_drawer_selection_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/rx_operation_card/rx_operation_card_2.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../widgets/widgets.dart';
import '../notifier/unload_drawer_notifier.dart';
import '../notifier/unload_drawer_state.dart';

class UnloadDrawerSelectionView extends ConsumerWidget {
  const UnloadDrawerSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(unloadDrawerNotifierProvider);
    final notifier = ref.read(unloadDrawerNotifierProvider.notifier);

    final mode = state.mode ?? UnloadDrawerMode.drawer;
    final selectedIndex = mode == UnloadDrawerMode.drawer ? 0 : 1;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 400,
            child: MedSegmentedButton(
              selectedIndex: selectedIndex,
              labels: [context.l10n.unload_segment_returnDrawer, context.l10n.unload_segment_returnBox],
              onChanged: (i) => notifier.switchMode(i == 0 ? UnloadDrawerMode.drawer : UnloadDrawerMode.box),
            ),
          ),
          Expanded(child: _buildContent(context, ref, state, mode)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UnloadDrawerState state, UnloadDrawerMode mode) {
    final notifier = ref.read(unloadDrawerNotifierProvider.notifier);

    final selection = switch (state) {
      UnloadDrawerSelection s => s,
      UnloadDrawerError(previousState: UnloadDrawerSelection s) => s,
      _ => null,
    };

    final isLoading = selection == null;
    final items = selection?.items ?? const [];
    final selectedIds = selection?.selectedIds ?? const {};
    final isBoxMode = mode == UnloadDrawerMode.box;

    return CabinSelectionContentShell(
      searchQuery: '',
      onSearchQueryChanged: (_) {},
      searchHint: '',
      showSearch: false,
      isLoading: isLoading,
      isEmpty: !isLoading && items.isEmpty,
      emptyMessage: isBoxMode
          ? context.l10n.unload_hint_noBoxMedicineFound
          : context.l10n.unload_hint_noDrawerMedicineFound,
      content: isLoading
          ? null
          : CabinOperationGrid(
              singleColumnThreshold: 0,
              maxColumns: 4,
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final isSelected = item.id != null && selectedIds.contains(item.id);
                final patientName = item.prescriptionItem?.hospitalization?.patient?.fullName;

                return RxOperationCard2(
                  title: item.material?.name ?? '—',
                  subtitle:
                      '${(item.quantity ?? 0).formatFractional} '
                      '${item.material?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback}'
                      '${patientName != null ? ' • $patientName' : ''}',
                  barcode: item.material?.barcode,
                  isSelected: isSelected,
                  onTap: item.id != null ? () => notifier.toggleItem(item.id!) : null,
                  note: RxCardNote(label: context.l10n.unload_fieldReturnedBy, text: item.returnUser?.fullName ?? '—'),
                );
              },
            ),
      footer: selection == null
          ? null
          : isBoxMode
          ? MedButton(
              label: context.l10n.unload_action_completeBoxUnload,
              isLoading: selection.isSubmitting,
              onPressed: selection.canConfirm ? notifier.confirmBoxUnload : null,
            )
          : MedButton(
              label: context.l10n.unload_action_startDrawerUnload,
              onPressed: selection.canConfirm ? notifier.startDrawerUnload : null,
            ),
    );
  }
}
