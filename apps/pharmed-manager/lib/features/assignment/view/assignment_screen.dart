import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../notifier/assignment_notifier.dart';
import '../notifier/bed_assignment_notifier.dart';

part 'bed_assignment_view.dart';
part 'drug_assignment_view.dart';

class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AssignmentNotifier(
        getStationUseCase: context.read(),
        getStationsUseCase: context.read(),
        getCabinVisualizerDataUseCase: context.read(),
      )..getStations(),
      builder: (context, child) => Consumer<AssignmentNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              title: menu.name ?? context.l10n.assignmentScreenTitle,
              subtitle: menu.description,
              isLoading:
                  notifier.isLoading(notifier.fetchVisualizerOp) ||
                  notifier.isLoading(notifier.fetchStationsOp) ||
                  notifier.isLoading(notifier.fetchStationOp),
              child: Column(
                spacing: 6.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 260,
                    child: MedDropdownInputField(
                      key: ValueKey(notifier.selectedStation),
                      options: notifier.stations,
                      onChanged: notifier.selectStation,
                      initialValue: notifier.selectedStation,
                      labelBuilder: (station) => station?.name,
                      placeholder: context.l10n.assignmentStationSelectPlaceholder,
                    ),
                  ),
                  if (notifier.cabin != null && notifier.cabinVisualizer != null) _buildView(notifier),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildView(AssignmentNotifier notifier) {
    if (notifier.cabin!.type == CabinType.mobile) {
      return Expanded(
        child: BedAssignmentView(
          key: ValueKey(notifier.cabin!.id),
          cabin: notifier.cabin!,
          data: notifier.cabinVisualizer!,
          station: notifier.selectedStation!,
        ),
      );
    } else {
      return DrugAssignmentView();
    }
  }
}
