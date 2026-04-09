import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
import 'package:pharmed_manager/features/firm/view/firm_form_panel.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';

import '../notifier/firm_notifier.dart';

class FirmScreen extends StatelessWidget {
  const FirmScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirmNotifier(getFirmsUseCase: context.read(), deleteFirmUseCase: context.read())..getFirms(),
      child: Consumer<FirmNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Firma Tanımlama',
              subtitle: menu.description,
              actions: [MedButton(onPressed: () => notifier.openPanel(), size: MedButtonSize.sm, label: 'Yeni Firma')],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 480,
                panel: FirmFormPanel(),
                child: UnifiedTableView<Firm>(
                  data: notifier.filteredItems,
                  isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
                  enableExcel: true,
                  enableSearch: true,
                  onSearchChanged: notifier.search,
                  actions: [
                    TableActionItem.edit(onPressed: (firm) => notifier.openPanel(firm: firm)),
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

void _onDelete(BuildContext context, FirmNotifier notifier, Firm item) {
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
