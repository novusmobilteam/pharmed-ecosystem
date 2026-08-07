// [SWREQ-UI-CABIN-DESIGN-002]
// Kabin dizaynı ekranının sol görseli. MasterCabinOverviewPanel'den
// KASITLI olarak ayrı — o ekran işlem (dolum/sayım/vb.) odaklı, bu ekran
// dizayn odaklı; gelecekte farklı yönlerde evrilecekler (bkz. dizayn notu).
// Sınıf: Class B

part of 'cabin_design_dialog.dart';

class CabinDesignVisual extends StatelessWidget {
  const CabinDesignVisual({super.key, required this.groups, required this.selectedSlotId, required this.onSlotTap});

  final List<DrawerGroup> groups;
  final int? selectedSlotId;
  final ValueChanged<DrawerGroup> onSlotTap;

  @override
  Widget build(BuildContext context) {
    // Kübik çekmeceleri 2'li satırlara böl (mockup'taki B-01/B-02 gibi yan
    // yana ikili düzen), serum/birim doz tam genişlik tek satır alır.
    final rows = <List<DrawerGroup>>[];
    int i = 0;
    while (i < groups.length) {
      final g = groups[i];
      if (g.isKubik &&
          !g.isReturnDrawer &&
          i + 1 < groups.length &&
          groups[i + 1].isKubik &&
          !groups[i + 1].isReturnDrawer) {
        rows.add([g, groups[i + 1]]);
        i += 2;
      } else {
        rows.add([g]);
        i += 1;
      }
    }

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface3,
        border: Border.all(color: MedColors.border, width: 3),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int r = 0; r < rows.length; r++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int c = 0; c < rows[r].length; c++) ...[
                  Expanded(
                    child: _SlotCard(
                      group: rows[r][c],
                      isSelected: rows[r][c].slot.id == selectedSlotId,
                      onTap: () => onSlotTap(rows[r][c]),
                    ),
                  ),
                  if (c < rows[r].length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
            if (r < rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.group, required this.isSelected, required this.onTap});

  final DrawerGroup group;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isReturn = group.isReturnDrawer;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isReturn
              ? MedColors.amberLight
              : isSelected
              ? MedColors.blueLight
              : MedColors.surface,
          border: Border.all(
            color: isReturn ? MedColors.amber : (isSelected ? MedColors.blue : MedColors.border),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: MedRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  group.address,
                  style: TextStyle(
                    fontFamily: MedFonts.mono,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isReturn ? MedColors.amber : MedColors.text3,
                  ),
                ),
                const Spacer(),
                if (isReturn)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: MedColors.amber, borderRadius: MedRadius.smAll),
                    child: Text(
                      context.l10n.cabinDesign_returnBadge,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
              ],
            ),
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(color: MedColors.border2, borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ),
      ),
    );
  }
}
