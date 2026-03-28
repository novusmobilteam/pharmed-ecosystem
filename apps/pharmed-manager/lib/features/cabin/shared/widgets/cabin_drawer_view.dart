part of 'cabin_editor/cabin_editor_view.dart';

class CabinDrawerView<T> extends StatelessWidget {
  final DrawerGroup? group;
  final int cabinId;
  final CabinViewMode mode;

  final List<T>? cellData;

  // Hücreyi kim cagiriyorsa o cizecek
  final Widget Function(BuildContext context, DrawerUnit unit, T? data) cellBuilder;

  const CabinDrawerView({
    super.key,
    required this.group,
    required this.cabinId,
    required this.mode,
    required this.cellBuilder,
    this.cellData,
  });

  @override
  Widget build(BuildContext context) {
    if (group == null) return _EmptyState();

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: context.theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderView(group: group!),
          Divider(height: 1, color: context.theme.dividerColor),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _DrawerCompartments<T>(
              mode: mode,
              drawerGroup: group!,
              cellData: cellData,
              cellBuilder: cellBuilder,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderView extends StatelessWidget {
  final DrawerGroup group;

  const _HeaderView({required this.group});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              group.isSerum
                  ? PhosphorIcons.package()
                  : group.isKubik
                      ? PhosphorIcons.gridFour()
                      : PhosphorIcons.rows(),
              size: 20,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${group.compartmentCount} Göz • ${group.address}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerCompartments<T> extends StatelessWidget {
  final CabinViewMode mode;
  final DrawerGroup drawerGroup;
  final List<T>? cellData;
  final Widget Function(BuildContext context, DrawerUnit unit, T? data) cellBuilder;

  const _DrawerCompartments({
    required this.drawerGroup,
    required this.cellData,
    required this.mode,
    required this.cellBuilder,
  });

  T? _findDataForUnit(DrawerUnit unit) {
    if (cellData == null || cellData!.isEmpty) return null;

    return cellData!.firstWhereOrNull((element) {
      if (element == null) return false;
      final dynamic item = element;

      // JSON'daki 'cabinDrawrId' alanı bizim fiziksel 'unit.id' değerimizdir.
      // Eğer DrawerUnitAssignment içinde 'unit.id'yi 322 olarak kurduysan burası çalışır:
      return item.unit.id.toString() == unit.id.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (drawerGroup.isSerum) return const SizedBox.shrink(); // Serum için özel çizim gerekirse eklenebilir

    if (drawerGroup.isKubik) {
      return _buildKubicView(context);
    } else {
      return _buildStandartView(context);
    }
  }

  Widget _buildKubicView(BuildContext context) {
    int count = drawerGroup.units.length;
    int crossAxis = (count <= 16) ? 4 : 5;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 120,
        crossAxisCount: crossAxis,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: drawerGroup.units.length,
      itemBuilder: (ctx, i) {
        final unit = drawerGroup.units[i];
        final data = _findDataForUnit(unit);
        // Çizim işini delege ediyoruz
        return cellBuilder(context, unit, data);
      },
    );
  }

  Widget _buildStandartView(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        spacing: 8,
        children: drawerGroup.units.map((unit) {
          final data = _findDataForUnit(unit);
          return Expanded(
            child: cellBuilder(context, unit, data),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.handTap(),
              size: 48,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Lütfen Çekmece Seçiniz',
            style: TextStyle(
              fontSize: 20,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İşlem yapmak için sağdaki panelden\nbir çekmece seçin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
