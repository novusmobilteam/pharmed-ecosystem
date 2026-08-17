// lib/features/my_patients/view/my_patients_screen.dart
//
// [SWREQ-UI-MYPATIENTS-VIEW-001]
// Sınıf : Class A
//
// Sol : AllPatientsPanel  — kabindeki tüm hastalar, + butonu
// Sağ : MyPatientsPanel   — benim hastalarım, — butonu

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../settings/notifier/settings_notifier.dart';
import '../notifier/my_patients_notifier.dart';

class MyPatientsScreen extends StatelessWidget {
  const MyPatientsScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    final cabinId = context.watch<DashboardNotifier>().cabinVisualizerData?.cabinId;

    if (cabinId == null) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return ChangeNotifierProvider<MyPatientsNotifier>(
      create: (ctx) => MyPatientsNotifier(
        getBedAssignments: ctx.read(),
        getHospitalizations: ctx.read(),
        getMyPatients: ctx.read(),
        addPatient: ctx.read(),
        removePatients: ctx.read(),
        authNotifier: ctx.read(),
        getDeviceMode: ctx.read<SettingsNotifier>().getDeviceMode,
      )..init(cabinId),
      child: _MyPatientsBodyView(cabinId: cabinId, menu: menu),
    );
  }
}

class _MyPatientsBodyView extends StatefulWidget {
  const _MyPatientsBodyView({required this.cabinId, required this.menu});

  final int cabinId;
  final MenuItem menu;

  @override
  State<_MyPatientsBodyView> createState() => _MyPatientsBodyViewState();
}

class _MyPatientsBodyViewState extends State<_MyPatientsBodyView> {
  @override
  void didUpdateWidget(_MyPatientsBodyView old) {
    super.didUpdateWidget(old);
    if (widget.cabinId != old.cabinId) {
      context.read<MyPatientsNotifier>().init(widget.cabinId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MyPatientsNotifier>();

    if (notifier.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, notifier.errorMessage!);
        notifier.dismissError();
      });
    }

    if (notifier.isInitialLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return CabinOperationSelectionLayout(
      leftWidth: 440,
      left: _AllPatientsPanel(notifier: notifier),
      right: _MyPatientsPanel(notifier: notifier),
    );
  }
}

class _AllPatientsPanel extends StatelessWidget {
  const _AllPatientsPanel({required this.notifier});

  final MyPatientsNotifier notifier;

  List<Hospitalization> get _filtered {
    final q = notifier.search.toLowerCase();
    if (q.isEmpty) return notifier.allPatients;
    return notifier.allPatients.where((h) {
      final name = h.patient?.fullName.toLowerCase() ?? '';
      final room = h.bed?.room?.name?.toLowerCase() ?? h.room?.name?.toLowerCase() ?? '';
      return name.contains(q) || room.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final myIds = notifier.myPatientHospitalizationIds;
    final filtered = _filtered;

    return Container(
      padding: MedSpacing.panelInsetPadding,
      decoration: MedDecoration.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabinOperationSearchField(
            onChanged: notifier.onSearchChanged,
            hintText: context.l10n.patientPicker_searchHint,
          ),

          SizedBox(height: MedSpacing.sm),

          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                    itemBuilder: (context, index) {
                      final h = filtered[index];
                      final hospId = h.id;
                      final isAlreadyMine = hospId != null && myIds.contains(hospId);
                      final isPending = hospId != null && notifier.isPending(hospId);

                      return Center();

                      // return Opacity(
                      //   opacity: isAlreadyMine ? 0.4 : 1.0,
                      //   child: PatientSelectionCard(
                      //     hospitalization: h,
                      //     onTap: () {},
                      //     showChevron: false,
                      //     trailing: isPending ? const Center(child: MedLoadingIndicator()) : null,
                      //     onAdd: (!isAlreadyMine && !isPending) ? () => notifier.addPatient(h) : null,
                      //   ),
                      // );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MyPatientsPanel extends StatelessWidget {
  const _MyPatientsPanel({required this.notifier});

  final MyPatientsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final myPatients = notifier.myPatients;
    return CabinOperationGrid(
      maxColumns: 3,
      itemCount: myPatients.length,
      itemBuilder: (context, index) {
        final mp = myPatients[index];
        final h = mp.hospitalization;
        final hospId = h?.id;
        final isPending = hospId != null && notifier.isPending(hospId);

        return Center();

        // return PatientSelectionCard(
        //   hospitalization: h ?? Hospitalization(),
        //   onTap: () {},
        //   showChevron: false,
        //   trailing: isPending ? const Center(child: MedLoadingIndicator()) : null,
        //   onRemove: isPending ? null : () => notifier.removePatient(mp),
        // );
      },
    );
  }
}
