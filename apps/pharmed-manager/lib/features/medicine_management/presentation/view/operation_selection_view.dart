part of 'medicine_management_view.dart';

class OperationSelectionView extends StatelessWidget {
  const OperationSelectionView({super.key, required this.hospitalization, required this.withdrawType});

  final WithdrawType withdrawType;
  final Hospitalization hospitalization;

  @override
  Widget build(BuildContext context) {
    final operations = [
      MenuItem(
        label: 'Alım',
        icon: PhosphorIcons.trayArrowDown(),
        builder: (context) => WithdrawView(
          hospitalization: hospitalization,
          withdrawType: withdrawType,
        ),
      ),
      MenuItem(
        label: 'İade',
        icon: PhosphorIcons.arrowArcLeft(),
        builder: (context) => MedicineRefundView(hospitalization: hospitalization),
      ),
      MenuItem(
        label: 'Fire/İmha',
        icon: PhosphorIcons.trash(),
        builder: (context) => DisposalView(hospitalization: hospitalization),
      ),
      MenuItem(
        label: 'Hasta İlacı Tanımlama',
        icon: PhosphorIcons.pill(),
        builder: (context) => PatientMedicineDefineView(hospitalization: hospitalization),
      ),
      MenuItem(
        label: 'Hasta İlaç Alım',
        icon: PhosphorIcons.bag(),
        builder: (context) => PatientMedicineWithdrawView(hospitalization: hospitalization),
      ),
      MenuItem(
        label: 'Serbest İlaç Alım',
        icon: PhosphorIcons.bag(),
        builder: (context) => WithdrawView(
          hospitalization: hospitalization,
          withdrawType: WithdrawType.free,
        ),
      ),
    ];

    return CustomDialog(
      title: 'Hasta İlaç İşlemleri',
      maxHeight: context.height * 0.6,
      width: context.width * 0.5,
      child: SubGridMenuView(items: operations),
    );
  }
}
