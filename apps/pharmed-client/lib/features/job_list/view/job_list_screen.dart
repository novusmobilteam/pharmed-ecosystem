import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/empty_widgets/no_data_view.dart';
import '../../../widgets/empty_widgets/no_selected_hospitalization_view.dart';
import '../../../widgets/hospitalization_panel/hospitalization_panel.dart';
import '../../../widgets/widgets.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/job_list_notifier.dart';

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key, this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  ConsumerState<JobListScreen> createState() => JobListScreenState();
}

class JobListScreenState extends ConsumerState<JobListScreen> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(jobListNotifierProvider);

    if (notifier.isError) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.networkError));
    }

    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(menu: widget.cabinRouteContext!.menu),
        Expanded(
          child: Row(
            spacing: 12.0,
            children: [
              Expanded(flex: 2, child: _LeftPanel(notifier)),
              Expanded(flex: 7, child: _RightPanel(notifier)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel(this.notifier);

  final JobListNotifier notifier;

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

class _RightPanel extends StatelessWidget {
  const _RightPanel(this.notifier);

  final JobListNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final title = notifier.selectedHospitalization != null
        ? notifier.selectedHospitalization?.patient?.fullName ?? '-'
        : 'Hasta Seçilmedi';

    return Container(
      alignment: Alignment.center,
      decoration: MedDecoration.panelDecoration,
      child: Builder(
        builder: (context) {
          if (notifier.isLoading(notifier.fetchOp)) return Center(child: MedLoadingIndicator());
          if (notifier.selectedHospitalization == null) return Center(child: NoSelectedHospitalizationView());
          if (notifier.selectedHospitalization != null && notifier.items.isEmpty) {
            return Center(
              child: NoDataView(
                title: context.l10n.emptyState_noPrescriptionTitle,
                subtitle: context.l10n.emptyState_noPrescriptionDescription,
                iconData: PhosphorIcons.receiptX(),
              ),
            );
          }

          return Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MedSpacing.insetXl,
                child: Text(title, style: MedTextStyles.titleSm()),
              ),
              Divider(height: 0),

              Expanded(
                child: Padding(
                  padding: MedSpacing.insetMd,
                  child: RxCarousel(items: notifier.items),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
