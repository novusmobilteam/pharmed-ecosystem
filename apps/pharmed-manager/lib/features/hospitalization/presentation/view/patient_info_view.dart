part of 'hospitalization_form_view.dart';

class _PatientButton extends StatelessWidget {
  const _PatientButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalizationFormNotifier>(
      builder: (context, vm, _) {
        return RectangleIconButton(
          iconData: PhosphorIcons.user(),
          color: vm.hasPatient ? context.colorScheme.primary : context.colorScheme.onPrimary.withAlpha(120),
          iconColor: vm.hasPatient ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<HospitalizationFormNotifier>(),
                child: PatientInfoView(),
              ),
            );
          },
        );
      },
    );
  }
}

class PatientInfoView extends StatefulWidget {
  const PatientInfoView({super.key});

  @override
  State<PatientInfoView> createState() => _PatientInfoViewState();
}

class _PatientInfoViewState extends State<PatientInfoView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalizationFormNotifier>(
      builder: (context, vm, _) {
        final patient = vm.patient;
        return CustomDialog(
          title: 'Hasta Bilgileri',
          onClose: () => context.pop(vm.patient),
          showAdd: false,
          width: 500,
          child: _PatientInfo(patient),
        );
      },
    );
  }
}

class _PatientInfo extends StatelessWidget {
  const _PatientInfo(this.patient);

  final Patient? patient;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('Hasta Adı'),
          subtitle: Text(patient?.fullName ?? "-"),
        ),
        ListTile(
          title: Text('Hasta Kodu'),
          subtitle: Text(patient?.protocolNo ?? "-"),
        ),
        ListTile(
          title: Text('Protokol No'),
          subtitle: Text(patient?.protocolNo ?? "-"),
        ),
        ListTile(
          title: Text('Doğum Tarihi'),
          subtitle: Text(patient?.birthDate?.formattedDate ?? "-"),
        ),
        ListTile(
          title: Text('Cinsiyet'),
          subtitle: Text(patient?.gender?.label ?? "-"),
        ),
        ListTile(
          title: Text('Kilo'),
          subtitle: Text(patient?.weight?.toCustomString() ?? "-"),
        ),
        ListTile(
          title: Text('Telefon'),
          subtitle: Text(patient?.phone ?? "-"),
        ),
      ],
    );
  }
}
