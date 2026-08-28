import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../widgets/widgets.dart';
import '../../../widgets/rx_operation_card/rx_operation_card_2.dart';
import '../notifier/unload_drawer_notifier.dart';
import '../notifier/unload_drawer_state.dart';

class UnloadDrawerExecutionView extends ConsumerWidget {
  const UnloadDrawerExecutionView({super.key, required this.allGroups});
  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(unloadDrawerNotifierProvider);
    final notifier = ref.read(unloadDrawerNotifierProvider.notifier);

    final executing = switch (state) {
      UnloadDrawerExecuting s => s,
      UnloadDrawerError(previousState: UnloadDrawerExecuting s) => s,
      _ => null,
    };

    if (executing == null) return const SizedBox.shrink();

    return CabinOperationExecutionLayout(
      // Queue yok — progress her zaman tek adımlık, ilerleme yüzdesi anlamsız.
      progressLabel: context.l10n.unload_label_drawerInProgress,
      progress: executing.status == CabinOperationJobStatus.completed ? 1 : 0,
      onStopConfirmed: notifier.abortAfterError,
      stopLabel: context.l10n.unload_action_stop,
      stopConfirmTitle: context.l10n.unload_action_stopConfirmTitle,
      stopConfirmMessage: context.l10n.unload_action_stopConfirmMessage,
      stopConfirmYesLabel: context.l10n.unload_action_stopConfirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: executing.toLocationItems(allGroups),
      activeIndex: 0,

      openedBuilder: (_) => _DrawerUnloadConfirmForm(executing: executing, notifier: notifier),
    );
  }
}

class _DrawerUnloadConfirmForm extends StatelessWidget {
  const _DrawerUnloadConfirmForm({required this.executing, required this.notifier});

  final UnloadDrawerExecuting executing;
  final UnloadDrawerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    // Artık salt-bilgi değil — kullanıcı fiziksel çekmecede GÖRDÜĞÜ ilacı
    // burada işaretler. Sadece işaretlenenler confirmDrawerUnload'a gider.
    return CabinExecutionGrid(
      maxWidth: 820,
      isLocked: executing.isSaving,
      isKubik: false,
      itemCount: executing.items.length,
      itemBuilder: (context, i) => _medicineSelectCard(context, executing.items[i], executing),
      header: null,
      canConfirm: executing.canConfirm,
      isSaving: executing.isSaving,
      confirmLabel: context.l10n.unload_action_completeDrawerUnload,
      onConfirm: notifier.confirmDrawerUnload,
    );
  }

  Widget _medicineSelectCard(BuildContext context, ReturnDrawerMedicine item, UnloadDrawerExecuting executing) {
    final unit = item.material?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;
    final isSelected = item.id != null && executing.selectedIds.contains(item.id);
    final time = item.returnDate;
    final drug = item.prescriptionItem?.medicine?.when(drug: (Drug d) => d, consumable: (_) => null);

    final returnNote = drug?.returnNote?.trim();

    return RxOperationCard2(
      title: item.material?.name ?? '—',
      subtitle: '${(item.quantity ?? 0).formatFractional} $unit',
      barcode: item.material?.barcode,
      statusChip: time != null ? RxCardChip(label: time.shortRelativeLabelOf(context), tone: MedTone.info) : null,
      isSelected: isSelected,

      note: (returnNote != null && returnNote.isNotEmpty)
          ? RxCardNote(label: context.l10n.medicine_fieldReturnNote, text: returnNote)
          : null,

      movements: [
        if (item.returnUser case final m?)
          RxCardMovement(
            label: PrescriptionMovementType.returned.actorLabel(context),
            tone: PrescriptionMovementType.returned.movementTone,
            performedBy: item.returnUser?.fullName ?? '',
            quantity: '${(item.quantity ?? 0).formatFractional} $unit',
            date: item.returnDate?.shortRelativeLabelOf(context) ?? '—',
          ),
      ],

      onTap: (item.id != null && !executing.isSaving) ? () => notifier.toggleExecutingItem(item.id!) : null,
    );
  }
}
