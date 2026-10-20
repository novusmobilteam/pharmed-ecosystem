part of 'station_empty_compartments_report_screen.dart';

/// Seçilen çekmecenin boş gözlerini (konum, göz sayısı, kademe sayısı) listeler.
class StationEmptyCompartmentDetailDialog extends StatelessWidget {
  const StationEmptyCompartmentDetailDialog({super.key, required this.item});

  final StationEmptyCompartment item;

  static Future<void> show(BuildContext context, {required StationEmptyCompartment item}) async {
    final notifier = context.read<StationEmptyCompartmentsReportNotifier>();
    notifier.openDetail(item);
    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => ChangeNotifierProvider.value(
        value: notifier,
        child: StationEmptyCompartmentDetailDialog(item: item),
      ),
    );
    notifier.closeDetail();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final l10n = context.l10n;
    final drawerLabel = context.read<StationEmptyCompartmentsReportNotifier>().drawerLabel(item);
    String v(Object? value) => (value == null || value.toString().isEmpty) ? '-' : value.toString();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: MedRadius.xl2All),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640, maxHeight: size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              title: l10n.report_stationEmptyCompartment_detailDialogTitle,
              subtitle: [item.stationName, item.cabinName, drawerLabel].whereType<String>().join(' · '),
            ),
            const Divider(height: 1, color: MedColors.border2),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: l10n.tableCore_stationEmptyCompartmentEmptyColumn,
                      value: v(item.emptyCount),
                    ),
                  ),
                  const SizedBox(width: MedSpacing.lg),
                  Expanded(
                    child: _InfoTile(
                      label: l10n.tableCore_stationEmptyCompartmentOccupiedColumn,
                      value: v(item.occupiedCount),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Consumer<StationEmptyCompartmentsReportNotifier>(
                  builder: (context, notifier, _) => _DetailsSection(
                    loading: notifier.isFetchingDetails,
                    failed: notifier.isDetailsFailed,
                    details: notifier.details,
                    onRetry: notifier.retryDetails,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.loading, required this.failed, required this.details, required this.onRetry});

  final bool loading;
  final bool failed;
  final List<StationEmptyCompartmentDetail> details;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.report_stationEmptyCompartment_detailsSectionTitle, style: MedTextStyles.titleSm()),
        const SizedBox(height: MedSpacing.md),
        if (loading)
          const SizedBox(height: 64, child: Center(child: CircularProgressIndicator.adaptive()))
        else if (failed)
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.report_stationEmptyCompartment_detailsLoadError,
                  style: MedTextStyles.bodyMd(color: MedColors.red),
                ),
              ),
              TextButton(onPressed: onRetry, child: Text(l10n.common_retryButton)),
            ],
          )
        else if (details.isEmpty)
          Text(l10n.report_stationEmptyCompartment_detailsEmpty, style: MedTextStyles.bodyMd(color: MedColors.text3))
        else
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: MedColors.border2),
                borderRadius: MedRadius.mdAll,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailRow(
                    isHeader: true,
                    location: l10n.tableCore_stationEmptyCompartmentDetailLocationColumn,
                    compartmentCount: l10n.tableCore_stationEmptyCompartmentDetailCompartmentCountColumn,
                    stepCount: l10n.tableCore_stationEmptyCompartmentDetailStepCountColumn,
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: details.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: MedColors.border2),
                      itemBuilder: (context, index) {
                        final d = details[index];
                        return _DetailRow(
                          location: d.location ?? '-',
                          compartmentCount: d.compartmentCount?.toString() ?? '-',
                          stepCount: d.stepCount?.toString() ?? '-',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.location,
    required this.compartmentCount,
    required this.stepCount,
    this.isHeader = false,
  });

  final String location;
  final String compartmentCount;
  final String stepCount;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? MedTextStyles.bodySm(color: MedColors.text3, weight: FontWeight.w600)
        : MedTextStyles.monoMd(color: MedColors.text);

    return Container(
      color: isHeader ? MedColors.surface2 : null,
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(location, style: style)),
          Expanded(child: Text(compartmentCount, style: style, textAlign: TextAlign.end)),
          Expanded(child: Text(stepCount, style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: MedTextStyles.titleMd()),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(subtitle!, style: MedTextStyles.bodyMd(color: MedColors.text3)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close, size: 18, color: MedColors.text3),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: 10),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: MedTextStyles.bodySm(color: MedColors.text3)),
          const SizedBox(height: 2),
          Text(value, style: MedTextStyles.numericLg()),
        ],
      ),
    );
  }
}
