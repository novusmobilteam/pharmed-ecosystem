import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/empty_widgets/no_data_view.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../widgets/hospitalization_panel/hospitalization_panel.dart';
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
    final menu = stationContext.menu;
    final notifier = ref.watch(urgentPatientNotifierProvider);

    if (notifier.isError) {
      return Center(child: EmptyStateWidget(title: notifier.errorMessage));
    }
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(menu: menu),
        Expanded(
          child: Row(
            spacing: 12.0,
            children: [
              Expanded(flex: 2, child: _LeftPanel(notifier)),
              Expanded(
                flex: 2,
                child: UrgentPatientPanel(
                  urgentPatients: notifier.urgentPatients,
                  selected: notifier.selectedUrgentPatient,
                  isLoading: notifier.isFetching,
                  onSelected: notifier.selectUrgentPatient,
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  spacing: 12.0,
                  children: [Expanded(child: UrgentPatientDetailPanel(notifier: notifier))],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel(this.notifier);

  final UrgentPatientNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return HospitalizationPanel(
      cellBuilder: (hosp) {
        final hospId = hosp.id;
        bool isSelected = notifier.selectedHospitalization?.id == hospId;
        return PatientSelectionCard(
          hospitalization: hosp,
          onTap: () => notifier.selectHospitalization(hosp),
          showChevron: false,
          isSelected: isSelected,
        );
      },
      onTypeChanged: () => notifier.clearSelection(),
    );
  }
}
