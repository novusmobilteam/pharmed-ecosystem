part of 'urgent_patient_screen.dart';

void showPatientListView(BuildContext context) {
  final notifier = context.read<UrgentPatientNotifier>();

  showDialog(
    context: context,
    builder: (_) =>
        ChangeNotifierProvider.value(value: context.read<UrgentPatientNotifier>(), child: PatientListView()),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier.getPatients();
  });
}

class PatientListView extends StatelessWidget {
  const PatientListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UrgentPatientNotifier>(
      builder: (context, notifier, child) {
        return RegistrationDialog(
          title: 'Acil Hasta Sonlandır',
          saveButtonText: 'Eşleştir',
          isLoading: notifier.isLoading(notifier.submitOp),
          onSave: () => notifier.submit(
            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
            onSuccess: (msg) {
              MessageUtils.showSuccessSnackbar(context, msg);
              Navigator.of(context).pop();
            },
          ),
          child: _buildDialogChild(),
        );
      },
    );
  }

  Widget _buildDialogChild() {
    return Consumer<UrgentPatientNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isLoading(notifier.fetchHospOp) && notifier.patients.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.patients.isEmpty) {
          return Center(child: CommonEmptyStates.noData());
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: notifier.patients.length,
          itemBuilder: (BuildContext context, int index) {
            final hosp = notifier.patients.elementAt(index);
            bool isSelected = hosp == notifier.selectedPatient;
            return SelectableListTile(item: hosp, onTap: notifier.selectPatient, isSelected: isSelected);
          },
        );
      },
    );
  }
}
