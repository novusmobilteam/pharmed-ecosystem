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

class _MobileSlotItem extends StatelessWidget {
  const _MobileSlotItem({required this.slot, required this.isSelected, required this.onTap});

  final MobileSlotVisual slot;
  final bool isSelected;
  final VoidCallback onTap;

  // Fault durumuna göre renk
  bool get _hasFault => slot.workingStatus != null && slot.workingStatus != CabinWorkingStatus.working;

  Color get _faultColor => slot.workingStatus == CabinWorkingStatus.maintenance ? MedColors.amber : MedColors.red;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 60,
        decoration: _hasFault
            ? _drawerCardDecoration(isSelected, 60).copyWith(
                // fault varsa border rengi override
                border: Border.all(color: isSelected ? MedColors.blue : _faultColor, width: isSelected ? 2 : 1.5),
              )
            : _drawerCardDecoration(isSelected, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 4),
              child: Row(
                children: [
                  Text('MOBİL', style: _typeLabelStyle),
                  const Spacer(),
                  // Fault ikonu veya göz sayısı
                  if (_hasFault)
                    Icon(
                      slot.workingStatus == CabinWorkingStatus.maintenance
                          ? Icons.build_circle_outlined
                          : Icons.error_outline_rounded,
                      size: 12,
                      color: _faultColor,
                    )
                  else
                    Text('${slot.totalCells} göz', style: _subLabelStyle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
              child: _MobileRowPreview(
                slot: slot,
                isSelected: isSelected,
                faultColor: _hasFault ? _faultColor : null, // eklendi
              ),
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

class _MobileRowPreview extends StatelessWidget {
  const _MobileRowPreview({
    required this.slot,
    required this.isSelected,
    this.faultColor, // eklendi
  });

  final MobileSlotVisual slot;
  final bool isSelected;
  final Color? faultColor; // eklendi

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 2,
      children: slot.rowColumns.take(6).map((cols) {
        return Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: faultColor?.withOpacity(0.5) ?? (isSelected ? MedColors.blue.withOpacity(0.4) : MedColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }
}
