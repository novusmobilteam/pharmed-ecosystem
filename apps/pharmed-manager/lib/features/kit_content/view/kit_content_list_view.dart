import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/kit_content_notifier.dart';
import 'kit_content_form_dialog.dart';

class KitContentListView extends StatefulWidget {
  final bool isDialog;
  final VoidCallback? onItemSelected;
  final Kit kit;

  const KitContentListView({super.key, this.isDialog = false, this.onItemSelected, required this.kit});

  @override
  State<KitContentListView> createState() => _KitContentListViewState();
}

class _KitContentListViewState extends State<KitContentListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<KitContentNotifier>();
      notifier.getKitContents(widget.kit.id ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KitContentNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.items.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.items.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.inventory_2_outlined,
            variant: EmptyStateVariant.custom,
            title: context.l10n.kitContent_listEmptyTitle,
            description: widget.isDialog
                ? context.l10n.common_addItemHint(context.l10n.kitContent_itemNameLabel)
                : context.l10n.common_emptyListMessage,
          );
        }

        return ListView.builder(
          itemCount: notifier.items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final kitContent = notifier.items.elementAt(index);
            return MedEditableListCard(
              title: kitContent.medicine?.title.toString() ?? "",
              subtitle: kitContent.medicine?.barcode,
              onEdit: () => _onEdit(context, notifier, initial: kitContent),
              onDelete: () => _onDelete(context, notifier, kitContent),
            );
          },
        );
      },
    );
  }

  Future<void> _onEdit(BuildContext context, KitContentNotifier notifier, {KitContent? initial}) async {
    final result = await showKitContentFormDialog(context, kitId: widget.kit.id!, initial: initial);

    if (result == true && context.mounted) {
      notifier.getKitContents(widget.kit.id ?? 0);
    }
  }

  void _onDelete(BuildContext context, KitContentNotifier notifier, KitContent item) {
    MessageUtils.showConfirmDeleteDialog(
      context: context,
      onConfirm: () => notifier.deleteKitContent(
        item.id!,
        widget.kit,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
      ),
    );
  }
}
