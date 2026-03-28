import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/patient.dart';
import '../../../hospitalization/presentation/view/hospitalization_form_view.dart';
import '../notifier/patient_form_notifier.dart';
import '../notifier/patient_selection_list_view_model.dart';
import 'patient_form_view.dart';

class PatientListView extends StatelessWidget {
  const PatientListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => PatientSelectionListViewModel(
        patientRepository: context.read(),
      )..getPatients(),
      child: Consumer<PatientSelectionListViewModel>(
        builder: (context, notifier, _) {
          return RegistrationDialog(
            title: 'Hasta Seçimi',
            showSearch: true,
            saveButtonText: 'Devam Et',
            isButtonActive: notifier.selectedPatient != null,
            onSave: () => _showHospitalizationDialog(context, notifier.selectedPatient!),
            actions: [
              IconButton(
                onPressed: () => _onNewPatient(context),
                icon: Icon(
                  PhosphorIcons.plus(),
                ),
              )
            ],
            onSearchChanged: notifier.search,
            child: _body(context, notifier),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, PatientSelectionListViewModel notifier) {
    if (notifier.getStatus.isLoading) {
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    if (notifier.patients.isEmpty) {
      return CommonEmptyStates.noData();
    }
    if (notifier.getStatus.isFailed) {
      return CommonEmptyStates.error();
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Positioned.fill(
          child: ListView.builder(
            itemCount: notifier.patients.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final patient = notifier.patients.elementAt(index);
              return EditableListItem(
                title: patient.title,
                subtitle: patient.subtitle,
                isSelected: notifier.selectedPatient == patient,
                onTap: () => notifier.selectedPatient = patient,
                onEdit: () => _onEditPatient(context, patient),
              );
            },
          ),
        ),
        // if (notifier.selectedPatient != null)
        //   Positioned(
        //     right: 16,
        //     bottom: 16,
        //     child: PharmedButton(
        //       onPressed: () => _showHospitalizationDialog(context, notifier.selectedPatient!),
        //       label: 'Devam Et',
        //     ),
        //   ),
      ],
    );
  }
}

Future<void> _onNewPatient(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (BuildContext context) => PatientFormNotifier(
        createPatientUseCase: context.read(),
        updatePatientUseCase: context.read(),
      ),
      child: PatientFormView(),
    ),
  );

  if ((result != null && result is Patient) && context.mounted) {
    context.read<PatientSelectionListViewModel>().selectedPatient = result;
    _showHospitalizationDialog(context, result);
  }
}

Future<void> _onEditPatient(BuildContext context, Patient patient) async {
  final result = await showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (BuildContext context) => PatientFormNotifier(
        initial: patient,
        createPatientUseCase: context.read(),
        updatePatientUseCase: context.read(),
      ),
      child: PatientFormView(patient: patient),
    ),
  );

  if ((result != null && result is Patient) && context.mounted) {
    context.read<PatientSelectionListViewModel>().selectedPatient = result;
    _showHospitalizationDialog(context, result);
  }
}

Future<void> _showHospitalizationDialog(BuildContext context, Patient patient) async {
  final result = await showHospitalizationFormView(context, patient: patient);

  if (result == true && context.mounted) {
    context.pop(true);
  }
}
