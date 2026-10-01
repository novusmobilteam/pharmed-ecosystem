part of '../view/dashboard_screen.dart';

class DrugActivityPanel extends StatelessWidget {
  const DrugActivityPanel({super.key, required this.section, required this.maskPatientData});

  final DashboardSection<List<PrescriptionItemMovement>?> section;
  final bool maskPatientData;

  @override
  Widget build(BuildContext context) {
    final movements = section.data ?? const <PrescriptionItemMovement>[];

    return MedDashboardPanel(
      title: context.l10n.dashboard_drugActivityPanelTitle.toUpperCase(),
      section: section,
      itemCount: movements.length,
      itemBuilder: (BuildContext context, int index) {
        final movement = movements[index];
        return MedDrugActivityCard(movement: movement, maskPatient: maskPatientData);
      },
    );
  }
}
