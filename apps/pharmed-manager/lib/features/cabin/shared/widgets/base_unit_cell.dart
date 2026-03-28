part of 'cabin_editor/cabin_editor_view.dart';

class BaseUnitCell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final CabinWorkingStatus workingStatus;
  final bool isSelected;

  const BaseUnitCell({
    super.key,
    required this.child,
    this.onTap,
    this.workingStatus = CabinWorkingStatus.working,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        workingStatus == CabinWorkingStatus.working ? context.colorScheme.surface : Colors.grey.withAlpha(80);

    return Container(
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColor,
        border: Border.all(
          color: isSelected ? context.colorScheme.primary : context.theme.dividerColor,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: workingStatus == CabinWorkingStatus.working
          ? _standartCell()
          : Icon(
              PhosphorIcons.wrench(),
              color: context.colorScheme.secondary,
              size: 28,
            ),
    );
  }

  Widget _standartCell() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
