part of 'drug_assignment_view.dart';

class _AssignmentIdlePanel extends StatelessWidget {
  const _AssignmentIdlePanel({
    required this.assignments,
    required this.groups,
    required this.onEdit,
    required this.menu,
    required this.onAssignmentSearchChanged,
  });

  final MenuItem menu;
  final List<MedicineAssignment> assignments;
  final List<DrawerGroup> groups;
  final ValueChanged<int> onEdit;
  final Function(String? query) onAssignmentSearchChanged;

  @override
  Widget build(BuildContext context) {
    return CabinSelectionContentShell(
      menu: menu,
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
                child: _AssignmentTable(assignments: assignments, groups: groups, onEdit: onEdit),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssignmentTable extends StatelessWidget {
  const _AssignmentTable({required this.assignments, required this.groups, required this.onEdit});

  final List<MedicineAssignment> assignments;
  final List<DrawerGroup> groups;
  final ValueChanged<int> onEdit;

  @override
  Widget build(BuildContext context) {
    final rows = assignments.where((a) => a.medicine != null).toList()
      ..sort((a, b) => (a.cabinDrawerId ?? 0).compareTo(b.cabinDrawerId ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TableHeaderRow(),
        const Divider(height: 1, color: MedColors.border2),
        for (final assignment in rows)
          _TableDataRow(
            assignment: assignment,
            locationLabel: _locationLabel(assignment, groups, context),
            onEdit: () {
              final id = assignment.cabinDrawerId;
              if (id != null) onEdit(id);
            },
          ),
      ],
    );
  }

  String _locationLabel(MedicineAssignment assignment, List<DrawerGroup> groups, BuildContext context) {
    for (final group in groups) {
      final index = group.units.indexWhere((u) => u.id == assignment.cabinDrawerId);
      if (index != -1) return context.l10n.assignment_idle_locationLabel(group.address, index + 1);
    }
    return '—';
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = MedTextStyles.titleSm();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
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
  const _TableDataRow({required this.assignment, required this.locationLabel, required this.onEdit});

  final MedicineAssignment assignment;
  final String locationLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
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
            child: Text(
              '${assignment.minQuantityFromBackend.toInt()} ${assignment.operationUnit}',
              style: MedTextStyles.bodySm(color: MedColors.text3),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${assignment.critQuantityFromBackend.toInt()} ${assignment.operationUnit}',
              style: MedTextStyles.bodySm(color: MedColors.text3),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${assignment.maxQuantityFromBackend.toInt()} ${assignment.operationUnit}',
              style: MedTextStyles.bodySm(color: MedColors.text3),
            ),
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
