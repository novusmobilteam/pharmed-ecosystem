part of 'assignment_screen.dart';

class DrugAssignmentView extends StatelessWidget {
  const DrugAssignmentView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return MedResponsiveLayout(
      mobile: MedMobileLayout(),
      tablet: MedTabletLayout(),
      desktop: MedDesktopLayout(
        menu: menu,
        child: ChangeNotifierProvider(
          create: (context) => DrugAssignmentNotifier(
            getStationsUseCase: context.read(),
            getCabinsByStationUseCase: context.read(),
            getAssignmentsUseCase: context.read(),
            getCabinVisualizerDataUseCase: context.read(),
            deleteAssignmentUseCase: context.read(),
          )..init(),
          child: Consumer<DrugAssignmentNotifier>(
            builder: (context, notifier, _) {
              return Row(
                spacing: 12.0,
                children: [
                  Expanded(
                    flex: 6,
                    child: MedTable<MedicineAssignment>(
                      data: notifier.assignments,
                      isLoading: notifier.isFetching,
                      columnDefs: _buildColumnDefs(context, notifier.assignments),
                      categories: notifier.sideCategories,
                      selectedCategoryId: notifier.selectedCategoryId,
                      onCategoryChanged: (id) => notifier.selectCategory(id),
                      actions: [
                        TableActionItem<MedicineAssignment>(
                          icon: PhosphorIcons.pen(),
                          tooltip: context.l10n.common_editTooltip,
                          onPressed: (assignment) => _onEditAssignment(
                            context,
                            notifier,
                            unitId: assignment.cabinDrawerId!,
                            assignment: assignment,
                          ),
                        ),

                        TableActionItem<MedicineAssignment>(
                          icon: PhosphorIcons.trash(),
                          tooltip: context.l10n.common_deleteTooltip,
                          color: MedColors.red,
                          onPressed: (assignment) => MessageUtils.showConfirmDeleteDialog(
                            context: context,
                            onConfirm: () {
                              notifier.deleteAssignment(
                                assignment,
                                onSuccess: () {
                                  MessageUtils.showSuccessSnackbar(
                                    context,
                                    context.l10n.common_operationSuccessMessage,
                                  );
                                },
                                onFailed: (msg) => MessageUtils.showErrorDialog(context, msg),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CabinAssignmentMiniPanel(
                      groups: notifier.groups,
                      assignments: notifier.assignments,
                      selectedUnitId: notifier.selectedUnitId,
                      onCellTap: (unit, {required isEmpty}) => _onEditAssignment(context, notifier, unitId: unit.id!),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

void _onEditAssignment(
  BuildContext context,
  DrugAssignmentNotifier notifier, {
  required int unitId,
  MedicineAssignment? assignment,
}) {
  final unit = notifier.findUnit(unitId);
  if (unit == null) return;

  notifier.selectUnit(unitId);
  final existing = assignment ?? notifier.assignments.firstWhereOrNull((a) => a.cabinDrawerId == unitId);

  showDialog(
    context: context,
    builder: (_) => DrugAssignmentFormDialog(
      cabinId: notifier.selectedCabinId!,
      unit: unit,
      existingAssignment: existing,
      onSuccess: () => notifier.refreshAssignments(),
    ),
  );
}

List<TableColumnDef<MedicineAssignment>> _buildColumnDefs(BuildContext context, List<MedicineAssignment> assignments) {
  return [
    TableColumnDef(title: context.l10n.assignment_idle_columnDrug, displayValue: (item) => item.medicine?.name),
    TableColumnDef(
      title: context.l10n.assignment_idle_columnMin,
      displayValue: (item) => _quantityLabel(context, item.minQuantity, item),
    ),
    TableColumnDef(
      title: context.l10n.assignment_idle_columnCritical,
      displayValue: (item) => _quantityLabel(context, item.criticalQuantity, item),
    ),
    TableColumnDef(
      title: context.l10n.assignment_idle_columnMax,
      displayValue: (item) => _quantityLabel(context, item.maxQuantity, item),
    ),
  ];
}

String _quantityLabel(BuildContext context, num? quantity, MedicineAssignment assignment) {
  return assignment.quantityWithDoseLabel(context, quantity);
}
