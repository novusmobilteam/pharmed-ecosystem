import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../census.dart';

part 'banners.dart';
part 'footer.dart';
part 'extra_stock_summary_card.dart';

class MobileCensusDialog extends ConsumerWidget {
  const MobileCensusDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileCensusNotifierProvider);
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
    if (ready == null) return const SizedBox.shrink();

    final errorMessage = state is MobileCensusError ? (state).message : null;

    return MedDialog(
      title: 'İlaç Sayım',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Banner'lar ──────────────────────────────────────────────
          if (errorMessage != null) ...[
            _CensusBanner(
              tone: _BannerTone.error,
              icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
              message: errorMessage,
            ),
            const SizedBox(height: MedSpacing.sm),
          ],
          if (ready.excessEpcs.isNotEmpty) ...[
            _CensusBanner(
              tone: _BannerTone.warning,
              icon: PhosphorIcons.package(PhosphorIconsStyle.bold),
              message:
                  'Kabinde ${ready.excessEpcs.length} beklenmeyen etiketli ilaç okundu. '
                  'Lütfen alın veya fazla stok olarak bildirin.',
            ),
            const SizedBox(height: MedSpacing.sm),
          ],
          if (ready.missingEpcs.isNotEmpty) ...[
            _CensusBanner(
              tone: _BannerTone.info,
              icon: PhosphorIcons.minusCircle(PhosphorIconsStyle.bold),
              message:
                  '${ready.missingEpcs.length} ilaç kabinde bulunamadı. '
                  'Tamamlandığında eksik stok olarak bildirilecek.',
            ),
            const SizedBox(height: MedSpacing.sm),
          ],

          // ── Fazla stok bildir butonu ────────────────────────────────
          if (ready.extraStocks.isNotEmpty) ...[
            const SizedBox(height: MedSpacing.sm),
            _ExtraStockSummaryCard(
              extraStocks: ready.extraStocks,
              onRemove: ref.read(mobileCensusNotifierProvider.notifier).removeExtraStock,
            ),
          ],
          const SizedBox(height: MedSpacing.md),

          // ── Grup listesi ────────────────────────────────────────────
          Flexible(
            child: ready.groups.isEmpty
                ? const EmptyStateWidget(variant: EmptyStateVariant.noPrescription)
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 4),
                    itemCount: ready.groups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                    itemBuilder: (context, i) {
                      final group = ready.groups[i];
                      return RxCensusGroupCard(
                        group: group,
                        onToggleMissing: ref.read(mobileCensusNotifierProvider.notifier).toggleMissingMark,
                      );
                    },
                  ),
          ),

          const SizedBox(height: MedSpacing.md),

          _ReportExtraStockButton(onReport: ref.read(mobileCensusNotifierProvider.notifier).addExtraStock),
          const SizedBox(height: MedSpacing.xl),

          _CensusDialogFooter(state: state, drawerStage: drawerStage, ready: ready),
        ],
      ),
    );
  }
}

class _ReportExtraStockButton extends StatelessWidget {
  const _ReportExtraStockButton({required this.onReport});

  final void Function({required Medicine medicine, required double quantity}) onReport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MedButton(
        label: context.l10n.census_action_report_extra_stock,
        size: MedButtonSize.md,
        variant: MedButtonVariant.danger,

        onPressed: () async {
          final result = await ReportExtraStockDialog.show(context);
          if (result != null) {
            onReport(medicine: result.medicine, quantity: result.quantity);
          }
        },
      ),
    );
  }
}
