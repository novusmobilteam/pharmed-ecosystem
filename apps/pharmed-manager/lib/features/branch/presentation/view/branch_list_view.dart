import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/core.dart';
import '../../domain/entity/branch.dart';
import '../notifier/branch_form_notifier.dart';
import '../notifier/branch_table_notifier.dart';
import 'branch_registration_dialog.dart';

Future<Branch?> showBranchListView(BuildContext context) async {
  final Branch? result = await showDialog(
    context: context,
    builder: (context) => BranchListView(),
  );

  return result;
}

class BranchListView extends StatefulWidget {
  const BranchListView({super.key});

  @override
  State<BranchListView> createState() => _BranchListViewState();
}

class _BranchListViewState extends State<BranchListView> {
  Branch? _selected;

  void _selectBranch(Branch b) {
    setState(() {
      _selected = b;
    });
  }

  // TODO : Servis Düzelince aramaya debounce eklenecek ve pagination mantığı burada da kısmen çalışacak..
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BranchTableNotifier(
        getBranchesUseCase: context.read(),
        deleteBranchUseCase: context.read(),
      )..getBranches(),
      child: Consumer<BranchTableNotifier>(
        builder: (context, vm, _) => CustomDialog(
          title: 'Branş Tanımlama',
          showSearch: false,
          showAdd: true,
          isLoading: vm.isFetching,
          //onSearchChanged: vm.search,
          onAddPressed: () => _showBranchRegistrationDialog(context),
          onClose: () => context.pop(),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              _listView(vm.items),
              RectangleIconButton(
                color: _selected != null ? context.colorScheme.primary : Colors.grey,
                iconColor: context.colorScheme.onPrimary,
                iconData: PhosphorIcons.arrowRight(),
                onPressed: () {
                  context.pop(_selected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listView(List<Branch> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final service = items.elementAt(index);
        return SelectableListTile(
          item: items.elementAt(index),
          onTap: _selectBranch,
          onDoubleTap: (item, context) {
            _selectBranch(item);
            context.pop(item);
          },
          isSelected: _selected == service,
        );
      },
    );
  }
}

Future<void> _showBranchRegistrationDialog(BuildContext context, {Branch? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => BranchFormNotifier(
        branch: initial,
        createBranchUseCase: context.read(),
        updateBranchUseCase: context.read(),
      ),
      child: BranchRegistrationDialog(),
    ),
  );

  if (result == true && context.mounted) {
    context.read<BranchTableNotifier>().getBranches();
  }
}
