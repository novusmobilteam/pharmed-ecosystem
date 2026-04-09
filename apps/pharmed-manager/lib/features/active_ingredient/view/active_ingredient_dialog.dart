import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/active_ingredient_notifier.dart';
import 'active_ingredient_form_view.dart';
import 'active_ingredient_list_view.dart';

Future<T?> showActiveIngredientDialog<T>(BuildContext context, {bool forSelection = false}) async {
  return showDialog<T>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => ActiveIngredientNotifier(
        getActiveIngredientsUseCase: context.read(),
        deleteActiveIngredientUseCase: context.read(),
      )..getActiveIngredients(),
      child: Consumer<ActiveIngredientNotifier>(
        builder: (context, vm, Widget? child) => CustomDialog(
          title: forSelection ? 'Etken Madde Seç' : 'Etken Madde Tanımlama',
          showSearch: true,
          showAdd: true,
          onSearchChanged: (query) => vm.search(query),
          onAddPressed: () => _showFormDialog(context),
          onClose: () => Navigator.of(context).pop(),
          child: ActiveIngredientListView(
            isDialog: true,
            onItemSelected: forSelection ? () => Navigator.of(context).pop() : null,
          ),
        ),
      ),
    ),
  );
}

Future<void> _showFormDialog(BuildContext context) async {
  final result = await showActiveIngredientFormDialog(context);
  if (result == true && context.mounted) {
    context.read<ActiveIngredientNotifier>().getActiveIngredients();
  }
}
