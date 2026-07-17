// [SWREQ-UI-CAB-005]
// İlaç atama sağ panel içeriği.
//
// [OperationPanelBase] iskeletine yerleştirilir.
// Göz seçilmeden önce placeholder gösterir.
// Göz seçilince:
//   - CellInfoCard (stok özeti)
//   - İlaç seçici butonu
//   - Min / Maks / Kritik miktar girişleri
//   - Atamayı Kaydet / Atamayı Kaldır butonları
//
// KULLANIM:
//   OperationPanelBase(
//     mode: CabinOperationMode.assign,
//     child: DrugAssignmentPanel(
//       state: state,
//       onSelectDrug: () async { ... },
//       onMinChanged: notifier.onMinQtyChanged,
//       onMaxChanged: notifier.onMaxQtyChanged,
//       onCriticalChanged: notifier.onCriticalQtyChanged,
//       onSave: notifier.saveAssignment,
//       onDelete: notifier.deleteAssignment,
//     ),
//   )
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

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
    return Column(
      key: ValueKey(state.assignment),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MedSelectionField(
          label: context.l10n.assignment_drugSectionLabel,
          initialValue: state.assignment.medicine,
          dataSource: (skip, take, search) =>
              ref.read(getDrugsUseCaseProvider).call(GetDrugsParams(skip: skip, take: take, search: search)),
          labelBuilder: (drug) => drug.name,
          onSelected: (drug) => onSelectDrug(drug),
        ),

        const SizedBox(height: 14),

        Row(
          spacing: 8.0,
          children: [
            Expanded(
              child: MedTextInputField(
                key: ValueKey(state.minQty),
                readOnly: true,
                label: context.l10n.common_minLabel,
                initialValue: state.minQty?.toCustomString(),
                onTap: () async {
                  final result = await showNumpadView(context, initialValue: state.minQty?.toCustomString() ?? '');
                  if (result != null) {
                    onMinChanged(int.tryParse(result));
                  }
                },
                onChanged: (String? value) {},
              ),
            ),
            Expanded(
              child: MedTextInputField(
                key: ValueKey(state.maxQty),
                readOnly: true,
                label: context.l10n.common_maxLabel,
                initialValue: state.maxQty?.toCustomString(),
                onTap: () async {
                  final result = await showNumpadView(context, initialValue: state.maxQty?.toCustomString() ?? '');
                  if (result != null) {
                    onMaxChanged(int.tryParse(result));
                  }
                },
                onChanged: (String? value) {},
              ),
            ),
            Expanded(
              child: MedTextInputField(
                key: ValueKey(state.criticalQty),
                readOnly: true,

                label: context.l10n.common_criticalLabel,
                initialValue: state.criticalQty?.toCustomString(),
                onTap: () async {
                  final result = await showNumpadView(context, initialValue: state.criticalQty?.toCustomString() ?? '');
                  if (result != null) {
                    onCriticalChanged(int.tryParse(result));
                  }
                },
                onChanged: (String? value) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

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
