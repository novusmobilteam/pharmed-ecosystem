import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinAssignmentListView extends StatelessWidget {
  const CabinAssignmentListView({
    super.key,
    required this.items,
    required this.selectedItemIds,
    this.onToggle,
    this.selectedCellIds = const {},
    this.onToggleCell,
    this.onDelete,
    this.onReplace,
    this.cabinLabelOf,
    this.showMiad = false,
  });

  final List<MedicineAssignment> items;
  final Set<int> selectedItemIds;
  final ValueChanged<int>? onToggle;

  /// Serum avadanlığı atamaları (cabinDrawerDetailId'li) göz bazında seçilir.
  /// [onToggleCell] verilmezse bu satırlar [onToggle] ile raf bazında seçilir.
  final Set<int> selectedCellIds;
  final ValueChanged<int>? onToggleCell;
  final ValueChanged<MedicineAssignment>? onDelete;
  final ValueChanged<MedicineAssignment>? onReplace;

  /// Verilirse "Kabin" sütunu gösterilir — istasyon geneli listelerde satırın
  /// hangi kabine ait olduğunu belirtir.
  final String? Function(MedicineAssignment assignment)? cabinLabelOf;

  /// true → Stok'un yanında "SKT" sütunu: gözdeki stokların EN ERKEN SKT'si.
  /// Geçmişse kırmızı, [_expiringSoonDays] gün içindeyse turuncu.
  final bool showMiad;

  static const _expiringSoonDays = 30;

  /// Pozitif miktarlı stokların en erken anlamlı SKT'si. Boş göz işaret
  /// tarihi (2099) yok sayılır. Serum avadanlığı satırında yalnızca o gözün
  /// stokları.
  static DateTime? _earliestMiad(MedicineAssignment assignment) {
    final cellId = assignment.cabinDrawerDetailId;
    DateTime? earliest;
    for (final s in assignment.stocks ?? const <CabinStock>[]) {
      if (cellId != null && s.cabinDrawerDetailId != cellId) continue;
      final d = s.miadDate;
      if ((s.quantity ?? 0) <= 0 || d == null || d.year >= 2099) continue;
      if (earliest == null || d.isBefore(earliest)) earliest = d;
    }
    return earliest;
  }

  static Color _miadColor(DateTime? miad) {
    if (miad == null) return MedColors.text3;
    if (miad.isExpiredMiad) return MedColors.red;
    if (miad.difference(todayDateOnly()).inDays <= _expiringSoonDays) return MedColors.amber;
    return MedColors.text;
  }

  double _ratio(double v, double max) => max > 0 ? (v / max).clamp(0.0, 1.0) : 0.0;

  // Sütun genişlikleri (flex) — başlık ve satır aynı değerleri kullanır.
  static const _medicineFlex = 4;
  static const _cabinFlex = 3;
  static const _locationFlex = 3;
  static const _stockFlex = 2;
  static const _miadFlex = 2;

  /// Tüm hücreler aynı boyutta (bodySm); ilaç adı kalın.
  static TextStyle _cell({Color? color, FontWeight? weight}) =>
      MedTextStyles.bodySm(color: color ?? MedColors.text, weight: weight);

  static Widget _cellText(String text, {int flex = 1, TextStyle? style}) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style ?? _cell()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final textStyle = MedTextStyles.titleSm();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (onToggle != null)
              SizedBox(width: 100, child: Text(context.l10n.cabinAssignmentList_selectColumn, style: textStyle)),
            _cellText(context.l10n.cabinAssignmentList_medicineColumn, flex: _medicineFlex, style: textStyle),
            if (cabinLabelOf != null)
              _cellText(context.l10n.cabinAssignmentList_cabinColumn, flex: _cabinFlex, style: textStyle),
            _cellText(context.l10n.cabinAssignmentList_locationColumn, flex: _locationFlex, style: textStyle),
            _cellText(context.l10n.cabinAssignmentList_stockColumn, flex: _stockFlex, style: textStyle),
            if (showMiad) _cellText(context.l10n.cabinAssignmentList_miadColumn, flex: _miadFlex, style: textStyle),
            SizedBox(width: 100, child: Text(context.l10n.cabinAssignmentList_fillLevelColumn, style: textStyle)),
            if (onDelete != null || onReplace != null)
              SizedBox(width: 96, child: Text(context.l10n.cabinAssignmentList_actionsColumn, style: textStyle)),
          ],
        ),
        SizedBox(height: 12.0),
        Divider(height: 1, thickness: 2),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 1);
            },
            itemBuilder: (BuildContext context, int index) {
              final assignment = items.elementAt(index);
              final name = assignment.medicine?.name ?? '-';
              final serumCellId = assignment.cabinDrawerDetailId;
              final serumCell = serumCellId == null
                  ? null
                  : assignment.cabinDrawerDetail?.firstWhereOrNull((c) => c.id == serumCellId);
              final konum = serumCellId != null
                  ? context.l10n.assignment_idle_serumLocationLabel(
                      assignment.drawerUnit?.orderNo ?? 0,
                      serumCell?.stepNo ?? 0,
                    )
                  : assignment.isKubikType
                  ? context.l10n.cabinAssignmentList_cubicLocationLabel(
                      assignment.drawerUnit?.drawerSlot?.address ?? '-',
                      assignment.drawerUnit?.compartmentNo ?? '-',
                      assignment.drawerUnit?.orderNo ?? '-',
                    )
                  : context.l10n.cabinAssignmentList_unitLocationLabel(
                      assignment.drawerUnit?.drawerSlot?.orderNumber ?? '-',
                      assignment.drawerUnit?.compartmentNo ?? '-',
                    );

              double current = assignment.totalQuantity;
              double maxQty = assignment.maxQuantity.toDouble();
              double critQty = assignment.criticalQuantity.toDouble();
              double minQty = assignment.minQuantity.toDouble();
              final id = assignment.cabinDrawerId;
              final bool byCell = serumCellId != null && onToggleCell != null;
              bool isSelected = byCell
                  ? selectedCellIds.contains(serumCellId)
                  : id != null && selectedItemIds.contains(id);
              final VoidCallback? onTap = byCell
                  ? () => onToggleCell!(serumCellId)
                  : (id == null || onToggle == null)
                  ? null
                  : () => onToggle!(id);

              MedCellStockLevel level = current <= critQty
                  ? MedCellStockLevel.critical
                  : (current <= minQty ? MedCellStockLevel.low : MedCellStockLevel.ok);

              final color = level.color;

              final stock = assignment.stockRatioLabel;

              final pct = _ratio(current, maxQty);

              return GestureDetector(
                onTap: onTap,
                child: SizedBox(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (onToggle != null)
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 100,
                          child: Icon(
                            isSelected ? PhosphorIconsFill.checkSquare : PhosphorIcons.square(),
                            color: MedColors.blue,
                          ),
                        ),
                      _cellText(name, flex: _medicineFlex, style: _cell(weight: FontWeight.w600)),
                      if (cabinLabelOf != null) _cellText(cabinLabelOf!(assignment) ?? '—', flex: _cabinFlex),
                      _cellText(konum, flex: _locationFlex),
                      _cellText(stock, flex: _stockFlex),
                      if (showMiad)
                        () {
                          final miad = _earliestMiad(assignment);
                          return _cellText(
                            miad?.formattedDate ?? '—',
                            flex: _miadFlex,
                            style: _cell(
                              color: _miadColor(miad),
                              weight: miad != null && miad.isExpiredMiad ? FontWeight.w600 : null,
                            ),
                          );
                        }(),
                      SizedBox(
                        width: 100,
                        child: _StockBar(
                          pct: pct,
                          minPct: _ratio(minQty, maxQty),
                          critPct: _ratio(critQty, maxQty),
                          color: color,
                        ),
                      ),
                      if (onDelete != null || onReplace != null)
                        SizedBox(
                          width: 96,
                          child:
                              assignment.totalQuantity <=
                                  0 // [Madde 10] sadece stok 0'ken
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (onReplace != null)
                                      IconButton(
                                        icon: Icon(PhosphorIcons.arrowsClockwise(), size: 18, color: MedColors.blue),
                                        tooltip: context.l10n.cabinAssignmentList_replaceTooltip,
                                        onPressed: () => onReplace!(assignment),
                                      ),
                                    if (onDelete != null)
                                      IconButton(
                                        icon: Icon(PhosphorIcons.trash(), size: 18, color: MedColors.red),
                                        tooltip: context.l10n.cabinAssignmentList_deleteTooltip,
                                        onPressed: () => onDelete!(assignment),
                                      ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StockBar extends StatelessWidget {
  const _StockBar({required this.pct, required this.minPct, required this.critPct, required this.color});

  final double pct;
  final double minPct;
  final double critPct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Align(
        alignment: Alignment.center,
        child: ClipRRect(
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: MedColors.surface2,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ),
    );
  }
}
