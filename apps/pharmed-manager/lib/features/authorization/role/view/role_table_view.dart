import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/widgets/side_panel.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../authorization_notifier.dart';
import '../notifier/role_table_notifier.dart';

import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import 'role_drug_authentication_view.dart';
import '../notifier/role_drug_auth_notifier.dart';
import 'role_mc_authentication_view.dart';
import '../notifier/role_mc_auth_notifier.dart';
import '../notifier/role_menu_auth_notifier.dart';
import 'role_menu_authentication_view.dart';

part 'role_authorization_panel.dart';

class RoleTableView extends StatelessWidget {
  const RoleTableView({super.key, required this.onEdit});

  final Function(Role role) onEdit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<RoleTableNotifier>(),
      child: Consumer<RoleTableNotifier>(
        builder: (context, notifier, child) {
          return UnifiedTableView<Role>(
            data: notifier.items,
            isLoading: notifier.isFetching,
            enableSearch: true,
            enableExcel: true,
            enablePDF: true,
            enablePagination: true,
            pageSize: notifier.pageSize,
            currentPage: notifier.currentPage,
            serverTotalCount: notifier.totalCount,
            onSearchChanged: notifier.search,
            onPageChanged: (page) {
              notifier.setPage(page);
              notifier.getRoles();
            },
            actions: [TableActionItem(icon: PhosphorIcons.pen(), tooltip: 'Düzenle', onPressed: onEdit)],
          );
        },
      ),
    );
  }
}
