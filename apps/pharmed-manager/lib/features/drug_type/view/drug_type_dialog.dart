import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/drug_type_notifier.dart';
import 'drug_type_form_dialog.dart';
import 'drug_type_list_view.dart';

Future<T?> showDrugTypeDialog<T>(BuildContext context, {bool forSelection = false}) async {
  return showDialog<T>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) =>
          DrugTypeNotifier(getDrugTypesUseCase: context.read(), deleteDrugTypeUseCase: context.read())..getDrugTypes(),
      child: Consumer<DrugTypeNotifier>(
        builder: (context, vm, _) => CustomDialog(
          title: forSelection ? 'İlaç Tipi Seç' : 'İlaç Tipi Tanımlama',
          showSearch: true,
          showAdd: !forSelection,
          onSearchChanged: vm.search,
          onAddPressed: () => _showFormDialog(context, vm),
          onClose: () => Navigator.of(context).pop(),
          child: DrugTypeListView(
            isDialog: true,
            onItemSelected: forSelection ? () => Navigator.of(context).pop() : null,
          ),
        ),
      ),
    ),
  );
}

Future<void> _showFormDialog(BuildContext context, DrugTypeNotifier vm) async {
  final result = await showDrugTypeFormDialog(context);
  if (result == true && context.mounted) {
    vm.getDrugTypes();
  }
}
