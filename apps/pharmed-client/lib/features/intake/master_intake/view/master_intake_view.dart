// [SWREQ-CLI-MINTAKE-004] [IEC 62304 §5.5]
// İlaç-merkezli master kabin İLAÇ ALIM ekranının root view'ı.
//
// Master dolumdaki MasterRefillView'in alım karşılığıdır. Hasta seçimi artık
// ekran önündeki PatientGateway modalı ile DEĞİL, sol panelde yapılır:
//   - CabinVisualizerData ile MasterIntakeNotifier'ı init eder (hastasız).
//   - Kalıcı iki-panel layout: sol (4) hasta+ilaç seçimi, sağ (6) yürütme.
//   - Sol panel kendi OperationPanelBase'ini taşır (NoPatient → hasta seçimi).
//   - Şahit doğrulama dialog'unu açar (WitnessLoginView).
//   - Kuyruk hatası dialog'unu yönetir (devam / sonlandır).
//   - MasterDrawerOperationWrapper ile sarar (sol alt çekmece banner'ı).
//
// Çekmece görseli YOKTUR — kullanıcı ilaç seçer, çekmeceler otomatik açılır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cabin_operation/master_drawer/master_drawer_operation_wrapper.dart';
import '../../intake.dart';

class MasterIntakeView extends ConsumerStatefulWidget {
  const MasterIntakeView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MasterIntakeView> createState() => _MasterIntakeViewState();
}

class _MasterIntakeViewState extends ConsumerState<MasterIntakeView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MasterIntakeView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterIntakeNotifierProvider.notifier).init(data);
    });
  }

  void _openWitnessDialog(IntakeItem item) {
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    // Zaten uygun bir şahit girilmişse tekrar sorma — direkt ata.
    final existing = notifier.resolveExistingWitness(item.id);
    if (existing != null) {
      notifier.addWitness(item.id, existing);
      MessageUtils.showInfoSnackbar(context, context.l10n.intake_info_witnessAutoAssigned(existing.fullName));
      return;
    }

    showMedDialog<bool>(
      context: context,
      builder: (_) => WitnessLoginView(item: item, onWitnessLoggedIn: (user) => notifier.addWitness(item.id, user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterIntakeNotifierProvider);
    final currentStation = ref.read(masterIntakeNotifierProvider.notifier).currentStation;

    ref.listen(masterIntakeNotifierProvider, (_, next) {
      if (next is MasterIntakeError && next.isQueueError) {
        final notifier = ref.read(masterIntakeNotifierProvider.notifier);
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.intake_error_queueTitle,
          customMessage: next.message.isNotEmpty
              ? '${context.l10n.intake_error_queueMessage}\n\n${next.message}'
              : context.l10n.intake_error_queueMessage,
          iconData: PhosphorIcons.warning(),
          color: MedColors.amber,
          confirmButtonText: context.l10n.refill_error_continueNext,
          cancelButtonText: context.l10n.refill_error_endProcess,
          onConfirm: notifier.continueAfterError,
          onCancel: notifier.abortAfterError,
        );
      } else if (next is MasterIntakeError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        ref.read(masterIntakeNotifierProvider.notifier).dismissError();
      }
    });

    if (widget.data == null || state is MasterIntakeUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return MasterDrawerOperationWrapper(
      child: Padding(
        padding: MedSpacing.insetLg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sol panel kendi OperationPanelBase'ini (kutu + header) taşır.
            Expanded(
              flex: 4,
              child: MasterIntakeSelectionPanel(currentStation: currentStation, onWitnessTap: _openWitnessDialog),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 8,
              child: Container(
                padding: MedSpacing.insetXl,
                decoration: BoxDecoration(
                  boxShadow: MedShadows.sm,
                  color: MedColors.surface,
                  borderRadius: MedRadius.lgAll,
                ),
                child: const MasterIntakeExecutionPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
