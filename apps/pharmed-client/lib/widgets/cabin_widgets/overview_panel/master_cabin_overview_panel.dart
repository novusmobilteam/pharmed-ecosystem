// lib/shared/widgets/cabin_widgets/overview_panel/master_cabin_overview_panel.dart
//
// [SWREQ-UI-CAB-002]
// Master kabin işlemleri ekranının sol paneli.
// DrawerGroup listesini tıklanabilir çekmece kartları olarak gösterir.
//
// Sınıf: Class B

part of 'overview_panel.dart';

class MasterCabinOverviewPanel extends StatelessWidget {
  const MasterCabinOverviewPanel({
    super.key,
    required this.groups,
    required this.mode,
    required this.onDrawerTap,
    this.selectedSlotId,
  });

  final List<DrawerGroup> groups;
  final CabinOperationMode mode;
  final void Function(DrawerGroup group) onDrawerTap;
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
                for (int i = 0; i < groups.length; i++) ...[
                  _MasterDrawerItem(
                    group: groups[i],
                    mode: mode,
                    isSelected: groups[i].slot.id == selectedSlotId,
                    onTap: () => onDrawerTap(groups[i]),
                  ),
                  if (i < groups.length - 1) const SizedBox(height: 5),
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
// _MasterDrawerItem — DrawerGroup bazlı çekmece kartı
// ─────────────────────────────────────────────────────────────────

class _MasterDrawerItem extends StatelessWidget {
  const _MasterDrawerItem({required this.group, required this.mode, required this.isSelected, required this.onTap});

  final DrawerGroup group;
  final CabinOperationMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final workingStatus = _resolveWorkingStatus(group.units);
    final stockStatus = _resolveStockDot();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: group.isSerum ? 92 : 60,
        decoration: _drawerCardDecoration(isSelected, group.isSerum ? 92 : 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 4),
              child: Row(
                children: [
                  Text(_typeLabel(), style: _typeLabelStyle),
                  const Spacer(),
                  _StatusDot(workingStatus: workingStatus, stockStatus: stockStatus),
                ],
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

  String _typeLabel() {
    if (group.isSerum) return 'SERUM';
    if (group.isKubik) return 'KÜBİK';
    return 'B.DOZ';
  }

  CabinWorkingStatus _resolveWorkingStatus(List<DrawerUnit> units) {
    if (units.any((u) => u.workingStatus == CabinWorkingStatus.faulty)) {
      return CabinWorkingStatus.faulty;
    }
    if (units.any((u) => u.workingStatus == CabinWorkingStatus.maintenance)) {
      return CabinWorkingStatus.maintenance;
    }
    return CabinWorkingStatus.working;
  }

  _DrawerStockStatus _resolveStockDot() {
    // TODO: DrawerGroup'a stok özet bilgisi eklenince güncelle
    return _DrawerStockStatus.normal;
  }
}
