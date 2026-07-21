import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/drug_class_notifier.dart';
import 'drug_class_form_dialog.dart';

/// İlaç sınıfı listesi widget'ı.
class DrugClassListView extends StatefulWidget {
  final bool isDialog;
  final VoidCallback? onItemSelected;

  const DrugClassListView({super.key, this.isDialog = false, this.onItemSelected});

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
          return EmptyStateWidget(
            icon: Icons.category_outlined,
            variant: EmptyStateVariant.custom,
            title: context.l10n.drugClassListEmptyTitle,
            description: widget.isDialog
                ? context.l10n.common_addItemHint('ilaç sınıfı')
                : context.l10n.common_emptyListMessage,
          );
        }

        return ListView.builder(
          itemCount: notifier.items.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final drugClass = notifier.items[index];
            return MedEditableListCard(
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
      notifier.fetch();
    }
  }

  void _onDelete(BuildContext context, DrugClassNotifier notifier, DrugClass item) {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      onConfirm: () => notifier.deleteDrugClass(
        item.id!,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
      ),
    );
  }
}
