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

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../refill.dart';

part 'badges.dart';
part 'items_list.dart';
part 'banners.dart';
part 'footer.dart';

String _formatEpc(String epc) {
  final clean = epc.replaceAll(' ', '');
  final chunks = <String>[];
  for (var i = 0; i < clean.length; i += 4) {
    chunks.add(clean.substring(i, (i + 4).clamp(0, clean.length)));
  }
  return chunks.join(' ');
}

class MobileRefillDialog extends ConsumerWidget {
  const MobileRefillDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileRefillNotifierProvider);
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

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: MedRadius.xl2All),
      backgroundColor: MedColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(),
            _StatsRow(),
            Flexible(child: _ItemsList()),
            if (errorMessage != null)
              _ErrorBanner(
                message: 'Tekrar deneyebilir ya da yerleştirdiğiniz ilaçları alarak işleminizi sonlandırabilirsiniz.',
              ),
            // UNEXPECTED blokaj — Dolum'a özel, kırmızı banner
            if (ready.isBlockedByUnexpected) _UnexpectedBanner(epcs: ready.unexpectedEpcs),
            // EXTRA PLACEMENT — kullanıcı seçili olmayan ilacın etiketini koydu
            if (ready.hasExtraPlacement) _ExtraPlacementBanner(epcs: ready.extraPlacedEpcs),
            // UNPLANNED hareket — Intake ile ortak, amber banner
            if (ready.hasUnplannedMovement) _UnplannedBanner(epcs: ready.unplannedMovements),
            if (state is MobileRefillRollbackInProgress)
              const _ErrorBanner(
                message:
                    'Dolum işlemi tamamlanamadı. Yerleştirdiğiniz ilaçları çekmeceden çıkartın ve çekmeceyi kapatarak işlemi sonlandırın.',
              ),

            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetXl,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('İlaç dolum işlemi', style: MedTextStyles.titleSm(color: MedColors.text)),
          ),
          const _StatusBadge(),
        ],
      ),
    );
  }
}
