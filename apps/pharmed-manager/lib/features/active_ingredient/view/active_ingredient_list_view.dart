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
        if (vm.isFetching && vm.allItems.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (vm.hasNoSearchResults) {
          return CommonEmptyStates.searchNotFound();
        }

        if (vm.allItems.isEmpty) {
          return CommonEmptyStates.generic(
            icon: Icons.science_outlined,
            message: 'Henüz etken madde bulunmuyor',
            subMessage: widget.isDialog ? 'Yeni etken madde eklemek için "+" butonuna tıklayın' : 'Liste henüz boş',
          );
        }

        return ListView.builder(
          itemCount: vm.filteredItems.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final activeIngredient = vm.filteredItems[index];
            return EditableListItem(
              title: activeIngredient.title,
              subtitle: activeIngredient.subtitle,
              onEdit: () => _onEdit(context, initial: activeIngredient),
              onDelete: () => _onDelete(context, activeIngredient),
              onTap: widget.onItemSelected != null
                  ? () {
                      widget.onItemSelected?.call();
                    }
                  : null,
            );
          },
        );
      },
    );
  }

  Future<void> _onEdit(BuildContext context, {ActiveIngredient? initial}) async {
    final result = await showActiveIngredientFormDialog(context, initial: initial);
    if (result == true && context.mounted) {
      context.read<ActiveIngredientNotifier>().getActiveIngredients();
    }
  }

  void _onDelete(BuildContext context, ActiveIngredient item) {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      onConfirm: () => context.read<ActiveIngredientNotifier>().deleteActiveIngredient(
        item.id!,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      ),
    );
  }
}
