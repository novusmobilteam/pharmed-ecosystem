import 'package:flutter/material.dart' show showDialog, CircularProgressIndicator, Icons;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/material_type.dart';
import '../notifier/material_type_notifier.dart';
import 'material_type_form_dialog.dart';

Future<T?> showMaterialTypeDialog<T>(
  BuildContext context, {
  bool forSelection = false,
}) async {
  return showDialog<T>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => MaterialTypeNotifier(
        getMaterialTypesUseCase: context.read(),
        deleteMaterialTypeUseCase: context.read(),
      )..getMaterialTypes(),
      child: Consumer<MaterialTypeNotifier>(
        builder: (context, vm, _) => CustomDialog(
          title: forSelection ? 'Malzeme Tipi Seç' : 'Malzeme Tipi Tanımlama',
          showSearch: true,
          showAdd: !forSelection,
          isLoading: vm.isFetching,
          onSearchChanged: vm.search,
          onAddPressed: () => _showFormDialog(context, vm),
          onClose: () => context.pop(),
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
    vm.getMaterialTypes();
  }
}

class MaterialTypeListView extends StatefulWidget {
  final bool isDialog;
  final VoidCallback? onItemSelected;

  const MaterialTypeListView({
    super.key,
    this.isDialog = false,
    this.onItemSelected,
  });

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
          return CommonEmptyStates.generic(
            icon: Icons.category_outlined,
            message: 'Henüz malzeme tipi bulunmuyor',
            subMessage: widget.isDialog ? 'Yeni malzeme tipi eklemek için "+" butonuna tıklayın' : 'Liste henüz boş',
          );
        }

        return ListView.builder(
          itemCount: notifier.filteredItems.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final materialType = notifier.filteredItems[index];
            return EditableListItem(
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
      notifier.getMaterialTypes();
    }
  }

  void _onDelete(BuildContext context, MaterialTypeNotifier notifier, MaterialType item) {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      onConfirm: () => notifier.deleteMaterialType(item),
    );
  }
}
