import 'package:flutter/material.dart' show showDialog, CircularProgressIndicator, Icons;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/material_type_notifier.dart';
import 'material_type_form_dialog.dart';

Future<T?> showMaterialTypeDialog<T>(BuildContext context, {bool forSelection = false}) async {
  return showDialog<T>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) =>
          MaterialTypeNotifier(getMaterialTypesUseCase: context.read(), deleteMaterialTypeUseCase: context.read())
            ..fetch(),
      child: Consumer<MaterialTypeNotifier>(
        builder: (context, vm, _) => CustomDialog(
          title: forSelection ? context.l10n.materialTypeDialogSelectTitle : context.l10n.materialTypeDialogTitle,
          showSearch: true,
          showAdd: !forSelection,
          isLoading: vm.isFetching,
          onSearchChanged: vm.search,
          onAddPressed: () => _showFormDialog(context, vm),
          onClose: () => Navigator.of(context).pop(),
          child: MaterialTypeListView(
            isDialog: true,
            onItemSelected: forSelection ? () => Navigator.of(context).pop() : null,
          ),
        ),
      ),
    ),
  );
}

Future<void> _showFormDialog(BuildContext context, MaterialTypeNotifier vm) async {
  final result = await showMaterialTypeFormDialog(context);
  if (result == true && context.mounted) {
    vm.fetch();
  }
}

class MaterialTypeListView extends StatefulWidget {
  final bool isDialog;
  final VoidCallback? onItemSelected;

  const MaterialTypeListView({super.key, this.isDialog = false, this.onItemSelected});

  @override
  State<MaterialTypeListView> createState() => _MaterialTypeListViewState();
}

class _MaterialTypeListViewState extends State<MaterialTypeListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialTypeNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.category_outlined,
            variant: EmptyStateVariant.custom,
            title: context.l10n.materialTypeListEmptyTitle,
            description: widget.isDialog
                ? context.l10n.common_addItemHint('malzeme tipi')
                : context.l10n.common_emptyListMessage,
          );
        }

        return ListView.builder(
          itemCount: notifier.items.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final materialType = notifier.items[index];
            return MedEditableListCard(
              title: materialType.title,
              subtitle: materialType.subtitle,
              onEdit: () => _onEdit(context, notifier, initial: materialType),
              onDelete: () => _onDelete(context, notifier, materialType),
              onTap: widget.onItemSelected != null ? () => widget.onItemSelected?.call() : null,
            );
          },
        );
      },
    );
  }

  Future<void> _onEdit(BuildContext context, MaterialTypeNotifier notifier, {MaterialType? initial}) async {
    final result = await showMaterialTypeFormDialog(context, initial: initial);
    if (result == true && context.mounted) {
      notifier.fetch();
    }
  }

  void _onDelete(BuildContext context, MaterialTypeNotifier notifier, MaterialType item) {
    MessageUtils.showConfirmDeleteDialog(context: context, onConfirm: () => notifier.deleteMaterialType(item));
  }
}
