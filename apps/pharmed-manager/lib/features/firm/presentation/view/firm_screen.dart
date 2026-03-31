import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/firm_form_notifier.dart';
import '../notifier/firm_table_notifier.dart';
import 'firm_registration_dialog.dart';

class FirmScreen extends StatelessWidget {
  const FirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirmTableNotifier(getFirmsUseCase: context.read(), deleteFirmUseCase: context.read())..getFirms(),
      child: Consumer<FirmTableNotifier>(
        builder: (context, notifier, _) {
          return Scaffold(
            body: ResponsiveLayout(
              mobile: const MobileLayout(),
              tablet: const TabletLayout(),
              desktop: DesktopLayout(
                title: 'Firma Tanımlama',
                showAddButton: true,
                onAddPressed: () => _showFirmRegistrationDialog(context, notifier),
                child: UnifiedTableView<Firm>(
                  data: notifier.filteredItems,
                  isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
                  enableExcel: true,
                  enableSearch: true,
                  onSearchChanged: notifier.search,
                  actions: [
                    TableActionItem.edit(
                      onPressed: (firm) => _showFirmRegistrationDialog(context, notifier, initial: firm),
                    ),
                    TableActionItem.delete(onPressed: (firm) => _onDelete(context, notifier, firm)),
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

void _onDelete(BuildContext context, FirmTableNotifier notifier, Firm item) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      await notifier.deleteFirm(
        item,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      );
    },
  );
}

Future<void> _showFirmRegistrationDialog(BuildContext context, FirmTableNotifier notifier, {Firm? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) =>
          FirmFormNotifier(firm: initial, createFirmUseCase: context.read(), updateFirmUseCase: context.read()),
      child: const FirmRegistrationDialog(),
    ),
  );

  if (result == true && context.mounted) {
    notifier.getFirms();
  }
}
