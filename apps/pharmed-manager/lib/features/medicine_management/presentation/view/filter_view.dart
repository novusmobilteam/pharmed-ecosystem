part of 'medicine_management_view.dart';

Future<void> showFilterView(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<MedicineManagementNotifier>(),
      child: FilterView(),
    ),
  );
}

class FilterView extends StatelessWidget {
  const FilterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Consumer<MedicineManagementNotifier>(
      builder: (context, vm, _) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340), // Biraz genişlettik
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  PatientFilterType.values.length,
                  (index) {
                    final filter = PatientFilterType.values.elementAt(index);
                    final isSelected = filter == vm.filter;
                    final effectiveColor = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface;

                    final effectiveIconColor =
                        isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

                    return InkWell(
                      onTap: () {
                        vm.changeFilter(filter);
                        context.pop();
                      },
                      hoverColor: theme.colorScheme.surfaceContainerHighest,
                      child: Container(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                                isSelected
                                    ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                                    : PhosphorIcons.circle(),
                                size: 20,
                                color: effectiveIconColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                filter.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: effectiveColor,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
