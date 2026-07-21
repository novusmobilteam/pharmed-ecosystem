import 'package:flutter/material.dart';

import '../../../../widgets/side_panel.dart';

import '../../active_ingredient/view/active_ingredient_dialog.dart';
import '../../drug_class/view/drug_class_dialog.dart';
import '../../drug_type/view/drug_type_dialog.dart';
import '../../kit/view/kit_list_dialog.dart';
import '../../material_type/view/material_type_view.dart';
import 'drug_form_panel.dart';
import 'medical_consumable_form_view.dart';
import '../notifier/medicine_notifier.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
part 'table_view.dart';
part 'footer.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MedicineNotifier(getMedicinesUseCase: context.read(), deleteMedicineUseCase: context.read())..fetch(),
      child: Consumer<MedicineNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const SizedBox(),
            tablet: const SizedBox(),
            desktop: MedDesktopLayout(
              menu: menu,
              actions: [
                MedButton(
                  onPressed: () => notifier.openPanel(),
                  size: MedButtonSize.sm,
                  label: context.l10n.medicine_newButtonLabel,
                ),
              ],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 1000,
                panel: DrugFormPanel(),
                child: Column(
                  spacing: 20,
                  children: [
                    Expanded(child: TableView(notifier: notifier)),
                    Footer(notifier),
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

Future<void> _onDelete(BuildContext context, MedicineNotifier notifier, Medicine data) async {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      await notifier.deleteMedicine(
        data,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (_) => MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
      );
    },
  );
}
