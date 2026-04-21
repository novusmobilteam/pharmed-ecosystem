// lib/features/cabin/presentation/widgets/drug_assignment_panel.dart
//
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
import 'package:pharmed_client/l10n/l10n_ext.dart';
import 'package:pharmed_client/widgets/cell_info_card.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../state/drug_assignment_ui_state.dart';

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
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stok özet kartı
          CellInfoCard(stock: state.assignment.stocks?.first),
          const SizedBox(height: 14),

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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// İlaç seçici
// ─────────────────────────────────────────────────────────────────

class _DrugSelector extends StatelessWidget {
  const _DrugSelector({required this.selectedDrug, required this.onTap});

  final Medicine? selectedDrug;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedDrug != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.assignment_drugSectionLabel,
          style: TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: MedColors.text3,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: hasSelection ? MedColors.blueLight : MedColors.surface2,
              border: Border.all(color: hasSelection ? MedColors.blue : MedColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasSelection ? (selectedDrug!.name ?? '—') : context.l10n.assignment_drugSelectorHint,
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 13,
                      fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w400,
                      color: hasSelection ? MedColors.blue : MedColors.text3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.search_rounded, size: 16, color: hasSelection ? MedColors.blue : MedColors.text3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Miktar girişleri
// ─────────────────────────────────────────────────────────────────

class _QtyFields extends StatelessWidget {
  const _QtyFields({
    required this.minQty,
    required this.maxQty,
    required this.criticalQty,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onCriticalChanged,
  });

  final int? minQty;
  final int? maxQty;
  final int? criticalQty;
  final ValueChanged<int?> onMinChanged;
  final ValueChanged<int?> onMaxChanged;
  final ValueChanged<int?> onCriticalChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.assignment_quantitySectionLabel,
          style: TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: MedColors.text3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: _QtyInput(label: context.l10n.common_minLabel, value: minQty, onChanged: onMinChanged),
            ),
            Expanded(
              child: _QtyInput(label: context.l10n.common_maxLabel, value: maxQty, onChanged: onMaxChanged),
            ),
            Expanded(
              child: _QtyInput(label: context.l10n.common_criticalLabel, value: criticalQty, onChanged: onCriticalChanged),
            ),
          ],
        ),
      ],
    );
  }
}

class _QtyInput extends StatefulWidget {
  const _QtyInput({required this.label, required this.value, required this.onChanged});

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  State<_QtyInput> createState() => _QtyInputState();
}

class _QtyInputState extends State<_QtyInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(_QtyInput old) {
    super.didUpdateWidget(old);
    // Dışarıdan value değişirse (göz değişimi) controller'ı güncelle
    if (widget.value != old.value) {
      final newText = widget.value?.toString() ?? '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: MedFonts.mono, fontSize: 14, fontWeight: FontWeight.w600, color: MedColors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: MedColors.surface2,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.blue, width: 1.5),
            ),
          ),
          onChanged: (v) => widget.onChanged(int.tryParse(v)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Aksiyon butonları
// ─────────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.canSave, required this.isAssigned, required this.onSave, required this.onDelete});

  final bool canSave;
  final bool isAssigned;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kaydet
        _PanelButton.primary(
          label: context.l10n.assignment_saveAssignmentButton,
          icon: Icons.check_rounded,
          enabled: canSave,
          onTap: canSave ? onSave : null,
        ),

        // Sil — sadece atanmış göz için
        if (isAssigned) ...[
          const SizedBox(height: 8),
          _PanelButton.danger(label: context.l10n.assignment_removeAssignmentButton, icon: Icons.delete_outline_rounded, onTap: onDelete),
        ],
      ],
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isDanger,
    this.enabled = true,
    this.onTap,
  });

  factory _PanelButton.primary({
    required String label,
    required IconData icon,
    bool enabled = true,
    VoidCallback? onTap,
  }) => _PanelButton(label: label, icon: icon, isPrimary: true, isDanger: false, enabled: enabled, onTap: onTap);

  factory _PanelButton.danger({required String label, required IconData icon, VoidCallback? onTap}) =>
      _PanelButton(label: label, icon: icon, isPrimary: false, isDanger: true, onTap: onTap);

  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isDanger;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color fg;

    if (!enabled) {
      bg = MedColors.surface3;
      border = MedColors.border;
      fg = MedColors.text4;
    } else if (isDanger) {
      bg = MedColors.redLight;
      border = MedColors.red;
      fg = MedColors.red;
    } else {
      bg = MedColors.blue;
      border = MedColors.blue;
      fg = Colors.white;
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: enabled && isPrimary
              ? [BoxShadow(color: MedColors.blue.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
