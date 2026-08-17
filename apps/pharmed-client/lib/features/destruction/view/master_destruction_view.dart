// master_destruction_view.dart
// Notifier artık ekranın kendi ChangeNotifierProvider'ında yaratılıyor.
// CabinVisualizerData, üstteki DestructionView tarafından context.watch
// ile canlı izlenip aktarılıyor (CensusView ile aynı desen).

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator_2.dart';
import '../../../core/hardware/hardware.dart';
import '../../../widgets/widgets.dart';
import '../../auth/notifier/auth_notifier.dart';
import '../notifier/destruction_notifier.dart';
import 'destruction_execution_view.dart';
import 'destruction_selection_view.dart';

class MasterDestructionView extends StatelessWidget {
  const MasterDestructionView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DestructionNotifier>(
      create: (ctx) => DestructionNotifier(
        orchestrator: MasterDrawerOrchestrator(
          startSession: ctx.read(),
          openCubicLid: ctx.read(),
          monitorClosure: ctx.read(),
        ),
        getAssignments: ctx.read(),
        completeDispose: ctx.read(),
        authNotifier: ctx.read<AuthNotifier>(),
      ),
      child: _MasterDestructionContent(data: data),
    );
  }
}

class _MasterDestructionContent extends StatefulWidget {
  const _MasterDestructionContent({this.data});

  final CabinVisualizerData? data;

  @override
  State<_MasterDestructionContent> createState() => _MasterDestructionContentState();
}

class _MasterDestructionContentState extends State<_MasterDestructionContent> {
  bool _wasQueueError = false;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DestructionNotifier>();

    // ref.listen'ın eşdeğeri — errorFailure/isQueueError geçişini izleyip
    // post-frame'de dialog/snackbar tetikliyoruz.
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleErrorTransition(notifier));

    return MasterCabinRootScaffold<CabinVisualizerData, DestructionNotifier>(
      data: widget.data,
      cabinIdOf: (d) => d.cabinId,
      onInit: (d) => notifier.init(d),
      state: notifier,
      phaseOf: (n) {
        if (!n.isFetchingAssignments && n.medicines.isEmpty && !n.isExecuting && n.errorFailure == null) {
          return const RootBooting();
        }
        if (n.isFetchingAssignments && n.medicines.isEmpty) return const RootBooting();
        if (n.isExecuting) return const RootExecuting();
        return const RootSelection();
      },
      selectionBuilder: (_) => DestructionSelectionView(allGroups: widget.data?.groups ?? const []),
      executionBuilder: (_) => DestructionExecutionView(allGroups: widget.data?.groups ?? const []),
    );
  }

  void _handleErrorTransition(DestructionNotifier notifier) {
    if (!mounted) return;
    final failure = notifier.errorFailure;
    if (failure == null) {
      _wasQueueError = false;
      return;
    }

    // Aynı hata için dialog/snackbar'ı tekrar tekrar açmamak için —
    // sadece "yeni" bir hata (henüz işlenmemiş) geldiğinde tetikle.
    if (_wasQueueError) return;
    _wasQueueError = true;

    if (notifier.isQueueError) {
      MessageUtils.showConfirmDialog(
        context: context,
        action: ConfirmAction.custom,
        customTitle: context.l10n.census_error_queueTitle,
        customMessage: failure.message(context).isNotEmpty
            ? failure.message(context)
            : context.l10n.census_error_queueMessage,
        iconData: PhosphorIcons.warning(),
        color: MedColors.amber,
        confirmButtonText: context.l10n.census_error_continueNext,
        cancelButtonText: context.l10n.census_error_endProcess,
        onConfirm: () {
          _wasQueueError = false;
          notifier.continueAfterError();
        },
        onCancel: () {
          _wasQueueError = false;
          notifier.abortAfterError();
        },
      );
    } else {
      MessageUtils.showErrorSnackbar(context, failure.message(context));
      notifier.dismissError();
      _wasQueueError = false;
    }
  }
}
