import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/drug_type_notifier.dart';
import 'drug_type_form_dialog.dart';

/// İlaç tipi listesi widget'ı.
class DrugTypeListView extends StatefulWidget {
  final bool isDialog;
  final VoidCallback? onItemSelected;

  const DrugTypeListView({super.key, this.isDialog = false, this.onItemSelected});

  @override
  State<DrugTypeListView> createState() => _DrugTypeListViewState();
}

class _DrugTypeListViewState extends State<DrugTypeListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrugTypeNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.isEmpty) {
          return CommonEmptyStates.generic(
            icon: Icons.inventory_2_outlined,
            message: 'Henüz ilaç tipi bulunmuyor',
            subMessage: widget.isDialog ? 'Yeni ilaç tipi eklemek için "+" butonuna tıklayın' : 'Liste henüz boş',
          );
        }

        return ListView.builder(
          itemCount: notifier.filteredItems.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final drugType = notifier.filteredItems[index];
            return EditableListItem(
              title: drugType.title,
              subtitle: drugType.subtitle,
              onEdit: () => _onEdit(context, notifier, initial: drugType),
              onDelete: () => _onDelete(context, notifier, drugType),
              onTap: widget.onItemSelected != null ? () => widget.onItemSelected?.call() : null,
            );
          },
        );
      },
    );
  }

  Future<void> _onEdit(BuildContext context, DrugTypeNotifier notifier, {DrugType? initial}) async {
    final result = await showDrugTypeFormDialog(context, initial: initial);
    if (result == true && context.mounted) {
      notifier.getDrugTypes();
    }
  }

  void _onDelete(BuildContext context, DrugTypeNotifier notifier, DrugType item) {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      onConfirm: () => notifier.deleteDrugType(
        item,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      ),
    );
  }
}
