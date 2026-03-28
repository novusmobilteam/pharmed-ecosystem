import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/drug_class.dart';
import '../notifier/drug_class_notifier.dart';
import 'drug_class_form_dialog.dart';

/// İlaç sınıfı listesi widget'ı.
class DrugClassListView extends StatefulWidget {
  final bool isDialog;
  final VoidCallback? onItemSelected;

  const DrugClassListView({
    super.key,
    this.isDialog = false,
    this.onItemSelected,
  });

  @override
  State<DrugClassListView> createState() => _DrugClassListViewState();
}

class _DrugClassListViewState extends State<DrugClassListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrugClassNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.isEmpty) {
          return CommonEmptyStates.generic(
            icon: Icons.category_outlined,
            message: 'Henüz ilaç sınıfı bulunmuyor',
            subMessage: widget.isDialog ? 'Yeni ilaç sınıfı eklemek için "+" butonuna tıklayın' : 'Liste henüz boş',
          );
        }

        return ListView.builder(
          itemCount: notifier.filteredItems.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final drugClass = notifier.filteredItems[index];
            return EditableListItem(
              title: drugClass.title,
              subtitle: drugClass.subtitle,
              onEdit: () => _onEdit(context, notifier, initial: drugClass),
              onDelete: () => _onDelete(context, notifier, drugClass),
              onTap: widget.onItemSelected != null ? () => widget.onItemSelected?.call() : null,
            );
          },
        );
      },
    );
  }

  Future<void> _onEdit(BuildContext context, DrugClassNotifier notifier, {DrugClass? initial}) async {
    final result = await showDrugClassFormDialog(context, initial: initial);
    if (result == true && context.mounted) {
      notifier.getDrugClasses();
    }
  }

  void _onDelete(BuildContext context, DrugClassNotifier notifier, DrugClass item) {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      onConfirm: () => notifier.deleteDrugClass(
        item.id!,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      ),
    );
  }
}
