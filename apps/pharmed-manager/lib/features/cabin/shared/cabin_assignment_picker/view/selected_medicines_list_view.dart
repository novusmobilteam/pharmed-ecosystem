part of 'cabin_assignment_picker_view.dart';

class SelectedMedicinesListView extends StatelessWidget {
  const SelectedMedicinesListView({super.key, required this.type});

  final CabinInventoryType type;

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinAssignmentPickerNotifier>(
      builder: (context, notifier, _) {
        final selected = notifier.selectedAssignments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: selected.isEmpty
                  ? Center(child: Text("Seçimleriniz burada görüntülenecektir.", style: context.textTheme.labelMedium))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: selected.length,
                      itemBuilder: (context, index) => _buildProcessCard(context, notifier, selected[index]),
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: context.colorScheme.onSurface.withAlpha(45),
                      ),
                    ),
            ),
            _buildHeader(context, notifier, selected.length),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CabinAssignmentPickerNotifier notifier, int count) {
    if (count > 0) {
      return ElevatedButton(
        onPressed: () => notifier.startSequentialProcess(),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(type.sequentialText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildProcessCard(BuildContext context, CabinAssignmentPickerNotifier notifier, CabinAssignment assignment) {
    final isCompleted = notifier.completedAssignmentIds.contains(assignment.id);
    final isCancelled = notifier.cancelledAssignmentIds.contains(assignment.id);
    final color = isCompleted
        ? Colors.green
        : isCancelled
            ? Colors.amber
            : context.colorScheme.onSurface;
    final iconData = isCompleted
        ? PhosphorIcons.checkCircle()
        : (isCancelled ? PhosphorIcons.warningCircle() : PhosphorIcons.arrowRight());
    final overrideQuantity = assignment.toDisplayQuantity(assignment.totalQuantity);

    return InkWell(
      onTap: isCompleted ? null : () => context.read<CabinStatusNotifier>().startOperation(assignment),
      child: Container(
        margin: EdgeInsets.only(bottom: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            spacing: 8.0,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      assignment.medicine?.name ?? '-',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(iconData, color: color),
                ],
              ),
              RatioProgressIndicator(
                assignment: assignment,
                overrideQuantity: overrideQuantity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
