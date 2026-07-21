import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/drug_assignment_state.dart';

class DrugAssignmentPanel extends StatelessWidget {
  const DrugAssignmentPanel({
    super.key,
    required this.state,
    required this.onSelectDrug,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onCriticalChanged,
    required this.onSave,
    required this.onDelete,
  });

  final DrugAssignmentUiState state;

  /// İlaç seç butonuna basılınca çağrılır.
  /// Dialog açma sorumluluğu view'dadır — panel bilmez.
  final Function(Medicine? medicine) onSelectDrug;
  final ValueChanged<int?> onMinChanged;
  final ValueChanged<int?> onMaxChanged;
  final ValueChanged<int?> onCriticalChanged;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      DrugAssignmentCellSelected s => _CellSelectedContent(
        state: s,
        onSelectDrug: onSelectDrug,
        onMinChanged: onMinChanged,
        onMaxChanged: onMaxChanged,
        onCriticalChanged: onCriticalChanged,
        onSave: onSave,
        onDelete: onDelete,
      ),
      DrugAssignmentSaving s => _SavingContent(state: s),
      _ => const _PlaceholderContent(),
    };
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MedColors.surface3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MedColors.border, width: 1.5),
            ),
            child: Icon(Icons.touch_app_rounded, size: 22, color: MedColors.text4),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.common_selectCellTitle,
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MedColors.text3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.assignment_assignDrugPlaceholder,
            style: MedTextStyles.bodySm(color: MedColors.text4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SavingContent extends StatelessWidget {
  const _SavingContent({required this.state});

  final DrugAssignmentSaving state;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _CellSelectedContent extends ConsumerWidget {
  const _CellSelectedContent({
    required this.state,
    required this.onSelectDrug,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onCriticalChanged,
    required this.onSave,
    required this.onDelete,
  });

  final DrugAssignmentCellSelected state;
  final ValueChanged<Medicine?> onSelectDrug;
  final ValueChanged<int?> onMinChanged;
  final ValueChanged<int?> onMaxChanged;
  final ValueChanged<int?> onCriticalChanged;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = state.selectedDrug ?? state.assignment.medicine;
    final suffix = medicine?.fillingUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

    return Column(
      spacing: 8.0,
      key: ValueKey(state.assignment),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MedValueCard(
          key: ValueKey(state.assignment.medicine),
          label: context.l10n.assignment_drugSectionLabel,
          value: state.selectedDrug?.name ?? state.assignment.medicine?.name ?? '',
          density: MedValueCardDensity.compact,
          trailingIcon: PhosphorIcons.magnifyingGlass(),
          onTap: () async {
            final result = await SelectionDialog.show<Medicine>(
              context,
              title: context.l10n.assignment_drugSectionLabel,
              dataSource: (skip, take, search) =>
                  ref.read(getDrugsUseCaseProvider).call(GetDrugsParams(skip: skip, take: take, search: search)),
              labelBuilder: (drug) => drug.name,
            );
            if (result != null) {
              onSelectDrug(result);
            }
          },
        ),

        // Min
        MedValueCard(
          label: context.l10n.common_minLabel,
          value: state.minQty?.toString() ?? '0',
          density: MedValueCardDensity.compact,
          suffix: suffix,
          onTap: () async {
            final result = await showNumpadView(context, initialValue: state.minQty?.toCustomString() ?? '');
            if (result != null) {
              onMinChanged(int.tryParse(result));
            }
          },
        ),

        // Maks
        MedValueCard(
          label: context.l10n.common_maxLabel,
          value: state.maxQty?.toString() ?? '0',
          density: MedValueCardDensity.compact,
          suffix: suffix,
          onTap: () async {
            final result = await showNumpadView(context, initialValue: state.maxQty?.toCustomString() ?? '');
            if (result != null) {
              onMaxChanged(int.tryParse(result));
            }
          },
        ),

        // Kritik
        MedValueCard(
          label: context.l10n.common_criticalLabel,
          value: state.criticalQty?.toString() ?? '0',
          density: MedValueCardDensity.compact,
          suffix: suffix,
          onTap: () async {
            final result = await showNumpadView(context, initialValue: state.criticalQty?.toCustomString() ?? '');
            if (result != null) {
              onCriticalChanged(int.tryParse(result));
            }
          },
        ),

        Spacer(),

        // Butonlar
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kaydet
            MedButton(
              label: context.l10n.assignment_saveAssignmentButton,
              variant: MedButtonVariant.primary,
              onPressed: state.canSave ? onSave : null,
            ),

            // Sil — sadece atanmış göz için
            if (state.isAssigned) ...[
              const SizedBox(height: 8),
              MedButton(
                label: context.l10n.assignment_removeAssignmentButton,
                variant: MedButtonVariant.danger,
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
