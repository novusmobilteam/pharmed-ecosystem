import 'package:flutter/material.dart';

import '../../../../core/widgets/side_panel.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../../active_ingredient/view/active_ingredient_dialog.dart';
import '../../../drug_class/view/drug_class_dialog.dart';
import '../../../drug_type/view/drug_type_dialog.dart';
import '../../../kit/view/kit_list_dialog.dart';
import '../../../material_type/view/material_type_view.dart';
import 'drug_form_panel.dart';
import 'medical_consumable_form_view.dart';
import '../notifier/medicine_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MedicineNotifier(getMedicinesUseCase: context.read(), deleteMedicineUseCase: context.read())..getMedicines(),
      child: Consumer<MedicineNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const SizedBox(),
            tablet: const SizedBox(),
            desktop: DesktopLayout(
              title: menu.name ?? 'İlaç/Tıbbi Sarf Tanımlama',
              subtitle: menu.description,
              actions: [PharmedButton(onPressed: () => notifier.openPanel(), label: 'Yeni İlaç')],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 1000,
                panel: DrugFormPanel(),
                child: Column(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: UnifiedTableView<Medicine>(
                        data: notifier.filteredItems,
                        isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
                        enableExcel: true,
                        enableSearch: true,
                        onSearchChanged: notifier.search,
                        actions: [
                          TableActionItem.edit(onPressed: (medicine) => notifier.openPanel(medicine: medicine)),
                          TableActionItem.delete(onPressed: (medicine) => _onDelete(context, notifier, medicine)),
                        ],
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
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
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
          label: 'Tıbbi Sarf Tanımlama',
          size: MedButtonSize.sm,
          onPressed: () async {
            final result = await showMedicalConsumableFormView(context);
            if (result) {
              notifier.getMedicines();
            }
          },
        ),
        MedButton(
          label: 'Etken Madde Tanımlama',
          size: MedButtonSize.sm,
          onPressed: () => showActiveIngredientDialog(context),
        ),
        MedButton(
          label: 'İlaç Sınıfı Tanımlama',
          size: MedButtonSize.sm,
          onPressed: () => showDrugClassDialog(context),
        ),
        MedButton(label: 'İlaç Tipi Tanımlama', size: MedButtonSize.sm, onPressed: () => showDrugTypeDialog(context)),
        MedButton(label: 'İlaç Kiti Oluştur', size: MedButtonSize.sm, onPressed: () => showKitDialog(context)),
        MedButton(
          label: 'Malzeme Tipi Tanımlama',
          size: MedButtonSize.sm,
          onPressed: () => showMaterialTypeDialog(context),
        ),
      ],
    );
  }
}
