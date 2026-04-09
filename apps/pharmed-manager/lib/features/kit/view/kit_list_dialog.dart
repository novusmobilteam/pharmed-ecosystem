import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/core.dart';
import '../notifier/kit_notifier.dart';
import 'kit_form_dialog.dart';
import 'kit_list_view.dart';

// Dialog'u açmak için helper function
Future<T?> showKitDialog<T>(BuildContext context, {bool forSelection = false}) async {
  return showDialog<T>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => KitNotifier(getKitsUseCase: context.read(), deleteKitUseCase: context.read())..getKits(),
      child: Consumer<KitNotifier>(
        builder: (context, notifier, _) => CustomDialog(
          title: forSelection ? 'Kit Seç' : 'Kit Tanımlama',
          showSearch: true,
          showAdd: !forSelection,
          onSearchChanged: notifier.search,
          onAddPressed: () => _showFormDialog(context, notifier),
          onClose: () => Navigator.of(context).pop(),
          child: KitListView(isDialog: true, onItemSelected: forSelection ? () => Navigator.of(context).pop() : null),
        ),
      ),
    ),
  );
}

Future<void> _showFormDialog(BuildContext context, KitNotifier notifier) async {
  final result = await showKitFormDialog(context);
  if (result == true && context.mounted) {
    notifier.getKits();
  }
}
