import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import '../../../widgets/widgets.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/urgent_patient_notifier.dart';

part 'urgent_patient_panel.dart';
part 'urgent_patient_medicine_panel.dart';

class UrgentPatientScreen extends ConsumerWidget {
  const UrgentPatientScreen({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(urgentPatientNotifierProvider);

    if (notifier.isFetching) {
      return Center(child: MedLoadingIndicator());
    }

    return MedResponsiveLayout(
      mobile: MedMobileLayout(),
      tablet: MedTabletLayout(),
      desktop: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PatientSelectionPanel(
                      config: const PatientSelectionConfig(
                        showFilters: false,
                        enableTabs: false,
                        enableUrgentPatient: false,
                        enableOrderlessToggle: false,
                      ),
                      onPatientSelected: (patient, tab, mode) => notifier.selectPatient(patient),
                      selectedPatient: notifier.selectedPatient,
                      currentStation: stationContext.station!,
                    ),
                  ),
                  SizedBox(width: MedSpacing.md),
                  Expanded(
                    flex: 2,
                    child: UrgentPatientPanel(
                      urgentPatients: notifier.urgentPatients,
                      selected: notifier.selectedUrgentPatient,
                      isLoading: notifier.isFetching,
                      onSelected: notifier.selectUrgentPatient,
                    ),
                  ),
                  SizedBox(width: MedSpacing.md),
                  Expanded(
                    flex: 5,
                    child: Column(
                      spacing: 12.0,
                      children: [
                        Expanded(child: UrgentPatientDetailPanel(urgentPatient: notifier.selectedUrgentPatient)),
                        if (notifier.selectedUrgentPatient != null && notifier.selectedPatient != null)
                          UrgentPatientFooter(
                            urgentPatient: notifier.selectedUrgentPatient!,
                            targetPatient: notifier.selectedPatient!,
                            isSubmitting: notifier.isSubmitting,
                            onSubmit: () => notifier.submit(
                              onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                              onSuccess: () => MessageUtils.showSuccessSnackbar(
                                context,
                                context.l10n.common_operationSuccessMessage,
                              ),
                            ),
                            isDeleting: notifier.isDeleting,
                            onDelete: () => notifier.deleteUrgentPatient(
                              onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                              onSuccess: () => MessageUtils.showSuccessSnackbar(
                                context,
                                context.l10n.common_operationSuccessMessage,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
