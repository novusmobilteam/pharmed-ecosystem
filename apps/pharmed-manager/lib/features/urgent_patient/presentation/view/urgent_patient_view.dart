import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/urgent_patient_notifier.dart';
import '../widgets/urgent_patient_card.dart';

part 'patient_list_view.dart';

class UrgentPatientView extends StatelessWidget {
  const UrgentPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UrgentPatientNotifier(
        getPatientsUseCase: context.read(),
        emergencyPatientUseCase: context.read(),
        getUrgentPatientsUseCase: context.read(),
      )..getUrgentPatients(),
      child: Consumer<UrgentPatientNotifier>(
        builder: (context, notifier, _) {
          return CustomDialog(
            title: 'Acil Hasta Sonlandır',
            actions: [
              if (notifier.selectedUrgentPatient != null)
                TextButton(
                  onPressed: () => _showPatientListView(context),
                  child: Text('Eşleştir'),
                ),
            ],
            child: _buildChild(notifier),
          );
        },
      ),
    );
  }

  Widget _buildChild(UrgentPatientNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    if (notifier.isEmpty) {
      return Center(
        child: CommonEmptyStates.generic(
          icon: PhosphorIcons.usersFour(),
          message: 'İşlem yapılacak acil hasta bulunamadı.',
        ),
      );
    }

    return ListView.builder(
      itemCount: notifier.filteredItems.length,
      itemBuilder: (BuildContext context, int index) {
        final patientData = notifier.filteredItems.elementAt(index);
        return UrgentPatientCard(
          patientData: patientData,
          onTap: () => notifier.selectUrgentPatient(patientData),
          isSelected: notifier.selectedUrgentPatient == patientData,
          selectedItemIds: notifier.selectedItemIds,
          onItemToggled: (item) => notifier.selectItem(item, patientData),
        );
      },
    );
  }
}

void _showPatientListView(BuildContext context) {
  context.read<UrgentPatientNotifier>().getHospitalizations();

  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UrgentPatientNotifier>(),
      child: PatientListView(),
    ),
  );
}
