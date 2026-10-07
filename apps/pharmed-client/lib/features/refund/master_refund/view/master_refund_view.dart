import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/empty_widgets/no_data_view.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';
import '../../../../widgets/empty_widgets/empty_selection_view.dart';
import '../../../../widgets/hospitalization_panel/hospitalization_panel.dart';
import '../../../../core/hardware/printer/printer.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_refund_execution_notifier.dart';
import '../notifier/master_refund_selection_notifier.dart';

part 'master_refund_selection_view.dart';
part 'master_refund_execution_view.dart';
part 'hospitalization_info_card.dart';
part 'refundable_item_card.dart';

class MasterRefundView extends ConsumerStatefulWidget {
  const MasterRefundView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterRefundView> createState() => _MasterRefundViewState();
}

class _MasterRefundViewState extends ConsumerState<MasterRefundView> {
  MasterRefundExecutionNotifier? _execution;

  @override
  void initState() {
    super.initState();
    // init() notify etmiyor, initState içinde doğrudan çağrılabilir (alımdaki gibi).
    ref.read(masterRefundSelectionNotifierProvider).init(widget.stationContext);

    final execution = ref.read(masterRefundExecutionNotifierProvider);
    _execution = execution;
    execution.onQueueFinished = () {
      // Kuyruk bitişi sensör event'iyle asenkron gelir; widget dispose
      // olduktan sonra da tetiklenebilir.
      if (!mounted) return;
      ref.read(masterRefundSelectionNotifierProvider).refreshAfterExecution();
    };
    // [SWREQ-PRN-094] Fiş arka planda basılır; hata iadeyi etkilemez, yalnızca bildirilir.
    execution.onReceiptFailed = (reason) {
      if (!mounted) return;
      MessageUtils.showErrorSnackbar(context, reason.message(context));
    };
  }

  @override
  void dispose() {
    _execution?.onQueueFinished = null;
    _execution?.onReceiptFailed = null;
    super.dispose();
  }

  Future<void> _startRefund() async {
    final selection = ref.read(masterRefundSelectionNotifierProvider);
    await selection.startRefund(
      onFailed: (msg) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, msg ?? context.l10n.refund_error_genericCheckFailed);
      },
      onSuccess: () async {
        // Karekod kapısı: alımda karekod okutulan her kalem için, HİÇBİR
        // çekmece açılmadan önce.
        if (!await _runQrGate(selection)) return;

        final skipped = await _execution?.start(selection.checkedItems) ?? const [];
        if (skipped.isEmpty || !mounted) return;
        MessageUtils.showErrorSnackbar(context, context.l10n.refund_error_drawerNotResolved(skipped.length));
      },
    );
  }

  /// Gereksinimler için dialog'u sırayla açar. Biri iptal edilirse iade
  /// başlamaz. Tümü gönderildiyse true.
  Future<bool> _runQrGate(MasterRefundSelectionNotifier selection) async {
    final requirements = selection.qrRequirements;
    final patientName = selection.selectedHospitalization?.patient?.fullName;

    for (final (index, requirement) in requirements.indexed) {
      if (!mounted) return false;
      final isLast = index == requirements.length - 1;

      final outcome = await showQrScanDialog(
        context,
        request: QrScanRequest(
          operationLabel: context.l10n.qrScan_operationRefund,
          medicineName: requirement.medicineName,
          requiredCount: requirement.requiredCount,
          expectedGtin: requirement.expectedGtin,
          chips: [
            if (requirements.length > 1)
              QrScanChip(context.l10n.refund_qr_progressChip(index + 1, requirements.length), accent: true),
            if (patientName != null) QrScanChip(patientName),
          ],
          // Son ilaçta onay iadeyi başlatır; öncekilerde sıradaki ilaca geçer.
          confirmLabel: isLast ? context.l10n.refund_qr_confirmButton : null,
        ),
        onSubmit: (codes) => selection.submitRefundQrCodes(requirement, codes),
      );

      if (outcome != QrScanOutcome.submitted) {
        selection.cancelRefundStart();
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(masterRefundSelectionNotifierProvider);
    final isExecuting = ref.watch(masterRefundExecutionNotifierProvider.select((n) => n.isExecuting));

    if (isExecuting) {
      return MasterRefundExecutionView(stationContext: widget.stationContext);
    }

    return MasterRefundSelectionView(
      stationContext: widget.stationContext,
      notifier: selection,
      onStartRefund: _startRefund,
    );
  }
}
