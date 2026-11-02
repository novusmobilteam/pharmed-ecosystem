part of 'drug_assignment_view.dart';

class _AssignmentIdlePanel extends StatelessWidget {
  const _AssignmentIdlePanel({
    required this.assignments,
    required this.groups,
    required this.onEdit,
    required this.menu,
    required this.onAssignmentSearchChanged,
    this.cabins = const [],
    this.cabinFilter,
    this.onCabinFilterChanged,
    this.cabinLabelOf,
  });

  final MenuItem menu;
  final List<MedicineAssignment> assignments;
  final List<DrawerGroup> groups;
  final ValueChanged<MedicineAssignment> onEdit;
  final Function(String? query) onAssignmentSearchChanged;

  /// İstasyon geneli: kabin filtresi ve "Kabin" sütunu.
  final List<Cabin> cabins;
  final int? cabinFilter;
  final ValueChanged<int?>? onCabinFilterChanged;
  final String? Function(MedicineAssignment assignment)? cabinLabelOf;

  @override
  Widget build(BuildContext context) {
    return CabinSelectionContentShell(
      menu: menu,
      extra: onCabinFilterChanged == null || cabins.length < 2
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: StationCabinFilterBar(
                cabins: cabins,
                selectedCabinId: cabinFilter,
                onChanged: onCabinFilterChanged!,
              ),
            ),
      searchQuery: '',
      showSearch: true,
      onSearchQueryChanged: (value) => onAssignmentSearchChanged(value),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (assignments.where((a) => a.medicine != null).isEmpty)
            SizedBox()
          else
            Expanded(
              child: SingleChildScrollView(
                child: _AssignmentTable(
                  assignments: assignments,
                  groups: groups,
                  onEdit: onEdit,
                  cabinLabelOf: cabinLabelOf,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssignmentTable extends StatelessWidget {
  const _AssignmentTable({required this.assignments, required this.groups, required this.onEdit, this.cabinLabelOf});

  final List<MedicineAssignment> assignments;
  final List<DrawerGroup> groups;
  final ValueChanged<MedicineAssignment> onEdit;
  final String? Function(MedicineAssignment assignment)? cabinLabelOf;

  @override
  Widget build(BuildContext context) {
    // Gelen sıra kabin sırasıdır — kabin içinde göz sırasına göre dizilir
    // (List.sort kararlı olmadığı için kabin sırası açıkça korunur).
    final filled = assignments.where((a) => a.medicine != null).toList();
    final cabinRank = <String?, int>{};
    for (final a in filled) {
      cabinRank.putIfAbsent(cabinLabelOf?.call(a), () => cabinRank.length);
    }
    final rows = filled
      ..sort((a, b) {
        final byCabin = cabinRank[cabinLabelOf?.call(a)]!.compareTo(cabinRank[cabinLabelOf?.call(b)]!);
        if (byCabin != 0) return byCabin;
        return (a.cabinDrawerId ?? 0).compareTo(b.cabinDrawerId ?? 0);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableHeaderRow(showCabin: cabinLabelOf != null),
        const Divider(height: 1, color: MedColors.border2),
        for (final assignment in rows)
          _TableDataRow(
            assignment: assignment,
            locationLabel: _locationLabel(assignment, groups, context),
            cabinLabel: cabinLabelOf == null ? null : (cabinLabelOf!(assignment) ?? '—'),
            onEdit: () => onEdit(assignment),
          ),
      ],
    );
  }

  String _locationLabel(MedicineAssignment assignment, List<DrawerGroup> groups, BuildContext context) {
    // Serum ataması cabinDrawrId'siz olabilir — önce avadanlık üzerinden bak.
    final serumLabel = _serumLocationLabel(assignment, groups, context);
    if (serumLabel != null) return serumLabel;

    for (final group in groups) {
      final index = group.units.indexWhere((u) => u.id == assignment.cabinDrawerId);
      if (index != -1) return context.l10n.assignment_idle_locationLabel(group.address, index + 1);
    }
    return '—';
  }

  /// Serum: raf + avadanlığın raftaki sırası (sağdan sola, A-n).
  String? _serumLocationLabel(MedicineAssignment assignment, List<DrawerGroup> groups, BuildContext context) {
    for (final group in groups.where((g) => g.isSerum)) {
      for (final shelf in group.serumShelves ?? const <SerumShelfLayout>[]) {
        final trayIndex = shelf.trays.indexWhere((t) => t.id != null && assignment.ownsCell(t.id!));
        if (trayIndex != -1) return context.l10n.assignment_idle_serumLocationLabel(shelf.orderNo, trayIndex + 1);
      }
    }
    return null;
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({this.showCabin = false});

  final bool showCabin;

  @override
  Widget build(BuildContext context) {
    final style = MedTextStyles.titleSm();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (showCabin) Expanded(flex: 3, child: Text(context.l10n.cabinAssignmentList_cabinColumn, style: style)),
          Expanded(flex: 3, child: Text(context.l10n.assignment_idle_columnLocation, style: style)),
          Expanded(flex: 4, child: Text(context.l10n.assignment_idle_columnDrug, style: style)),
          Expanded(flex: 2, child: Text(context.l10n.assignment_idle_columnMin, style: style)),
          Expanded(flex: 2, child: Text(context.l10n.assignment_idle_columnCritical, style: style)),
          Expanded(flex: 2, child: Text(context.l10n.assignment_idle_columnMax, style: style)),
          const SizedBox(width: 100),
        ],
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({required this.assignment, required this.locationLabel, required this.onEdit, this.cabinLabel});

  final MedicineAssignment assignment;
  final String locationLabel;
  final VoidCallback onEdit;

  /// null → kabin sütunu gösterilmez.
  final String? cabinLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (cabinLabel != null)
            Expanded(
              flex: 3,
              child: Text(
                cabinLabel!,
                style: MedTextStyles.bodySm(color: MedColors.text3),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            flex: 3,
            child: Text(locationLabel, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          Expanded(
            flex: 4,
            child: Text(
              assignment.medicine?.name ?? '—',
              style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(assignment.minQuantityLabel, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          Expanded(
            flex: 2,
            child: Text(assignment.critQuantityLabel, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          Expanded(
            flex: 2,
            child: Text(assignment.maxQuantityLabel, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          SizedBox(
            width: 100,
            child: TextButton(
              onPressed: onEdit,
              child: Text(
                context.l10n.assignment_idle_editLink,
                style: MedTextStyles.bodyMd(color: MedColors.blue, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
