// [SWREQ-CLI-MREFILL-004] [IEC 62304 §5.5]
// İlaç-merkezli master kabin dolum ekranının root view'ı.
//
// Sorumluluk:
//   - CabinVisualizerData ile MasterRefillNotifier'ı initialize eder
//   - Kalıcı iki-panel layout: sol (4) seçim, sağ (6) yürütme/boş state
//   - Kuyruk hatası dialog'unu yönetir
//   - MasterDrawerOperationWrapper ile sarar (sol alt köşe çekmece banner'ı)
//
// Selection ve Execution panelleri artık yan yana gösterilir; yürütme
// başlayınca sol panel kendi içinde kilitlenir. İşlem bitince notifier
// seçimleri temizleyip Selection'a döner (ayrı "başarılı" ekranı yok).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cabin_operation/master_drawer/master_drawer_operation_wrapper.dart';
import '../notifier/master_refill_notifier.dart';
import '../notifier/master_refill_state.dart';
import 'master_refill_selection_panel.dart';
import 'master_refill_execution_panel.dart';

class MasterRefillView extends ConsumerStatefulWidget {
  const MasterRefillView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MasterRefillView> createState() => _MasterRefillViewState();
}

class _MasterRefillViewState extends ConsumerState<MasterRefillView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MasterRefillView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterRefillNotifierProvider.notifier).init(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterRefillNotifierProvider);

    ref.listen(masterRefillNotifierProvider, (_, next) {
      if (next is MasterRefillError && next.isQueueError) {
        // Dolum/çekmece hatası: çekmece kapandı ama kayıt başarısız.
        // Kullanıcı ilaçları geri almalı, sonra devam veya sonlandır.
        final notifier = ref.read(masterRefillNotifierProvider.notifier);
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.refill_error_queueTitle,
          customMessage: next.message.isNotEmpty
              ? '${context.l10n.refill_error_queueMessage}\n\n${next.message}'
              : context.l10n.refill_error_queueMessage,
          iconData: PhosphorIcons.warning(),
          color: MedColors.amber,
          confirmButtonText: context.l10n.refill_error_continueNext,
          cancelButtonText: context.l10n.refill_error_endProcess,
          onConfirm: notifier.continueAfterError,
          onCancel: notifier.abortAfterError,
        );
      } else if (next is MasterRefillError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        ref.read(masterRefillNotifierProvider.notifier).dismissError();
      }
    });

    if (widget.data == null || state is MasterRefillUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is MasterRefillLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return MasterDrawerOperationWrapper(
      child: Padding(
        padding: MedSpacing.insetLg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                padding: MedSpacing.insetXl,
                decoration: BoxDecoration(
                  boxShadow: MedShadows.sm,
                  color: MedColors.surface,
                  borderRadius: MedRadius.lgAll,
                ),
                child: MasterRefillSelectionPanel(),
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              flex: 6,
              child: Container(
                padding: MedSpacing.insetXl,
                decoration: BoxDecoration(
                  boxShadow: MedShadows.sm,
                  color: MedColors.surface,
                  borderRadius: MedRadius.lgAll,
                ),
                child: MasterRefillExecutionPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
