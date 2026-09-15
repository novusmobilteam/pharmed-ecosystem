import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/empty_widgets/no_data_view.dart';
import 'package:pharmed_client/widgets/hospitalization_panel/hospitalization_panel.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';

import '../../dashboard/dashboard.dart';
import '../notifier/my_patients_notifier.dart';

class MyPatientsScreen extends ConsumerStatefulWidget {
  const MyPatientsScreen({super.key, this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  ConsumerState<MyPatientsScreen> createState() => MyPatientsScreenState();
}

class MyPatientsScreenState extends ConsumerState<MyPatientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(myPatientsNotifierProvider).init(widget.cabinRouteContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(myPatientsNotifierProvider);

    if (notifier.isError) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.networkError));
    }

    if (notifier.isInitiallyLoading) {
      return const Center(child: MedLoadingIndicator());
    }

    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: 4.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 4.0,
              children: [
                Container(
                  width: 4,
                  height: 25,
                  decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.mdAll),
                ),
                Text(widget.cabinRouteContext?.menu.name.toString() ?? '-', style: MedTextStyles.titleLg()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(context.l10n.myPatients_screenDescription, style: MedTextStyles.bodyMd()),
            ),
          ],
        ),
        Expanded(
          child: Row(
            spacing: 12.0,
            children: [
              Expanded(flex: 2, child: _AllPatientsPanel(notifier: notifier)),
              Expanded(flex: 7, child: _RightPanel(notifier: notifier)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AllPatientsPanel extends StatelessWidget {
  const _AllPatientsPanel({required this.notifier});

  final MyPatientsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final myIds = notifier.myPatientHospitalizationIds;
    return HospitalizationPanel(
      showTypeSelector: false,
      cellBuilder: (hosp) {
        final hospId = hosp.id;
        final isAlreadyMine = hospId != null && myIds.contains(hospId);
        final isPending = hospId != null && notifier.isPending(hospId);
        return Opacity(
          opacity: isAlreadyMine ? 0.4 : 1.0,
          child: PatientSelectionCard(
            hospitalization: hosp,
            onTap: () {},
            showChevron: false,
            trailing: isPending ? const Center(child: MedLoadingIndicator()) : null,
            onAdd: (!isAlreadyMine && !isPending) ? () => notifier.addPatient(hosp) : null,
          ),
        );
      },
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.notifier});

  final MyPatientsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final myPatients = notifier.myPatients;

    return Container(
      alignment: Alignment.center,
      decoration: MedDecoration.panelDecoration,
      child: Builder(
        builder: (BuildContext context) {
          if (myPatients.isEmpty) {
            return Center(
              child: NoDataView(
                title: context.l10n.myPatients_emptyTitle,
                subtitle: context.l10n.myPatients_emptyDescription,
                iconData: PhosphorIcons.plus(),
              ),
            );
          }

          return Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MedSpacing.insetXl,
                child: Text(context.l10n.myPatients_myPatientsPanelTitle, style: MedTextStyles.titleSm()),
              ),
              Divider(height: 0),

              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifier.myPatients.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final patient = notifier.myPatients.elementAt(index);
                    final hosp = patient.hospitalization;

                    if (hosp == null) return SizedBox();
                    return Padding(
                      padding: MedSpacing.insetXl,
                      child: Row(
                        spacing: 8.0,
                        children: [
                          MedAvatar(initials: hosp.patient?.initials ?? '', palette: AvatarPalette.blue, size: 44),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hosp.patient?.fullName ?? '-', style: MedTextStyles.titleSm()),
                              Text(hosp.patient?.tcNo ?? '-', style: MedTextStyles.monoMd()),
                            ],
                          ),
                          Spacer(),
                          MedChip(
                            label: hosp.inpatientService?.name ?? '',
                            background: MedColors.blueLight,
                            foreground: MedColors.blue,
                            showBorder: false,
                          ),
                          MedChip(
                            label: hosp.admissionDate?.formattedDate ?? '',
                            background: MedColors.amberLight,
                            foreground: MedColors.amber,
                            showBorder: false,
                          ),
                          SizedBox(width: 12.0),

                          MedRectangleIconButton(
                            iconData: notifier.isPending(hosp.id ?? 0)
                                ? PhosphorIcons.spinner()
                                : PhosphorIcons.minus(),
                            onPressed: () => notifier.removePatient(patient),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
