import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_refund_notifier.dart';
import '../notifier/master_refund_state.dart';
import 'master_refund_execution_view.dart';
import 'master_refund_selection_view.dart';

class MasterRefundView extends ConsumerStatefulWidget {
  const MasterRefundView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterRefundView> createState() => _MasterRefundViewState();
}

class _MasterRefundViewState extends ConsumerState<MasterRefundView> {
  // Hasta seçimi değiştiğinde tekrar terkar loading göstermemek için kullanılan flag.
  bool _hasBooted = false;

  bool _isPatientReady(PatientSelectionState s) => switch (s) {
    PatientSelectionReady() => true,
    PatientSelectionError() => true,
    _ => false,
  };

  @override
  void initState() {
    super.initState();

    final notifier = ref.read(masterRefundNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.stationContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterRefundNotifierProvider);
    final patientState = ref.watch(patientSelectionNotifierProvider);
    final notifier = ref.read(masterRefundNotifierProvider.notifier);
    final isExecuting =
        state is MasterRefundExecuting ||
        (state is MasterRefundError && (state).previousState is MasterRefundExecuting);

    ref.listen(masterRefundNotifierProvider, (_, next) {
      if (next is MasterRefundError && next.isQueueError) {
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.intake_error_queueTitle,
          customMessage: next.failure.message(context).isNotEmpty
              ? next.failure.message(context)
              : context.l10n.intake_error_queueMessage,
          iconData: PhosphorIcons.warning(),
          color: MedColors.amber,
          confirmButtonText: context.l10n.refill_error_continueNext,
          cancelButtonText: context.l10n.refill_error_endProcess,
          onConfirm: notifier.continueAfterError,
          onCancel: notifier.abortAfterError,
        );
      } else if (next is MasterRefundError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      }
    });

    final selectionView = MasterRefundSelectionView(stationContext: widget.stationContext);

    if (!_hasBooted) {
      if (!_isPatientReady(patientState)) {
        // selectionView'ı (ve içindeki patient-selection init tetikleyicisini)
        // Offstage ile MOUNT EDİLMİŞ tutuyoruz — aksi halde
        // PatientSelectionNotifier'ın initState'teki init() çağrısı hiç
        // tetiklenmez ve _isPatientReady sonsuza kadar false kalır.
        return Stack(
          children: [
            Offstage(offstage: true, child: selectionView),
            const Center(child: MedLoadingIndicator()),
          ],
        );
      }
      _hasBooted = true;
    }

    _hasBooted = true;

    if (isExecuting) {
      return MasterRefundExecutionView(cabinDataByCabinId: widget.stationContext.cabinDataByCabinId);
    }

    return selectionView;
  }
}
