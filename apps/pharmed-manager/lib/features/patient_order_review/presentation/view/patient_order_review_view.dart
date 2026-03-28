import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/patient_card.dart';
import '../../../../core/widgets/prescription_group_card.dart';
import '../notifier/patient_request_review_notifier.dart';

part 'prescriptions_view.dart';

class PatientOrderReviewView extends StatelessWidget {
  const PatientOrderReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatientOrderReviewNotifier(
        getHospitalizedAndRecentExitsUseCase: context.read(),
        getPatientPrescriptionHistoryUseCase: context.read(),
      )..getPatients(),
      builder: (context, child) => Consumer<PatientOrderReviewNotifier>(
        builder: (context, notifier, _) {
          return CustomDialog(
            title: 'Hasta İstem İncele',
            showSearch: true,
            onSearchChanged: (value) => notifier.search(value),
            child: _buildContent(context, notifier),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PatientOrderReviewNotifier notifier) {
    if (notifier.isFetchingPatients && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.isEmpty) {
      return CommonEmptyStates.noPatient();
    }

    return ListView.builder(
      itemCount: notifier.filteredItems.length,
      itemBuilder: (BuildContext context, int index) {
        final patient = notifier.filteredItems.elementAt(index);
        return PatientCard(
          patient: patient,
          onTap: () {
            notifier.getPrescriptions(
              patient.id ?? 0,
              onLoading: (msg) => showLoading(context, message: msg),
              onFailed: (msg) {
                hideLoading(context);
                MessageUtils.showErrorSnackbar(context, msg);
              },
              onSuccess: () {
                hideLoading(context);
                showPrescriptions(context);
              },
            );
          },
        );
      },
    );
  }
}
