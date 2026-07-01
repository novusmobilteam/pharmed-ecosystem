// [SWREQ-CLI-INTAKE-010] [IEC 62304 §5.5]
// Mobil ilaç alım işlemi tam ekran dialog'u.
//
// Çekmece açıldığında otomatik gösterilir, alım tamamlanınca kapanır.
// State değişiklikleri ref.watch ile yansır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../widgets/cabin_operation_dialog/cabin_operation_dialog.dart';
import '../../intake.dart';

part 'items_list.dart';

class MobileIntakeDialog extends ConsumerWidget {
  const MobileIntakeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final notifier = ref.read(mobileIntakeNotifierProvider.notifier);
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

    if (ready == null) {
      return const SizedBox.shrink();
    }

    final errorMessage = state is MobileIntakeError ? state.message : null;

    return CabinOperationDialog(
      type: CabinInventoryType.intake,
      statusInput: OperationStatusInput(
        phase: _intakePhase(state),
        drawerStage: drawerStage,
        baselineCompleted: ready.baselineCompleted,
        canComplete: ready.canComplete,
        rollbackSettling: state is MobileIntakeRollbackInProgress && ready.rfidReadEpcs.isEmpty,
      ),
      stats: [
        StatCellData(label: 'Seçili', value: '${ready.selectedItemIds.length} ilaç'),
        StatCellData(label: 'Kabinde Okunan', value: '${ready.totalReadCount} etiket'),
        StatCellData(
          label: 'Plan Dışı',
          value: '${ready.unplannedCount}',
          valueColor: ready.unplannedCount > 0 ? MedColors.red : null,
          icon: ready.unplannedCount > 0 ? PhosphorIcons.warning(PhosphorIconsStyle.bold) : null,
        ),
      ],
      banners: [
        if (errorMessage != null)
          const OperationErrorBanner(
            message: 'Tekrar deneyebilir ya da yerleştirdiğiniz ilaçları alarak işleminizi sonlandırabilirsiniz.',
          ),
        if (ready.hasUnplannedMovement) UnplannedMovementBanner(epcs: ready.unplannedMovements),
        if (ready.hasUnexpectedTag) UnexpectedTagBanner(epcs: ready.unexpectedEpcs),
        if (state is MobileIntakeRollbackInProgress)
          const RollbackBanner(
            message:
                'Alım işlemi tamamlanamadı. Aldığınız ilaçları çekmeceye koyun '
                've çekmeceyi kapatarak işlemi sonlandırın.',
          ),
      ],
      footerContent: _intakeFooter(state, drawerStage, ready, notifier),
      child: _ItemsList(),
    );
  }
}

OperationPhase _intakePhase(MobileIntakeState s) {
  if (s is MobileIntakeFatalError) return OperationPhase.fatal;
  if (s is MobileIntakeSaving) return OperationPhase.saving;
  if (s is MobileIntakeError) return OperationPhase.error;
  if (s is MobileIntakeRollbackInProgress) return OperationPhase.rollback;
  return OperationPhase.normal;
}

FooterContent _intakeFooter(
  MobileIntakeState state,
  MobileDrawerStage stage,
  MobileIntakeReady ready,
  MobileIntakeNotifier notifier,
) {
  // ── Hint ──
  final hint = switch (state) {
    MobileIntakeFatalError(:final message) => 'Kritik bir hata oluştu: $message',
    MobileIntakeSaving() => 'Kaydediliyor...',
    MobileIntakeError() => 'Hata oluştu — tekrar deneyebilirsiniz',
    MobileIntakeRollbackInProgress() => switch (stage) {
      MobileDrawerOpening() => 'Çekmece açılıyor, lütfen bekleyin...',
      MobileDrawerOpened() => 'Çıkardığınız ilaçları kabine geri koyun, ardından çekmeceyi kapatın.',
      MobileDrawerClosed() =>
        ready.isRollbackComplete
            ? 'İlaçları geri koydunuz. İşlem sonlandırılıyor...'
            : 'Bazı ilaçlar hâlâ eksik. Çekmeceyi açıp kalan ilaçları geri koyun.',
      _ => 'İşlem geri alınıyor...',
    },
    _ => switch (stage) {
      MobileDrawerOpening() => 'Çekmece açılıyor...',
      MobileDrawerOpened() =>
        ready.baselineCompleted
            ? 'Almak istediğiniz ilaçları çekmeceden çıkartın, ardından çekmeceyi kapatın'
            : 'Kabin taranıyor, lütfen bekleyin',
      MobileDrawerClosed() =>
        ready.canComplete
            ? 'İşlemi bitirmek için tamamla butonuna basın'
            : 'Henüz ilaç alınmadı. Çekmeceyi açıp ilaçları çıkartın.',
      _ => 'İlaçları çekmeceden çıkartın, ardından çekmeceyi kapatın',
    },
  };

  // ── Actions ──
  final actions = switch (state) {
    MobileIntakeFatalError() => [FooterActions.dismiss(notifier.dismissError)],
    MobileIntakeError() => [FooterActions.retry(notifier.retryComplete)],
    MobileIntakeSaving() => [FooterActions.saving()],
    MobileIntakeRollbackInProgress() => const <Widget>[],
    _ when stage is MobileDrawerClosed && ready.canComplete => [
      FooterActions.primary('İşlemi tamamla', notifier.completeIntake),
    ],
    _ when stage is MobileDrawerClosed => [FooterActions.primary('Almaya Devam Et', notifier.reopenDrawer)],
    _ => [FooterActions.primary('İşlemi tamamla', null)],
  };

  return FooterContent(hint: hint, actions: actions);
}
