import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../kit_content/view/kit_content_list_dialog.dart';
import '../notifier/kit_notifier.dart';
import 'kit_form_dialog.dart';

class KitListView extends StatefulWidget {
  final bool isDialog;
  final VoidCallback? onItemSelected;

  const KitListView({super.key, this.isDialog = false, this.onItemSelected});

  @override
  State<KitListView> createState() => _KitListViewState();
}

class _KitListViewState extends State<KitListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<KitNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.isEmpty) {
          return CommonEmptyStates.generic(
            icon: Icons.medical_services_outlined,
            message: 'Henüz kit bulunmuyor',
            subMessage: widget.isDialog ? 'Yeni kit eklemek için "+" butonuna tıklayın' : 'Liste henüz boş',
          );
        }

        return ListView.builder(
          itemCount: notifier.filteredItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final kit = notifier.filteredItems[index];
            return EditableListItem(
              title: kit.name ?? '-',
              onEdit: () => _onEdit(context, notifier, initial: kit),
              onDelete: () => _onDelete(context, notifier, kit),
              onTap: widget.onItemSelected != null ? () => widget.onItemSelected?.call() : null,
              additionalActions: [
                AdditionalActionButton(
                  icon: PhosphorIcons.gear(),
                  onPressed: () => _onManageContent(context, kit),
                  tooltip: 'Kit İçeriğini Yönet',
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _onEdit(BuildContext context, KitNotifier notifier, {Kit? initial}) async {
    final result = await showKitFormDialog(context, initial: initial);
    if (result == true && context.mounted) {
      notifier.getKits();
    }
  }

  void _onDelete(BuildContext context, KitNotifier notifier, Kit item) {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      onConfirm: () => notifier.deleteKit(
        item,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      ),
    );
  }

  void _onManageContent(BuildContext context, Kit kit) {
    showDialog(
      context: context,
      builder: (_) => KitContentListDialog(kit: kit),
    );
  }
}
