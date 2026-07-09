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
              title: menu.name ?? context.l10n.medicine_screenTitleFallback,
              subtitle: menu.description,
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
                    Expanded(
                      child: MedTable<Medicine>(
                        data: notifier.items,
                        isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
                        enableExcel: true,
                        enableSearch: true,
                        onSearchChanged: notifier.search,
                        actions: [
                          TableActionItem.edit(
                            context: context,
                            onPressed: (medicine) => notifier.openPanel(medicine: medicine),
                          ),
                          TableActionItem.delete(
                            context: context,
                            onPressed: (medicine) => _onDelete(context, notifier, medicine),
                          ),
                        ],
                        enablePagination: true,
                        pageSize: notifier.pageSize,
                        currentPage: notifier.currentPage,
                        onPageChanged: (page) => notifier.setPage(page),
                      ),
                    ),
                    _DefinitionButtonsView(notifier),
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

class _DefinitionButtonsView extends StatelessWidget {
  const _DefinitionButtonsView(this.notifier);

  final MedicineNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MedButton(
          label: context.l10n.medicine_defineMedicalConsumableButton,
          size: MedButtonSize.sm,
          onPressed: () async {
            final result = await showMedicalConsumableFormView(context);
            if (result) {
              notifier.fetch();
            }
          },
        ),
        MedButton(
          label: context.l10n.medicine_defineActiveIngredientButton,
          size: MedButtonSize.sm,
          onPressed: () => showActiveIngredientDialog(context),
        ),
        MedButton(
          label: context.l10n.medicine_defineDrugClassButton,
          size: MedButtonSize.sm,
          onPressed: () => showDrugClassDialog(context),
        ),
        MedButton(
          label: context.l10n.medicine_defineDrugTypeButton,
          size: MedButtonSize.sm,
          onPressed: () => showDrugTypeDialog(context),
        ),
        MedButton(
          label: context.l10n.medicine_createKitButton,
          size: MedButtonSize.sm,
          onPressed: () => showKitDialog(context),
        ),
        MedButton(
          label: context.l10n.medicine_defineMaterialTypeButton,
          size: MedButtonSize.sm,
          onPressed: () => showMaterialTypeDialog(context),
        ),
      ],
    );
  }
}
