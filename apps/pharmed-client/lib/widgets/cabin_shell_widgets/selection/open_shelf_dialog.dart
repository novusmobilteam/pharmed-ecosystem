// [SWREQ-CLI-CABIN-SERUM-OPEN-001] [IEC 62304 §5.5]
// Serum Açık Raf: avadanlıksız rafta birden çok ilaç atanır. Kabin görselinde
// raf tek blok olarak çizilir; dokununca bu pencere raftaki ilaçları listeler.
//   - İşlem seçim ekranları (dolum/sayım/boşaltma/imha): çoklu seçim ([onToggle]).
//   - İlaç atama: mevcut atamayı düzenleme ([onOpen]) ve rafa ilaç ekleme ([onAdd]).
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Future<void> showOpenShelfDialog({
  required BuildContext context,
  required int shelfNo,
  required List<MedicineAssignment> assignments,
  bool Function(MedicineAssignment assignment)? isSelected,
  bool Function(MedicineAssignment assignment)? canSelect,
  ValueChanged<MedicineAssignment>? onToggle,
  ValueChanged<MedicineAssignment>? onOpen,
  VoidCallback? onAdd,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _OpenShelfDialog(
      shelfNo: shelfNo,
      assignments: assignments,
      isSelected: isSelected,
      canSelect: canSelect,
      onToggle: onToggle,
      onOpen: onOpen,
      onAdd: onAdd,
    ),
  );
}

class _OpenShelfDialog extends StatefulWidget {
  const _OpenShelfDialog({
    required this.shelfNo,
    required this.assignments,
    this.isSelected,
    this.canSelect,
    this.onToggle,
    this.onOpen,
    this.onAdd,
  });

  final int shelfNo;
  final List<MedicineAssignment> assignments;
  final bool Function(MedicineAssignment)? isSelected;
  final bool Function(MedicineAssignment)? canSelect;
  final ValueChanged<MedicineAssignment>? onToggle;
  final ValueChanged<MedicineAssignment>? onOpen;
  final VoidCallback? onAdd;

  @override
  State<_OpenShelfDialog> createState() => _OpenShelfDialogState();
}

class _OpenShelfDialogState extends State<_OpenShelfDialog> {
  void _toggle(MedicineAssignment a) {
    widget.onToggle?.call(a);
    // Seçim notifier'da; pencere onu dinlemediği için yeniden çizilir.
    setState(() {});
  }

  void _open(MedicineAssignment a) {
    Navigator.of(context).pop();
    widget.onOpen?.call(a);
  }

  void _add() {
    Navigator.of(context).pop();
    widget.onAdd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [...widget.assignments]
      ..sort((a, b) => (a.medicine?.name ?? '').toLowerCase().compareTo((b.medicine?.name ?? '').toLowerCase()));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: MedSpacing.insetXl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.rows(), size: 18, color: MedColors.blue),
                  const SizedBox(width: MedSpacing.sm),
                  Expanded(child: Text(l10n.cabinOperation_openShelfTitle(widget.shelfNo), style: MedTextStyles.titleMd())),
                  Text(
                    l10n.cabinOperation_openShelfMedicineCount(items.length),
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                  ),
                ],
              ),
              const SizedBox(height: MedSpacing.lg),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: MedSpacing.xl),
                  child: Text(
                    l10n.cabinOperation_openShelfEmpty,
                    textAlign: TextAlign.center,
                    style: MedTextStyles.bodyMd(color: MedColors.text3),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.xs),
                    itemBuilder: (_, i) => _row(items[i]),
                  ),
                ),
              const SizedBox(height: MedSpacing.lg),
              Row(
                children: [
                  if (widget.onAdd != null)
                    MedButton(
                      label: l10n.cabinOperation_openShelfAddMedicine,
                      prefixIcon: Icon(PhosphorIcons.plus()),
                      variant: MedButtonVariant.secondary,
                      onPressed: _add,
                    ),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.common_closeButton)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(MedicineAssignment a) {
    final selectable = widget.onToggle != null && (widget.canSelect?.call(a) ?? true);
    final selected = widget.isSelected?.call(a) ?? false;
    final VoidCallback? onTap = widget.onOpen != null ? () => _open(a) : (selectable ? () => _toggle(a) : null);

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: selected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: selected ? MedColors.blue : MedColors.border2),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.medicine?.name ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${a.totalQuantity.toStringAsFixed(0)} / ${a.maxQuantity.toInt()}',
                    style: MedTextStyles.monoSm(color: MedColors.text3),
                  ),
                ],
              ),
            ),
            if (widget.onOpen != null)
              Icon(PhosphorIcons.caretRight(), size: 16, color: MedColors.text3)
            else if (widget.onToggle != null)
              Checkbox(value: selected, onChanged: selectable ? (_) => _toggle(a) : null),
          ],
        ),
      ),
    );
  }
}
