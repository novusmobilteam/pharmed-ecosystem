import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/active_ingredient_notifier.dart';
import 'active_ingredient_form_view.dart';

class ActiveIngredientListView extends StatefulWidget {
  final bool isDialog;
  final VoidCallback? onItemSelected;

  const ActiveIngredientListView({super.key, this.isDialog = false, this.onItemSelected});

  @override
  State<ActiveIngredientListView> createState() => _ActiveIngredientListViewState();
}

class _ActiveIngredientListViewState extends State<ActiveIngredientListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveIngredientNotifier>(
      builder: (context, vm, _) {
        if (vm.isFetching && vm.items.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (vm.items.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.science_outlined,
            variant: EmptyStateVariant.custom,
            title: context.l10n.activeIngredientListEmptyTitle,
            description: widget.isDialog
                ? context.l10n.common_addItemHint('etken madde')
                : context.l10n.common_emptyListMessage,
          );
        }

        return ListView.builder(
          itemCount: vm.items.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final activeIngredient = vm.items[index];
            return MedEditableListCard(
              title: activeIngredient.title,
              subtitle: activeIngredient.subtitle,
              onEdit: () => _onEdit(context, initial: activeIngredient),
              onDelete: () => _onDelete(context, activeIngredient),
              onTap: widget.onItemSelected != null
                  ? () {
                      widget.onItemSelected?.call();
                    }
                  : null,
              editTooltip: '',
            );
          },
        );
      },
    );
  }

  Future<void> _onEdit(BuildContext context, {ActiveIngredient? initial}) async {
    final result = await showActiveIngredientFormDialog(context, initial: initial);
    if (result == true && context.mounted) {
      context.read<ActiveIngredientNotifier>().fetch();
    }
  }

  void _onDelete(BuildContext context, ActiveIngredient item) {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      onConfirm: () => context.read<ActiveIngredientNotifier>().deleteActiveIngredient(
        item.id!,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
      ),
    );
  }
}
