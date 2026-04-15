// lib/shared/widgets/cabin_widgets/overview_panel/mobile_cabin_overview_panel.dart
//
// [SWREQ-UI-CAB-007]
// Mobil kabin işlemleri ekranının sol paneli.
// MobileSlotVisual listesini tıklanabilir çekmece kartları olarak gösterir.
//
// Sınıf: Class B

part of 'overview_panel.dart';

class MobileCabinOverviewPanel extends StatelessWidget {
  const MobileCabinOverviewPanel({
    super.key,
    required this.slots,
    required this.mode,
    required this.onSlotTap,
    this.selectedSlotId,
  });

  final List<MobileSlotVisual> slots;
  final CabinOperationMode mode;
  final void Function(MobileSlotVisual slot) onSlotTap;
  final int? selectedSlotId;

  @override
  Widget build(BuildContext context) {
    return _CabinContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CabinPanelHeader(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < slots.length; i++) ...[
                  _MobileSlotItem(
                    slot: slots[i],
                    isSelected: slots[i].slotId == selectedSlotId,
                    onTap: () => onSlotTap(slots[i]),
                  ),
                  if (i < slots.length - 1) const SizedBox(height: 5),
                ],
              ],
            ),
          ),
          const _CabinPanelFooter(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MobileSlotItem — MobileSlotVisual bazlı çekmece kartı
// ─────────────────────────────────────────────────────────────────

class _MobileSlotItem extends StatelessWidget {
  const _MobileSlotItem({required this.slot, required this.isSelected, required this.onTap});

  final MobileSlotVisual slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 60,
        decoration: _drawerCardDecoration(isSelected, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 4),
              child: Row(
                children: [
                  Text('MOBİL', style: _typeLabelStyle),
                  const Spacer(),
                  Text('${slot.totalCells} göz', style: _subLabelStyle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
              child: _MobileRowPreview(slot: slot, isSelected: isSelected),
            ),
            const Spacer(),
            const _DrawerHandle(),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _MobileRowPreview — satır yapısını mini bar olarak gösterir
// ─────────────────────────────────────────────────────────────────

class _MobileRowPreview extends StatelessWidget {
  const _MobileRowPreview({required this.slot, required this.isSelected});

  final MobileSlotVisual slot;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 2,
      children: slot.rowColumns.take(6).map((cols) {
        return Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: isSelected ? MedColors.blue.withOpacity(0.4) : MedColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }
}
