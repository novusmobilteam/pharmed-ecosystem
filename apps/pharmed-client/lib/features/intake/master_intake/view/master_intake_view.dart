// [SWREQ-CLI-MINTAKE-004] [IEC 62304 §5.5]
// İlaç-merkezli master kabin İLAÇ ALIM ekranının root view'ı.
//
// İki bağımsız provider senkron boot olmalı: masterIntakeNotifierProvider
// (bu ekranın kendi state'i) + patientSelectionNotifierProvider (ortak hasta
// seçim çatısı, PatientSelectionPanel içinde kullanılıyor). Bu yüzden
// extraBootGate ile ikincisinin de hazır olması bekleniyor — bkz.
// MasterCabinRootScaffold.
//
// Executing fazında (ve ondan doğan hatada) patient list dahil hiçbir şey
// ekranda kalmaz — replacesEverything: true.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/hardware.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../intake.dart';

class MasterIntakeView extends ConsumerStatefulWidget {
  const MasterIntakeView({super.key, this.data, required this.menu});

  final CabinVisualizerData? data;
  final MenuItem menu;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MasterIntakeViewState();
}

class _MasterIntakeViewState extends ConsumerState<MasterIntakeView> {
  bool _isPatientReady(PatientSelectionState s) => switch (s) {
    PatientSelectionReady() => true,
    PatientSelectionError(previousState: PatientSelectionReady()) => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterIntakeNotifierProvider);
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    ref.listen(masterIntakeNotifierProvider, (_, next) {
      if (next is MasterIntakeError && next.isQueueError) {
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
      } else if (next is MasterIntakeError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      }
    });

    return MasterCabinRootScaffold<CabinVisualizerData, MasterIntakeState>(
      data: widget.data,
      cabinIdOf: (d) => d.cabinId,
      onInit: (d) => notifier.init(d),
      state: state,
      extraBootGate: () => !_isPatientReady(ref.watch(patientSelectionNotifierProvider)),
      phaseOf: (s) => switch (s) {
        MasterIntakeUninitialized() || MasterIntakeLoading() => const RootBooting(),
        MasterIntakeExecuting() => const RootExecuting(replacesEverything: true),
        MasterIntakeError(previousState: MasterIntakeExecuting()) => const RootExecuting(replacesEverything: true),
        _ => const RootSelection(),
      },
      selectionBuilder: (_) => const MasterIntakeSelectionView(),
      executionBuilder: (_) => MasterIntakeExecutionView(allGroups: widget.data?.groups ?? const []),
    );
  }
}
