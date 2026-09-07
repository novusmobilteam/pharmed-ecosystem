import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Dolum listesi seçim ekranının sağ panelinde satırları listeler.
/// CabinAssignmentListView'e paralel ama farklı veri modelinden
/// (RefillListDetail) besleniyor ve stok/doluluk bar'ı yerine manager'ın
/// belirlediği hedef miktarı gösterir — bu ekranda "mevcut stok" değil
/// "ne kadar doldurulacağı" önemli.
// presentation/widgets/refill_list_assignment_list_view.dart

class RefillListAssignmentListView extends StatelessWidget {
  const RefillListAssignmentListView({super.key, required this.items, required this.selectedDrawerIds, this.onToggle});

  final List<RefillListDetail> items;
  final Set<int> selectedDrawerIds;
  final ValueChanged<int>? onToggle;

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
            SizedBox(
              width: 140,
              child: Text(context.l10n.refillList_column_targetQuantity, style: textStyle, textAlign: TextAlign.end),
            ),
            SizedBox(
              width: 140,
              child: Text(context.l10n.refillList_column_filledQuantity, style: textStyle, textAlign: TextAlign.end),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        const Divider(height: 1, thickness: 2),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = items.elementAt(index);
              final name = row.medicine?.name ?? '-';
              final cabinName = row.cabinDrawer?.drawerSlot?.cabin?.name;

              final id = row.cabinAssignment?.cabinDrawerId;
              final isSelected = id != null && selectedDrawerIds.contains(id);
              final isFilled = row.isFilled;
              final filledLabel = row.filledQuantityLabel(context);

              return GestureDetector(
                onTap: (id == null || onToggle == null) ? null : () => onToggle!(id),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Expanded(child: Text(cabinName ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis)),
                      SizedBox(
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 2,
                          children: [Text(row.plannedQuantityLabel(context), textAlign: TextAlign.end)],
                        ),
                      ),
                      SizedBox(width: 140, child: Text(filledLabel ?? '-', textAlign: TextAlign.end)),
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
