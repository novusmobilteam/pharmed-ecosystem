import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class RefillListTableView extends StatelessWidget {
  const RefillListTableView({
    super.key,
    required this.items,
    required this.selectedItems,
    this.onToggle,
    this.isSelectable,
  });

  final List<RefillListDetail> items;
  final List<RefillListDetail> selectedItems;
  final ValueChanged<RefillListDetail>? onToggle;

  /// Satır seçime açık mı — verilmezse tüm satırlar seçilebilir sayılır.
  /// Tamamlanmış satırlar bu callback'ten bağımsız olarak HİÇ seçilemez.
  final bool Function(RefillListDetail)? isSelectable;

  static const double _checkboxWidth = 60;
  static const double _quantityWidth = 140;
  static const double _statusWidth = 130;

  @override
  Widget build(BuildContext context) {
    final selectedIds = {for (final s in selectedItems) s.id};

    return Container(
      decoration: MedDecoration.panelDecoration,
      child: Column(
        children: [
          _HeaderView(
            checkboxWidth: _checkboxWidth,
            quantityWidth: _quantityWidth,
            statusWidth: _statusWidth,
            showCheckboxColumn: onToggle != null,
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final isCompleted = item.fillStatus == RefillListItemFillStatus.completed;
                final canToggle =
                    onToggle != null &&
                    !isCompleted &&
                    item.cabinAssignment?.cabinDrawerId != null &&
                    (isSelectable?.call(item) ?? true);

                return _TableItemView(
                  key: ValueKey(item.id),
                  checkboxWidth: _checkboxWidth,
                  quantityWidth: _quantityWidth,
                  statusWidth: _statusWidth,
                  showCheckboxColumn: onToggle != null,
                  showCheckbox: !isCompleted,
                  isSelected: selectedIds.contains(item.id),
                  item: item,
                  onToggle: canToggle ? () => onToggle!(item) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderView extends StatelessWidget {
  const _HeaderView({
    required this.checkboxWidth,
    required this.quantityWidth,
    required this.statusWidth,
    required this.showCheckboxColumn,
  });

  final double checkboxWidth;
  final double quantityWidth;
  final double statusWidth;
  final bool showCheckboxColumn;

  @override
  Widget build(BuildContext context) {
    final textStyle = MedTextStyles.titleSm(color: Colors.white);

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.blue,
        borderRadius: BorderRadius.only(topLeft: MedRadius.md, topRight: MedRadius.md),
      ),
      child: Row(
        children: [
          if (showCheckboxColumn) SizedBox(width: checkboxWidth),
          Expanded(child: Text(context.l10n.cabinAssignmentList_medicineColumn, style: textStyle)),
          Expanded(child: Text(context.l10n.cabinAssignmentList_locationColumn, style: textStyle)),
          SizedBox(
            width: quantityWidth,
            child: Text(context.l10n.refillList_column_targetQuantity, style: textStyle, textAlign: TextAlign.end),
          ),
          SizedBox(
            width: quantityWidth,
            child: Text(context.l10n.refillList_column_filledQuantity, style: textStyle, textAlign: TextAlign.end),
          ),
          SizedBox(
            width: statusWidth,
            child: Text(context.l10n.refillList_column_status, style: textStyle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _TableItemView extends StatelessWidget {
  const _TableItemView({
    super.key,
    required this.checkboxWidth,
    required this.quantityWidth,
    required this.statusWidth,
    required this.showCheckboxColumn,
    required this.showCheckbox,
    required this.isSelected,
    required this.item,
    this.onToggle,
  });

  final double checkboxWidth;
  final double quantityWidth;
  final double statusWidth;

  /// Sütun alanı — başlıkla hizalı kalmak için her satırda korunur.
  final bool showCheckboxColumn;

  /// Tamamlanan satırda alan boş kalır, checkbox çizilmez.
  final bool showCheckbox;

  final bool isSelected;
  final RefillListDetail item;

  /// null → satır seçilemez (tıklama ve checkbox pasif).
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final status = item.fillStatus;
    final filledLabel = item.filledQuantityLabel;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            if (showCheckboxColumn)
              SizedBox(
                width: checkboxWidth,
                child: showCheckbox
                    ? MedCheckbox(
                        value: isSelected,
                        onChanged: onToggle != null ? (_) => onToggle!() : null,
                        size: MedCheckboxSize.lg,
                      )
                    : null,
              ),
            Expanded(
              child: Text(
                item.medicine?.name ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MedTextStyles.titleSm(),
              ),
            ),
            Expanded(
              child: Text(
                item.cabinDrawer?.drawerSlot?.cabin?.name ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MedTextStyles.bodyMd(),
              ),
            ),
            SizedBox(
              width: quantityWidth,
              child: Text(item.plannedQuantityLabel, textAlign: TextAlign.end, style: MedTextStyles.bodyMd()),
            ),
            SizedBox(
              width: quantityWidth,
              child: Text(
                filledLabel ?? '-',
                textAlign: TextAlign.end,
                style: filledLabel != null
                    ? MedTextStyles.bodyLg(color: status.color, weight: FontWeight.w700)
                    : MedTextStyles.bodyMd(color: MedColors.text3),
              ),
            ),
            SizedBox(
              width: statusWidth,
              child: Center(child: RefillListFillStatusBadge(status: status)),
            ),
          ],
        ),
      ),
    );
  }
}

class RefillListFillStatusBadge extends StatelessWidget {
  const RefillListFillStatusBadge({super.key, required this.status});

  final RefillListItemFillStatus status;

  @override
  Widget build(BuildContext context) {
    return MedChip(
      label: status.label,
      style: status.chipStyle,
      shape: MedChipShape.pill,
      size: MedChipSize.md,
      showBorder: false,
    );
  }
}
