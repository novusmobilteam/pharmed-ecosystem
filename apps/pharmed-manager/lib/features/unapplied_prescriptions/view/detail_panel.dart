part of 'unapplied_prescriptions_screen.dart';

/// Seçili yatışın uygulanmayı bekleyen kalemleri — reçete işlemleri detay
/// paneliyle aynı düzen: üstte hasta/yatış şeridi, altında GÜN bazlı kartlar
/// (salt okunur). Kalemler liste servisiyle birlikte geldiği için ayrı yükleme
/// yoktur.
class DetailPanel extends StatelessWidget {
  const DetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<UnappliedPrescriptionsNotifier>();
    final hosp = notifier.selectedHospitalization?.hospitalization;
    final days = notifier.dayGroups;

    return SidePanel(
      disableScroll: true,
      onClose: notifier.closePanel,
      title: hosp?.patient?.fullName ?? context.l10n.prescription_detailPanelPatientFallback,
      subtitle: context.l10n.unappliedPrescription_detailDialogTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hosp != null) PatientInfoStrip(hospitalization: hosp),
          Expanded(
            child: days.isEmpty
                ? Center(child: EmptyStateWidget(variant: EmptyStateVariant.noData))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: days.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final group = days[index];
                      return RxGroupCard.day(
                        key: ValueKey('day-${group.day}'),
                        day: group.day,
                        items: group.items,
                        permissions: PrescriptionActionPermissions.none(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
