import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinAssignmentListView extends StatelessWidget {
  const CabinAssignmentListView({super.key, required this.items, required this.selectedItemIds, this.onToggle});

  final List<MedicineAssignment> items;
  final Set<int> selectedItemIds;
  final ValueChanged<int>? onToggle;

  double _ratio(double v, double max) => max > 0 ? (v / max).clamp(0.0, 1.0) : 0.0;

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
            Expanded(child: Text(context.l10n.cabinAssignmentList_medicineColumn, style: textStyle)),
            Expanded(child: Text(context.l10n.cabinAssignmentList_locationColumn, style: textStyle)),
            Expanded(child: Text(context.l10n.cabinAssignmentList_stockColumn, style: textStyle)),
            SizedBox(width: 100, child: Text(context.l10n.cabinAssignmentList_fillLevelColumn, style: textStyle)),
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
              final konum = assignment.isKubikType
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
              double maxQty = assignment.maxQuantity?.toDouble() ?? 0.0;
              double critQty = assignment.critQuantityFromBackend;
              double minQty = assignment.minQuantityFromBackend;
              final id = assignment.cabinDrawerId;
              bool isSelected = id != null && selectedItemIds.contains(id);

              MedCellStockLevel level = current <= critQty
                  ? MedCellStockLevel.critical
                  : (current <= minQty ? MedCellStockLevel.low : MedCellStockLevel.ok);

              final color = level.color;

              String stock =
                  '${current.formatFractional}/${maxQty.formatFractional} (${assignment.operationUnit(context)})';

              final pct = _ratio(current, maxQty);

              return GestureDetector(
                onTap: (id == null || onToggle == null) ? null : () => onToggle!(id),
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
                      Expanded(child: Text(name)),
                      Expanded(child: Text(konum)),
                      Expanded(child: Text(stock)),
                      SizedBox(
                        width: 100,
                        child: _StockBar(
                          pct: pct,
                          minPct: _ratio(minQty, maxQty),
                          critPct: _ratio(critQty, maxQty),
                          color: color,
                        ),
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
