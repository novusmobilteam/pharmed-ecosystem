import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';

import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
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
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Uyarı Tanımlama',
              subtitle: menu.description,
              actions: [MedButton(onPressed: () => notifier.openPanel(), size: MedButtonSize.sm, label: 'Yeni Uyarı')],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 480,
                panel: WarningFormPanel(),
                child: UnifiedTableView<Warning>(
                  data: notifier.filteredItems,
                  isLoading: notifier.isLoading(notifier.deleteOp),
                  enableExcel: true,
                  enableSearch: true,
                  onSearchChanged: notifier.search,
                  actions: [
                    TableActionItem.edit(onPressed: (warning) => notifier.openPanel(warning: warning)),
                    TableActionItem.delete(
                      onPressed: (warning) => notifier.deleteWarning(
                        warning,
                        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
