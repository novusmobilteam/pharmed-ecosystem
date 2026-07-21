// [SWREQ-CLI-REFILL-013] [IEC 62304 §5.5]
// Mobil ilaç dolum işlemi tam ekran dialog'u.
//
// Çekmece açıldığında otomatik gösterilir, dolum tamamlanınca veya geri alma
// (rollback) bittiğinde kapanır. State değişiklikleri ref.watch ile yansır.
//
// Mimari notu — phase enum YOK:
//   State + drawerStage zaten "şu an ne yapılıyor" bilgisini eksiksiz taşıyor;
//   ara bir UI enum'u tutmak bu bilgiyi paralel kopyalardı. _StatusBadge ve
//   _Footer state + stage'i KENDİSİ pattern match'liyor → tek doğruluk
//   kaynağı state. Yeni state eklendiğinde sadece bu iki switch güncellenir.
//
// Hata akışları:
//   - MobileRefillError              → kullanıcı "Tekrar Dene" veya "Aç ve Düzelt"
//   - MobileRefillRollbackInProgress → drawer otomatik açılır, ilaçlar geri çıkarılır
//   - MobileRefillRollbackCompleted  → dialog otomatik kapanır (readyContext null)
//   - MobileRefillFatalError         → kurtarılamaz; "Tamam" ile dismiss
//
// Intake dialog'undan farkları (Dolum semantiği):
//   - WaitingForClose phase YOK (drawer kapatıldıktan SONRA complete edilir)
//   - "Doluma Devam Et" butonu — drawer Closed + canComplete false durumunda
//   - UNEXPECTED blokaj banner'ı (kırmızı) — Dolum'a özel (§5.1 matris)
//   - Rollback akışında "Kabinden Çıkarıldı" rozeti (previouslyPlacedEpcs)
//   - Item statüleri: placed / awaiting / removed / nonRfid
//   - Stats sayaçları: Seçili / Yerleştirilen / Plan Dışı
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';
import '../../refill.dart';

part 'items_list.dart';
part 'footer.dart';

class MobileRefillDialog extends ConsumerWidget {
  const MobileRefillDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileRefillNotifierProvider);
    final notifier = ref.read(mobileRefillNotifierProvider.notifier);
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

    final errorMessage = state is MobileRefillError ? state.message : null;
    return CabinOperationDialog(
      type: CabinInventoryType.refill,
      statusInput: OperationStatusInput(
        phase: _refillPhase(state),
        drawerStage: drawerStage,
        baselineCompleted: ready.baselineCompleted,
        canComplete: ready.canComplete,
      ),
      stats: [
        StatCellData(
          label: context.l10n.cabinOperation_label_selected,
          value: context.l10n.refill_label_multiMedicine(ready.selectedItemIds.length),
        ),
        StatCellData(
          label: context.l10n.refill_label_placedCount,
          value: context.l10n.refill_label_placedProgress(ready.rfidReadCount, ready.rfidExpectedCount),
          valueColor: ready.allSelectedRfidRead && ready.baselineCompleted ? MedColors.green : null,
        ),
        StatCellData(
          label: context.l10n.cabinOperation_label_unplanned,
          value: '${ready.unplannedCount}',
          valueColor: ready.unplannedCount > 0 ? MedColors.red : null,
        ),
        StatCellData(
          label: context.l10n.refill_label_extraTag,
          value: '${ready.unexpectedEpcs.length}',
          valueColor: ready.unexpectedEpcs.isNotEmpty ? MedColors.amber : null,
        ),
      ],
      banners: [
        if (errorMessage != null) OperationErrorBanner(message: context.l10n.refill_error_retry),
        // Fazla/yanlış etiket — Dolum'a özel blokaj (kırmızı, blocking)
        if (ready.hasExtraPlacement) UnexpectedTagBanner(epcs: ready.unexpectedEpcs, blocking: true),
        // Plan dışı çıkış — kapanışta eksik stok bildirimi oluşacak
        if (ready.hasUnplannedMovement) UnplannedMovementBanner(epcs: ready.baselineLostEpcs),
      ],
      footerContent: _refillFooter(context, state, drawerStage, ready, notifier),
      child: _ItemsList(),
    );
  }
}

OperationPhase _refillPhase(MobileRefillState s) {
  if (s is MobileRefillFatalError) return OperationPhase.fatal;
  if (s is MobileRefillSaving) return OperationPhase.saving;
  if (s is MobileRefillError) return OperationPhase.error;
  return OperationPhase.normal;
}
