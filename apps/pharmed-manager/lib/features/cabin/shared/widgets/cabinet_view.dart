part of 'cabin_editor/cabin_editor_view.dart';

class CabinetView extends StatelessWidget {
  final List<DrawerGroup> groups;
  final Function(DrawerGroup group) onDrawerTap;
  final DrawerGroup? selectedGroup;

  const CabinetView({
    super.key,
    required this.groups,
    required this.onDrawerTap,
    this.selectedGroup,
  });

  @override
  Widget build(BuildContext context) {
    const double cabinWidth = 300.0;
    const EdgeInsets outerPadding = EdgeInsets.all(16.0);
    const EdgeInsets insetPadding = EdgeInsets.all(12.0);
    Color backgroundColor = context.colorScheme.onSurfaceVariant.withAlpha(15);

    final BorderRadius outerRadius = BorderRadius.circular(8.0);
    final Color cabinColor = context.colorScheme.surface;

    return Center(
      child: Container(
        height: context.height,
        width: cabinWidth,
        padding: outerPadding,
        decoration: BoxDecoration(
          color: cabinColor,
          borderRadius: outerRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: context.theme.dividerColor),
        ),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CabinetHeadUnit(backgroundColor, outerRadius, insetPadding),
              Container(
                decoration: BoxDecoration(color: backgroundColor, borderRadius: outerRadius),
                padding: insetPadding,
                child: Column(
                  children: groups.map((group) {
                    final bool isSelected = selectedGroup?.address != null && selectedGroup!.address == group.address;
                    return _CabinetModuleRenderer(
                      group: group,
                      isSelected: isSelected,
                      onTap: () => onDrawerTap(group),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kabinin üst kısmındaki ekranlı bölüm
class _CabinetHeadUnit extends StatelessWidget {
  const _CabinetHeadUnit(this.backgroundColor, this.outerRadius, this.insetPadding);

  final Color backgroundColor;
  final BorderRadius outerRadius;
  final EdgeInsets insetPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: insetPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: outerRadius,
      ),
      child: Icon(
        PhosphorIcons.monitor(),
        size: 48,
        color: context.colorScheme.outlineVariant.withAlpha(100),
      ),
    );
  }
}

/// Her bir çekmece grubunu veya serum dolabını çizen widget
class _CabinetModuleRenderer extends StatelessWidget {
  final DrawerGroup group;
  final VoidCallback onTap;
  final bool isSelected;

  const _CabinetModuleRenderer({
    required this.group,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSerumCabinet = group.isSerum;

    // Kübik mi?
    final bool isKubic = group.isKubik;

    // Seçili durum için renk ve border ayarları
    final Color borderColor = isSelected ? context.colorScheme.primary : context.theme.dividerColor;
    final double borderWidth = isSelected ? 2.0 : 1.0;
    final Color backgroundColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: isSerumCabinet
              ? _buildSerumCabinetVisual(context, borderColor, borderWidth, backgroundColor)
              : _buildDrawerVisual(
                  isKubic: isKubic,
                  context: context,
                  borderColor: borderColor,
                  borderWidth: borderWidth,
                  backgroundColor: backgroundColor),
        ),
      ),
    );
  }

  // 1. Standart/Kübik Çekmece Görünümü (Yatay Şerit)
  Widget _buildDrawerVisual({
    required bool isKubic,
    required BuildContext context,
    required Color borderColor,
    required double borderWidth,
    required Color? backgroundColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child: Text(
          group.name,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? context.colorScheme.primary : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSerumCabinetVisual(
    BuildContext context,
    Color borderColor,
    double borderWidth,
    Color? backgroundColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 120,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          group.name,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? context.colorScheme.primary : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
