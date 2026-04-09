import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/drug_class_notifier.dart';
import 'drug_class_form_dialog.dart';
import 'drug_class_list_view.dart';

Future<T?> showDrugClassDialog<T>(BuildContext context, {bool forSelection = false}) async {
  return showDialog<T>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) =>
          DrugClassNotifier(getDrugClassUseCase: context.read(), deleteDrugClassUseCase: context.read())
            ..getDrugClasses(),
      child: Consumer<DrugClassNotifier>(
        builder: (context, vm, _) => CustomDialog(
          title: forSelection ? 'İlaç Sınıfı Seç' : 'İlaç Sınıfı Tanımlama',
          showSearch: true,
          showAdd: !forSelection,
          onSearchChanged: vm.search,
          onAddPressed: () => _showFormDialog(context, vm),
          onClose: () => Navigator.of(context).pop(),
          child: DrugClassListView(
            isDialog: true,
            onItemSelected: forSelection ? () => Navigator.of(context).pop() : null,
          ),
        ),
      ),
    ),
  );
}

Future<void> _showFormDialog(BuildContext context, DrugClassNotifier vm) async {
  final result = await showDrugClassFormDialog(context);
  if (result == true && context.mounted) {
    vm.getDrugClasses();
  }
}
