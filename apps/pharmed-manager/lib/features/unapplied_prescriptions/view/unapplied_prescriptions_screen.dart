import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/unapplied_prescriptions_notifier.dart';

part 'prescription_detail_view.dart';
part 'table_view.dart';

class UnappliedPrescriptionsScreen extends StatelessWidget {
  const UnappliedPrescriptionsScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnappliedPrescriptionsNotifier(
        getUnappliedPrescriptionsUseCase: context.read(),
        getUnappliedPrescriptionDetailUseCase: context.read(),
      )..fetch(),
      builder: (context, child) {
        return Consumer<UnappliedPrescriptionsNotifier>(
          builder: (context, notifier, child) {
            return MedResponsiveLayout(
              mobile: const MedMobileLayout(),
              tablet: const MedTabletLayout(),
              desktop: MedDesktopLayout(
                menu: menu,
                showAddButton: false,
                child: TableView(notifier: notifier),
              ),
            );
          },
        );
      },
    );
  }
}
