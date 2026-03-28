part of 'my_patients_view.dart';

Future<bool> showAddPatientDialog(
  BuildContext context,
  int userId, {
  required List<Hospitalization> initiallySelected,
}) async {
  final result = await showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (context) => AddPatientNotifier(
        userId: userId,
        initiallySelected: initiallySelected,
        addPatientUseCase: context.read(),
        getHospitalizationsUseCase: context.read(),
      )..fetchHospitalizations(),
      child: AddPatientView(),
    ),
  );

  return result ?? false;
}

class AddPatientView extends StatelessWidget {
  const AddPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPatientNotifier>(
      builder: (context, notifier, child) {
        return RegistrationDialog(
          title: 'Hasta Ekle',
          saveButtonText: 'Tamam',
          isLoading: notifier.isLoading(notifier.submitOp),
          showSearch: true,
          onSearchChanged: notifier.search,
          onSave: () {
            notifier.submit(
              onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
              onSuccess: (msg) {
                MessageUtils.showSuccessSnackbar(context, msg);
                context.pop(true);
              },
            );
          },
          child: _buildContent(notifier),
        );
      },
    );
  }

  Widget _buildContent(AddPatientNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.isEmpty) {
      return Center(child: CommonEmptyStates.noPatient());
    }

    if (notifier.hasNoSearchResults) {
      return Center(child: CommonEmptyStates.searchNotFound());
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: notifier.filteredItems.length,
      itemBuilder: (BuildContext context, int index) {
        final hosp = notifier.filteredItems.elementAt(index);
        bool isSelected = notifier.selectedItemIds.contains(hosp.patient?.id);
        return SelectableListTile(
          item: hosp,
          onTap: notifier.selectPatient,
          isSelected: isSelected,
        );
      },
    );
  }
}
