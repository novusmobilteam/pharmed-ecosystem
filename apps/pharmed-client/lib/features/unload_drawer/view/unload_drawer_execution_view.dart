// features/unload_drawer/view/unload_drawer_execution_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../widgets/widgets.dart';
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
    // Assignment üzerinden tek fiziksel çekmece açık — kartlar burada
    // birer "hedef" değil, sadece o çekmecede biriken iadelerin dökümü.
    // Refund'un CabinExecutionGridCard'ı assignment bazlı tek target
    // gösterdiği için burada uygun değil; ReturnDrawerMedicine listesini
    // düz bir grid'de bilgi amaçlı listeliyoruz.
    return CabinExecutionGrid(
      maxWidth: 640,
      isLocked: executing.isSaving,
      isKubik: false,
      itemCount: executing.items.length,
      itemBuilder: (context, i) => _medicineInfoCard(context, executing.items[i]),
      header: null,
      canConfirm: executing.items.isNotEmpty,
      isSaving: executing.isSaving,
      confirmLabel: context.l10n.unload_action_completeDrawerUnload,
      onConfirm: notifier.confirmDrawerUnload,
    );
  }

  Widget _medicineInfoCard(BuildContext context, ReturnDrawerMedicine item) {
    final unit = item.material?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

    return MedValueCard(
      label: item.material?.name ?? '—',
      value: (item.quantity ?? 0).formatFractional,
      suffix: unit,
      onTap: () {},
    );
  }
}
