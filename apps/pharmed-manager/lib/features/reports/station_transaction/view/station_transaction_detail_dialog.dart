part of 'station_transaction_report_screen.dart';

class StationTransactionDetailDialog extends StatelessWidget {
  const StationTransactionDetailDialog({super.key, required this.transaction});

  final StationTransaction transaction;

  static Future<void> show(BuildContext context, {required StationTransaction transaction}) async {
    final notifier = context.read<StationTransactionReportNotifier>();
    notifier.openDetail(transaction);
    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => ChangeNotifierProvider.value(
        value: notifier,
        child: StationTransactionDetailDialog(transaction: transaction),
      ),
    );
    notifier.closeDetail();
  }

  List<(String, String)> _fields(BuildContext context) {
    final t = transaction;
    final l10n = context.l10n;
    String v(Object? value) => (value == null || value.toString().isEmpty) ? '-' : value.toString();
    return [
      (l10n.tableCore_stationTransactionDateColumn, v(t.transactionDate?.formattedDate)),
      (l10n.tableCore_stationTransactionTypeColumn, v(t.transaction)),
      (l10n.tableCore_stationTransactionCabinColumn, v(t.cabinName)),
      (l10n.tableCore_stationTransactionQuantityColumn, v(t.quantity?.formatFractional)),
      (l10n.tableCore_stationTransactionCodeColumn, v(t.code)),
      (l10n.tableCore_stationTransactionBarcodeColumn, v(t.barcode)),
      (l10n.tableCore_stationTransactionOrderColumn, v(t.order)),
      (l10n.tableCore_stationTransactionCompartmentColumn, v(t.compartment)),
      (l10n.tableCore_stationTransactionPatientColumn, v(t.patient)),
      (l10n.tableCore_stationTransactionProtocolCodeColumn, v(t.protocolCode)),
      (l10n.tableCore_stationTransactionPerformedByColumn, v(t.performedBy)),
      (l10n.tableCore_stationTransactionWitnessColumn, v(t.witness)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hasSteps = transaction.hasSteps == true;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640, maxHeight: size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              title: context.l10n.report_stationTransaction_detailDialogTitle,
              subtitle: transaction.material,
            ),
            Divider(height: 1, color: MedColors.border2),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InfoGrid(fields: _fields(context)),
                    if (hasSteps) ...[
                      const SizedBox(height: 20),
                      Consumer<StationTransactionReportNotifier>(
                        builder: (context, notifier, _) => _StepsSection(
                          loading: notifier.isFetchingSteps,
                          failed: notifier.isStepsFailed,
                          steps: notifier.detailSteps,
                          onRetry: notifier.retrySteps,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({required this.loading, required this.failed, required this.steps, required this.onRetry});

  final bool loading;
  final bool failed;
  final List<StationTransactionStep> steps;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeCount = steps.where((s) => (s.quantity ?? 0) > 0).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              l10n.report_stationTransaction_stepsSectionTitle,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
            ),
            const Spacer(),
            if (steps.isNotEmpty)
              Text(
                l10n.report_stationTransaction_stepsSummary(activeCount),
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (loading)
          const SizedBox(height: 64, child: Center(child: CircularProgressIndicator.adaptive()))
        else if (failed)
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.report_stationTransaction_stepsLoadError,
                  style: MedTextStyles.bodyMd(color: MedColors.red),
                ),
              ),
              TextButton(onPressed: onRetry, child: Text(l10n.common_retryButton)),
            ],
          )
        else if (steps.isEmpty)
          Text(l10n.report_stationTransaction_stepsEmpty, style: MedTextStyles.bodyMd(color: MedColors.text3))
        else
          _StepStrip(steps: steps),
      ],
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(subtitle!, style: MedTextStyles.bodyMd(color: MedColors.text3)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

// ─── BİLGİ IZGARASI ──────────────────────────────────────────────────────────

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.fields});

  final List<(String, String)> fields;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (label, value) in fields)
              SizedBox(
                width: itemWidth,
                child: _InfoTile(label: label, value: value),
              ),
          ],
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: MedTextStyles.bodyMd(color: MedColors.text).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StepStrip extends StatelessWidget {
  const _StepStrip({required this.steps});

  final List<StationTransactionStep> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(child: _StepCell(step: steps[i])),
        ],
      ],
    );
  }
}

class _StepCell extends StatelessWidget {
  const _StepCell({required this.step});

  final StationTransactionStep step;

  @override
  Widget build(BuildContext context) {
    final qty = step.quantity ?? 0;
    final active = qty > 0;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: active ? MedColors.blueLight : MedColors.surface2,
        border: Border.all(color: active ? MedColors.blue : MedColors.border2, width: active ? 1.5 : 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${step.stepNo ?? '-'}',
            style: TextStyle(fontSize: 10, color: active ? MedColors.blue : const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 2),
          Text(
            active ? qty.formatFractional : '–',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? MedColors.blue : const Color(0xFFD1D5DB),
            ),
          ),
        ],
      ),
    );
  }
}
