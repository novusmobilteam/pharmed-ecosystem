part of 'unapplied_prescriptions_screen.dart';

class DetailPanel extends StatelessWidget {
  const DetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SidePanel(
      disableScroll: true,
      onClose: () => context.read<UnappliedPrescriptionsNotifier>().closePanel(),
      title: context.l10n.unappliedPrescription_detailDialogTitle,
      child: Consumer<UnappliedPrescriptionsNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isFetchingDetail) {
            return Center(child: MedLoadingIndicator());
          }

          if (notifier.prescriptionItems.isEmpty) {
            return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noData));
          }

          final grouped = notifier.groupedPrescriptions;
          final prescriptionIds = grouped.keys.toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemCount: grouped.length,
              shrinkWrap: true,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final prescriptionId = prescriptionIds[index];
                final items = grouped[prescriptionId] ?? [];

                return RxGroupCard(
                  prescriptionId: prescriptionId,
                  items: items,
                  permissions: PrescriptionActionPermissions.none(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
