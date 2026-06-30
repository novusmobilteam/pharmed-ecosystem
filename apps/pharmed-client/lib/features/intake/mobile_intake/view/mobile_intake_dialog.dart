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
import '../../intake.dart';

part 'badges.dart';
part 'items_list.dart';
part 'banners.dart';
part 'footer.dart';

// EPC formatı: "E280116060000204..." → "E280 1160 6000 0204 ..."
String _formatEpc(String epc) {
  final clean = epc.replaceAll(' ', '');
  final chunks = <String>[];
  for (var i = 0; i < clean.length; i += 4) {
    chunks.add(clean.substring(i, (i + 4).clamp(0, clean.length)));
  }
  return chunks.join(' ');
}

class MobileIntakeDialog extends ConsumerWidget {
  const MobileIntakeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;
    final keep = state.shouldKeepDialog(drawerStage);
    MedLogger.info(
      unit: 'MobileIntakeDialog',
      swreq: 'SWREQ-CLI-INTAKE-003',
      message: 'shouldKeepDialog',
      context: {
        'keep': keep,
        'state': state.runtimeType.toString(),
        'stage': drawerStage.runtimeType.toString(),
        'canPop': Navigator.of(context).canPop(),
      },
    );
    if (!keep) {
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
            if (ready.hasUnplannedMovement) _UnplannedBanner(epcs: ready.unplannedMovements),
            if (state is MobileIntakeRollbackInProgress)
              const _ErrorBanner(
                message:
                    'Alım işlemi tamamlanamadı. Aldığınız ilaçları çekmeceden çıkartın ve çekmeceyi kapatarak işlemi sonlandırın.',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [Text('İlaç alım işlemi', style: MedTextStyles.titleSm(color: MedColors.text))],
            ),
          ),
          _StatusBadge(),
        ],
      ),
    );
  }
}
