part of 'inconsistency_screen.dart';

/// Bir tutarsızlık kaydının tüm detaylarını gösteren dialog.
///
/// Kullanım:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => InconsistencyDetailDialog(inconsistency: item),
/// );
/// ```
class InconsistencyDetailDialog extends StatelessWidget {
  const InconsistencyDetailDialog({super.key, required this.inconsistency});

  final Inconsistency inconsistency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSolved = inconsistency.isSolved;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.xl2All),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(
              title: l10n.inconsistency_detailDialogTitle,
              isSolved: isSolved,
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: MedSpacing.insetXl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      children: [
                        _DetailRow(label: l10n.inconsistency_medicineLabel, value: inconsistency.medicine?.name),
                        _DetailRow(
                          label: l10n.inconsistency_activeIngredientsLabel,
                          value: inconsistency.activeIngredients?.join(', '),
                        ),
                      ],
                    ),
                    const SizedBox(height: MedSpacing.lg),
                    _Section(
                      children: [
                        _DetailRow(
                          label: l10n.inconsistency_quantityLabel,
                          value:
                              '${inconsistency.quantity?.formatFractional} ${inconsistency.medicine?.operationUnitLocalized(context)}',
                          valueColor: MedColors.red,
                        ),
                        _DetailRow(
                          label: l10n.inconsistency_requiredQuantityLabel,
                          value:
                              '${inconsistency.requiredQuantity?.formatFractional} ${inconsistency.medicine?.operationUnitLocalized(context)}',
                        ),
                        _DetailRow(label: l10n.inconsistency_miadDateLabel, value: _formatDate(inconsistency.miadDate)),
                        _DetailRow(label: l10n.inconsistency_shelfLabel, value: inconsistency.shelfNo?.toString()),
                        _DetailRow(
                          label: l10n.inconsistency_compartmentLabel,
                          value: inconsistency.corpartmentNo?.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: MedSpacing.lg),
                    _Section(
                      children: [
                        _DetailRow(label: l10n.inconsistency_reportedByUserLabel, value: inconsistency.user?.fullName),
                        _DetailRow(
                          label: l10n.inconsistency_createdDateLabel,
                          value: _formatDateTime(inconsistency.createdDate),
                        ),
                        if (isSolved) ...[
                          _DetailRow(
                            label: l10n.inconsistency_resolvedByUserLabel,
                            value: inconsistency.solvedUser?.fullName,
                            valueColor: MedColors.green,
                          ),
                          _DetailRow(
                            label: l10n.inconsistency_resolvedDateLabel,
                            value: _formatDateTime(inconsistency.solvedDate),
                          ),
                        ],
                      ],
                    ),
                    if ((inconsistency.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: MedSpacing.lg),
                      Text(l10n.inconsistency_descriptionLabel, style: MedTextStyles.titleSm(color: MedColors.text2)),
                      const SizedBox(height: MedSpacing.xs),
                      Container(
                        width: double.infinity,
                        padding: MedSpacing.insetMd,
                        decoration: BoxDecoration(
                          color: MedColors.surface2,
                          borderRadius: MedRadius.mdAll,
                          border: Border.all(color: MedColors.border),
                        ),
                        child: Text(inconsistency.description!, style: MedTextStyles.bodyMd()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: MedSpacing.insetXl,
              child: SizedBox(
                width: double.infinity,
                child: MedButton(label: l10n.common_closeTooltip, onPressed: () => Navigator.of(context).pop()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  String? _formatDateTime(DateTime? date) {
    if (date == null) return null;
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.isSolved, required this.onClose});

  final String title;
  final bool isSolved;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: BorderRadius.only(topLeft: MedRadius.xl2, topRight: MedRadius.xl2),
        border: Border(bottom: BorderSide(color: MedColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: MedTextStyles.titleMd())),
          _StatusBadge(isSolved: isSolved, l10n: l10n),
          const SizedBox(width: MedSpacing.sm),
          IconButton(icon: const Icon(Icons.close), onPressed: onClose, tooltip: l10n.common_closeTooltip),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isSolved, required this.l10n});

  final bool isSolved;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final color = isSolved ? MedColors.green : MedColors.amber;
    final bg = isSolved ? MedColors.greenLight : MedColors.amberLight;
    final label = isSolved ? l10n.inconsistency_statusSolvedBadge : l10n.inconsistency_statusUnsolvedBadge;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: MedTextStyles.monoSm(color: color)),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String? value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MedSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: MedTextStyles.bodySm(color: MedColors.text2)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value!,
              textAlign: TextAlign.right,
              style: MedTextStyles.bodyMd(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
