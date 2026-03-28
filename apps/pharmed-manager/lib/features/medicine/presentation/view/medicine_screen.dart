import 'package:flutter/material.dart';

import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../domain/entity/medicine.dart';
import '../../../active_ingredient/presentation/view/active_ingredient_dialog.dart';
import '../../../drug_class/presentation/view/drug_class_dialog.dart';
import '../../../drug_type/presentation/view/drug_type_dialog.dart';
import '../../../kit/presentation/view/kit_list_dialog.dart';
import '../../../material_type/presentation/view/material_type_view.dart';
import 'drug_form_view.dart';
import 'medical_consumable_form_view.dart';
import '../notifier/medicine_table_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicineTableNotifier(
        getMedicinesUseCase: context.read(),
        deleteMedicineUseCase: context.read(),
      )..getMedicines(),
      child: _MedicineScreenBody(),
    );
  }
}

class _MedicineScreenBody extends StatefulWidget {
  const _MedicineScreenBody();

  @override
  State<_MedicineScreenBody> createState() => _MedicineScreenBodyState();
}

class _MedicineScreenBodyState extends State<_MedicineScreenBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MedicineTableNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const SizedBox(),
            tablet: const SizedBox(),
            desktop: DesktopLayout(
              title: 'İlaç/Tıbbi Sarf Tanımlama',
              showAddButton: true,
              onAddPressed: () => _onAdd(context, notifier),
              child: _buildChild(context, notifier),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildChild(BuildContext context, MedicineTableNotifier notifier) {
  return Column(
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
            TableActionItem.edit(
              onPressed: (data) => _onEdit(context, notifier, data),
            ),
            TableActionItem.delete(
              onPressed: (data) => _onDelete(context, notifier, data),
            ),
          ],
        ),
      ),
      _DefinitionButtonsView(notifier),
    ],
  );
}

Future<void> _onAdd(BuildContext context, MedicineTableNotifier notifier) async {
  final result = await showDrugFormView(context);

  if (result && context.mounted == true) {
    notifier.getMedicines();
  }
}

Future<void> _onEdit(BuildContext context, MedicineTableNotifier notifier, Medicine data) async {
  bool result = false;

  if (data is Drug) {
    result = await showDrugFormView(context, initial: data);
  } else {
    result = await showMedicalConsumableFormView(
      context,
      initial: data as MedicalConsumable,
    );
  }

  if (result && context.mounted == true) {
    notifier.getMedicines();
  }
}

Future<void> _onDelete(BuildContext context, MedicineTableNotifier notifier, Medicine data) async {
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

  final MedicineTableNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PharmedButton(
          label: 'Tıbbi Sarf Tanımlama',
          onPressed: () async {
            final result = await showMedicalConsumableFormView(context);
            if (result) {
              notifier.getMedicines();
            }
          },
        ),
        PharmedButton(
          label: 'Etken Madde Tanımlama',
          onPressed: () => showActiveIngredientDialog(context),
        ),
        PharmedButton(
          label: 'İlaç Sınıfı Tanımlama',
          onPressed: () => showDrugClassDialog(context),
        ),
        PharmedButton(
          label: 'İlaç Tipi Tanımlama',
          onPressed: () => showDrugTypeDialog(context),
        ),
        PharmedButton(
          label: 'İlaç Kiti Oluştur',
          onPressed: () => showKitDialog(context),
        ),
        PharmedButton(
          label: 'Malzeme Tipi Tanımlama',
          onPressed: () => showMaterialTypeDialog(context),
        ),
      ],
    );
  }
}
