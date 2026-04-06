part of 'cabin_fault_view.dart';

class FaultCell extends StatelessWidget {
  final DrawerUnit unit;
  final Fault? fault;
  final VoidCallback onTap;

  const FaultCell({super.key, required this.unit, this.fault, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Arıza durumuna göre tema renklerini alalım
    final status = fault?.workingStatus ?? CabinWorkingStatus.working;
    final Color statusColor = status.color;
    final IconData statusIcon = _getStatusIcon(status);

    return BaseUnitCell(
      onTap: onTap,
      //workingStatus: unit.workingStatus,
      child: Container(
        decoration: BoxDecoration(
          color: statusColor.withAlpha(20),
          border: Border.all(color: statusColor.withAlpha(20), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Icon(statusIcon, color: statusColor, size: 32)),
      ),
    );
  }

  IconData _getStatusIcon(CabinWorkingStatus status) {
    switch (status) {
      case CabinWorkingStatus.working:
        return PhosphorIcons.checkCircle();
      case CabinWorkingStatus.faulty:
        return PhosphorIcons.warningCircle();
      case CabinWorkingStatus.maintenance:
        return PhosphorIcons.warning();
    }
  }
}
