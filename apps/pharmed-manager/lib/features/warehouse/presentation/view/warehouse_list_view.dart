import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../notifier/warehouse_table_notifier.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import 'warehouse_table_view.dart';

Future<Warehouse?> showWarehouseListView(BuildContext context) async {
  final Warehouse? result = await showDialog(context: context, builder: (context) => WarehouseListView());

  return result;
}

/// Kurulum Sihirbazı'nda depo seçimi için kullanılan widget
class WarehouseListView extends StatefulWidget {
  const WarehouseListView({super.key});

  @override
  State<WarehouseListView> createState() => _WarehouseListViewState();
}

class _WarehouseListViewState extends State<WarehouseListView> {
  Warehouse? _selected;

  void _selectWarehouse(Warehouse w) {
    setState(() {
      _selected = w;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          WarehouseTableNotifier(getWarehousesUseCase: context.read(), deleteWarehouseUseCase: context.read())
            ..getWarehouses(),
      child: Consumer<WarehouseTableNotifier>(
        builder: (context, notifier, _) => CustomDialog(
          title: 'Depo Tanımlama',
          height: 700,
          showSearch: false,
          showAdd: true,
          isLoading: notifier.isLoading(notifier.fetchOp),
          //onSearchChanged: notifier.search,
          onAddPressed: () => showWarehouseRegistrationDialog(context),
          onClose: () => context.pop(),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              _listView(notifier.allItems),
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

  Widget _listView(List<Warehouse> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final warehouse = items.elementAt(index);
        return SelectableListTile(
          item: items.elementAt(index),
          onTap: _selectWarehouse,
          onDoubleTap: (item, context) {
            _selectWarehouse(item);
            context.pop(item);
          },
          isSelected: _selected == warehouse,
        );
      },
    );
  }
}
