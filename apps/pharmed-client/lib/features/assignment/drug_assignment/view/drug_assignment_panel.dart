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
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/drug_assignment_state.dart';

part '../widgets/action_buttons.dart';
part '../widgets/drug_selector.dart';
part '../widgets/qty_fields.dart';

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
  final VoidCallback onSelectDrug;

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

class _CellSelectedContent extends StatelessWidget {
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
  final VoidCallback onSelectDrug;
  final ValueChanged<int?> onMinChanged;
  final ValueChanged<int?> onMaxChanged;
  final ValueChanged<int?> onCriticalChanged;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // İlaç seçici
        _DrugSelector(selectedDrug: state.selectedDrug, onTap: onSelectDrug),
        const SizedBox(height: 14),

        // Miktar girişleri
        _QtyFields(
          minQty: state.minQty,
          maxQty: state.maxQty,
          criticalQty: state.criticalQty,
          onMinChanged: onMinChanged,
          onMaxChanged: onMaxChanged,
          onCriticalChanged: onCriticalChanged,
        ),
        const SizedBox(height: 20),

        // Butonlar
        _ActionButtons(canSave: state.canSave, isAssigned: state.isAssigned, onSave: onSave, onDelete: onDelete),
      ],
    );
  }
}
