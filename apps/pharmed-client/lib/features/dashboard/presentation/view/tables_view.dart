part of 'dashboard_screen.dart';

class TablesView extends StatelessWidget {
  const TablesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardNotifier>(
      builder: (context, notifier, child) {
        return Row(
          children: [
            Expanded(
              child: DashboardListView(
                title: context.l10n.dashboard_drugActivityPanelTitle.toUpperCase(),
                items: notifier.activities,
                cellBuilder: (item, index) => Text(item.createdAt.toString()),
                isLoading: notifier.isLoading(notifier.activitiesOp),
                onRefresh: () => notifier.fetchActivities(),
              ),
            ),
            VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: DashboardListView(
                      title: context.l10n.dashboard_upcomingTreatmentsPanelTitle.toUpperCase(),
                      items: notifier.treatments,
                      cellBuilder: (item, index) => Text(item.toString()),
                      isLoading: notifier.isLoading(notifier.treatmentsOp),
                      onRefresh: () => notifier.fetchActivities(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: DashboardListView(
                      title: context.l10n.dashboardUnappliedPrescriptionsPanelTitle.toUpperCase(),
                      items: notifier.unapplieds,
                      cellBuilder: (item, index) => Text(item.toString()),
                      isLoading: notifier.isLoading(notifier.unappliedOp),
                      onRefresh: () => notifier.fetchUnapplied(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class DashboardListView<T> extends StatelessWidget {
  const DashboardListView({
    super.key,
    required this.title,
    required this.items,
    required this.cellBuilder,
    required this.isLoading,
    required this.onRefresh,
  });

  final String title;
  final List<T> items;
  final Widget? Function(T item, int index) cellBuilder;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: MedTextStyles.titleSm()),
              Builder(
                builder: (context) {
                  if (isLoading) {
                    return MedLoadingIndicator(size: 18);
                  } else {
                    return GestureDetector(
                      child: Icon(PhosphorIcons.arrowCounterClockwise(), size: 18),
                      onTap: () => onRefresh(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        Divider(height: 1),
        Builder(
          builder: (context) {
            if (items.isEmpty) {
              return EmptyStateWidget(variant: EmptyStateVariant.noData);
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = items[index];
                    return cellBuilder(item, index);
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
