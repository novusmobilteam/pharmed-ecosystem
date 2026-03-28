import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../domain/entity/warning.dart';
import '../notifier/warning_notifier.dart';
import 'warning_form_view.dart';

/// Uyarı tanımlama ekranı.
class WarningScreen extends StatelessWidget {
  const WarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WarningNotifier(
        getWarningsUseCase: context.read(),
        deleteWarningUseCase: context.read(),
      )..getWarnings(),
      child: Consumer<WarningNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: 'Uyarı Tanımlama',
              showAddButton: true,
              onAddPressed: () => _onEdit(context, notifier),
              child: UnifiedTableView<Warning>(
                data: notifier.filteredItems,
                isLoading: notifier.isLoading(notifier.deleteOp),
                enableExcel: true,
                enableSearch: true,
                onSearchChanged: notifier.search,
                actions: [
                  TableActionItem.edit(
                    onPressed: (warning) => _onEdit(context, notifier, initial: warning),
                  ),
                  TableActionItem.delete(
                    onPressed: (warning) => notifier.deleteWarning(
                      warning,
                      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                      onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _onEdit(BuildContext context, WarningNotifier notifier, {Warning? initial}) async {
  final result = await showWarningFormDialog(context, initial: initial);

  if (result == true && context.mounted) {
    notifier.getWarnings();
  }
}
