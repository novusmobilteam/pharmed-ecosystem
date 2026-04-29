import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/widgets/unified_table/unified_table_models.dart';
import 'package:pharmed_manager/core/widgets/unified_table/unified_table_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/urgent_patient_notifier.dart';

part 'patient_list_view.dart';

class UrgentPatientScreen extends StatelessWidget {
  const UrgentPatientScreen({super.key, required this.menu});

  final MenuItem menu;

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
          return ResponsiveLayout(
            mobile: MobileLayout(),
            tablet: TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Acil Hasta Sonlandır',
              subtitle: menu.description,
              child: _buildChild(context, notifier),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild(BuildContext context, UrgentPatientNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return Center(child: CircularProgressIndicator.adaptive());
    }

    return UnifiedTableView(
      data: notifier.filteredItems,
      actions: [
        TableActionItem(
          icon: PhosphorIcons.pen(),
          tooltip: 'Acil Hasta Sonlandır',
          onPressed: (_) => showPatientListView(context),
        ),
      ],
      emptyWidget: CommonEmptyStates.generic(
        icon: PhosphorIcons.usersFour(),
        message: 'İşlem yapılacak acil hasta bulunamadı.',
        subMessage: 'Acil hasta oluşturulduğu zaman burada görüntülenecektir.',
      ),
    );
  }
}
