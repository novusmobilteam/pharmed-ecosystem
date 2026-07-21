import 'package:flutter/material.dart';
import '../../../../widgets/side_panel.dart';
import 'package:pharmed_manager/features/firm/view/firm_form_panel.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../notifier/firm_notifier.dart';
part 'table_view.dart';

class FirmScreen extends StatelessWidget {
  const FirmScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirmNotifier(getFirmsUseCase: context.read(), deleteFirmUseCase: context.read())..fetch(),
      child: Consumer<FirmNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              actions: [
                MedButton(
                  onPressed: () => notifier.openPanel(),
                  size: MedButtonSize.sm,
                  label: context.l10n.firm_createPanelTitle,
                ),
              ],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 480,
                panel: FirmFormPanel(),
                child: TableView(notifier: notifier),
              ),
            ),
          );
        },
      ),
    );
  }
}
