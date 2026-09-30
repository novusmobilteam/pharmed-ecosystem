import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../auth/auth.dart';
import '../../service_selection/service_selection.dart';
import '../notifier/stock_movement_notifier.dart';
import '../widgets/stock_movement_card.dart';
import '../widgets/stock_movement_ranked_bars.dart';
import '../widgets/stock_movement_timeline_chart.dart';
import '../widgets/stock_movement_toolbar.dart';
import '../widgets/stock_movement_type_donut.dart';

/// Stok Hareket — istasyondaki tüm stok hareketlerinin grafiksel sunumu.
///
/// Veri: manager "İstasyon Hareketleri" ile aynı kaynak (StationTransaction).
/// SWREQ-XXX (atanacak)
class StockMovementScreen extends ConsumerStatefulWidget {
  const StockMovementScreen({super.key});

  @override
  ConsumerState<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stationId = _resolveStationId();
      if (stationId != null) {
        ref.read(stockMovementNotifierProvider).initialize(stationId: stationId);
      }
    });
  }

  int? _resolveStationId() => ref.read(activeServiceNotifierProvider).station?.id;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(stockMovementNotifierProvider);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ref.read(authNotifierProvider.notifier).onUserActivity(),
      child: ColoredBox(
        color: MedColors.bg,
        child: Padding(
          padding: MedSpacing.insetXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StockMovementToolbar(notifier: notifier),
              if (notifier.isTruncated) ...[
                const SizedBox(height: MedSpacing.md),
                _TruncatedBanner(count: notifier.summary.totalCount),
              ],
              const SizedBox(height: MedSpacing.lg),
              Expanded(child: _Body(notifier: notifier)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.notifier});

  final StockMovementNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = notifier.summary;

    // İlk yüklemede veri yoksa tam ekran durumlar; yeniden yüklemede
    // eski grafikler üstteki ince progress ile yerinde kalır.
    if (summary.isEmpty) {
      if (notifier.isFetching) return const Center(child: MedLoadingIndicator());
      if (notifier.isFetchFailed) {
        return _StateMessage(
          icon: PhosphorIcons.warningCircle(),
          title: notifier.statusMessage ?? l10n.movement_loadErrorMessage,
          action: FilledButton(onPressed: notifier.refresh, child: Text(l10n.common_retryButton)),
        );
      }
      return _StateMessage(
        icon: PhosphorIcons.chartLineUp(),
        title: l10n.movement_emptyTitle,
        description: l10n.movement_emptyDescription,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SizedBox(height: 88, child: StockMovementKpiStrip(summary: summary)),
        // const SizedBox(height: MedSpacing.lg),
        Expanded(
          flex: 6,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: StockMovementCard(
                  title: l10n.movement_chart_timelineTitle,
                  child: StockMovementTimelineChart(summary: summary),
                ),
              ),
              const SizedBox(width: MedSpacing.lg),
              Expanded(
                child: StockMovementCard(
                  title: l10n.movement_chart_typeDistributionTitle,
                  dotColor: MedColors.green,
                  child: StockMovementTypeDonut(summary: summary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: MedSpacing.lg),
        Expanded(
          flex: 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: StockMovementCard(
                  title: l10n.movement_chart_topMaterialsTitle,
                  dotColor: MedColors.amber,
                  child: StockMovementRankedBars(
                    color: MedColors.amber,
                    rows: [
                      for (final m in summary.topMaterials)
                        RankedBarRow(
                          label: m.material,
                          subLabel: m.code,
                          value: m.count,
                          trailing: l10n.movement_chart_movementCount(m.count),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: MedSpacing.lg),
              Expanded(
                child: StockMovementCard(
                  title: l10n.movement_chart_cabinDistributionTitle,
                  child: StockMovementRankedBars(
                    rows: [
                      for (final c in notifier.availableCabins)
                        RankedBarRow(
                          label: c.cabinName,
                          // Tip filtresi uygulanmış sayım; kabin listesi sabit kalır.
                          value: summary.byCabin.where((b) => b.cabinId == c.cabinId).firstOrNull?.count ?? 0,
                          selected: notifier.selectedCabinIds.isEmpty
                              ? null
                              : notifier.selectedCabinIds.contains(c.cabinId),
                          onTap: () => notifier.toggleCabin(c.cabinId),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TruncatedBanner extends StatelessWidget {
  const _TruncatedBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.md),
      decoration: BoxDecoration(
        color: MedColors.amber.withValues(alpha: 0.1),
        border: Border.all(color: MedColors.amber.withValues(alpha: 0.4)),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.warning(), color: MedColors.amber, size: 18),
          const SizedBox(width: MedSpacing.md),
          Expanded(child: Text(context.l10n.movement_truncatedWarning(count), style: MedTextStyles.bodySm())),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.title, this.description, this.action});

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: MedColors.border),
          const SizedBox(height: MedSpacing.lg),
          Text(title, style: MedTextStyles.titleMd(), textAlign: TextAlign.center),
          if (description != null) ...[
            const SizedBox(height: MedSpacing.sm),
            Text(description!, style: MedTextStyles.bodyMd(), textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: MedSpacing.xl), action!],
        ],
      ),
    );
  }
}
