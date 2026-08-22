import 'package:flutter/material.dart';
import '../../../../widgets/side_panel.dart';

import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../notifier/warning_notifier.dart';
import 'warning_form_panel.dart';

class WarningScreen extends StatelessWidget {
  const WarningScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          WarningNotifier(getWarningsUseCase: context.read(), deleteWarningUseCase: context.read())..getWarnings(),
      child: Consumer<WarningNotifier>(
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
                  label: context.l10n.warning_formAddTitle,
                ),
              ],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 480,
                panel: WarningFormPanel(),
                child: MedTable<Warning>(
                  data: notifier.items,
                  isLoading: notifier.isLoading(notifier.deleteOp),
                  enableExcel: true,
                  enableSearch: true,
                  //onSearchChanged: notifier.search,
                  actions: [
                    TableActionItem.edit(
                      context: context,
                      onPressed: (warning) => notifier.openPanel(warning: warning),
                    ),
                    TableActionItem.delete(
                      context: context,
                      onPressed: (warning) => notifier.deleteWarning(
                        warning,
                        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                        onSuccess: (msg) =>
                            MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
                      ),
                    ),
                  ],
                  columnDefs: [],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
