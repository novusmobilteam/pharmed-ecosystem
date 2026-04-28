import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/menu_browser_view.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';

import '../../authorization_notifier.dart';
import '../notifier/user_authorization_notifier.dart';
import '../notifier/user_table_notifier.dart';

part 'user_authorization_panel.dart';

class UserTableView extends StatelessWidget {
  const UserTableView({super.key, required this.onEdit});

  final Function(User user) onEdit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<UserTableNotifier>(),
      child: Consumer<UserTableNotifier>(
        builder: (context, notifier, child) {
          return UnifiedTableView<User>(
            data: notifier.items,
            isLoading: notifier.isFetching,
            enableSearch: true,
            enableExcel: true,
            enablePDF: true,
            onSearchChanged: notifier.search,
            enablePagination: true,
            pageSize: notifier.pageSize,
            currentPage: notifier.currentPage,
            serverTotalCount: notifier.totalCount,

            onPageChanged: (page) {
              notifier.setPage(page);
              notifier.getUsers();
            },
            actions: [TableActionItem(icon: PhosphorIcons.pen(), tooltip: 'Düzenle', onPressed: onEdit)],
          );
        },
      ),
    );
  }
}
