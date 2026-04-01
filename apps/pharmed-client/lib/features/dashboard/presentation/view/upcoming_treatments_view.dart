part of 'dashboard_screen.dart';

class UpcomingTreatmentsView extends StatelessWidget {
  const UpcomingTreatmentsView({super.key, required this.treatments, required this.isStale, required this.notifier});

  final DashboardNotifier notifier;
  final List<PrescriptionItem> treatments;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final items = treatments.map((t) {
      final palette = AvatarPalette.values[(t.id ?? 0) % AvatarPalette.values.length];
      final initials = (t.patientName ?? 'Bilinmeyen Hasta')
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();

      return TreatmentItem(
        time: t.time?.formattedTime.toString() ?? '',
        patientName: t.patientName ?? 'Bilinmeyen Hasta',
        patientId: '',
        //patientId: t.patientIdLabel,
        avatar: MedAvatar(initials: initials, palette: palette),
        medicineName: t.medicine?.name ?? 'Bilinmeyen İlaç',
        dose: '',
        drawerCode: '',
        priority: TreatmentPriority.normal,
        status: TreatmentStatus.pending,
        //dose: t.medicine?,
        //drawerCode: t.drawerCode,
        //priority: _mapPriority(t.priority),
        //status: _mapStatus(t.status),
        onDetail: () {},
      );
    }).toList();

    return TreatmentList(
      items: items,
      isStale: isStale,
      onNewAssign: () async {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => MedConfirmationDialog(
            title: 'Yeni Tedavi Ata',
            description: 'Yeni tedavi atama ekranına geçilecek.',
            confirmLabel: 'Devam Et',
            cancelLabel: 'İptal',
            isDangerous: false,
            onConfirm: () {
              Navigator.of(context).pop();
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }

  TreatmentPriority _mapPriority(TreatmentPriorityDomain p) => switch (p) {
    TreatmentPriorityDomain.urgent => TreatmentPriority.urgent,
    TreatmentPriorityDomain.normal => TreatmentPriority.normal,
    TreatmentPriorityDomain.routine => TreatmentPriority.routine,
  };

  TreatmentStatus _mapStatus(TreatmentStatusDomain s) => switch (s) {
    TreatmentStatusDomain.pending => TreatmentStatus.pending,
    TreatmentStatusDomain.done => TreatmentStatus.done,
    TreatmentStatusDomain.returned => TreatmentStatus.returned,
  };
}

typedef TreatmentPriorityDomain = TreatmentPriority;
typedef TreatmentStatusDomain = TreatmentStatus;
