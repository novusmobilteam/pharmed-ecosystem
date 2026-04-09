import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/kit_content_notifier.dart';
import 'kit_content_form_dialog.dart';
import 'kit_content_list_view.dart';

/// Kit içerik listesi dialog.
class KitContentListDialog extends StatelessWidget {
  const KitContentListDialog({super.key, required this.kit});

  final Kit kit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          KitContentNotifier(getKitContentUseCase: context.read(), deleteKitContentUseCase: context.read()),
      child: Consumer<KitContentNotifier>(
        builder: (context, vm, _) => CustomDialog(
          title: 'Kit İçerik Tanımlama',
          showSearch: true,
          showAdd: true,
          onSearchChanged: vm.search,
          onAddPressed: () => _showFormDialog(context, vm),
          onClose: () => Navigator.of(context).pop(),
          child: KitContentListView(isDialog: true, kit: kit),
        ),
      ),
    );
  }
}

Future<void> _showFormDialog(BuildContext context, KitContentNotifier notifier) async {
  final result = await showKitContentFormDialog(context, kitId: notifier.kitId);

  if (result == true && context.mounted) {
    notifier.getKitContents(notifier.kitId ?? 0);
  }
}
