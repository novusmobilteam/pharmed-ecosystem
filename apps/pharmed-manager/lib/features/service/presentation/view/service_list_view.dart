import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'service_table_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/service_table_notifier.dart';

Future<HospitalService?> showServiceListView(BuildContext context) async {
  final HospitalService? result = await showDialog(context: context, builder: (context) => ServiceListView());

  return result;
}

/// Kurulum Sihirbazı'nda servis seçimi için kullanılan widget
class ServiceListView extends StatefulWidget {
  const ServiceListView({super.key});

  @override
  State<ServiceListView> createState() => _ServiceListViewState();
}

class _ServiceListViewState extends State<ServiceListView> {
  HospitalService? _selected;

  void _selectService(HospitalService s) {
    setState(() {
      _selected = s;
    });
  }

  // TODO : Servis Düzelince aramaya debounce eklenecek ve pagination mantığı burada da kısmen çalışacak..
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ServiceTableNotifier(getServicesUseCase: context.read(), deleteServiceUseCase: context.read())..getServices(),
      child: Consumer<ServiceTableNotifier>(
        builder: (context, notifier, _) => CustomDialog(
          title: 'Servis Tanımlama',
          showSearch: false,
          showAdd: true,
          isLoading: notifier.isLoading(notifier.fetchOp),
          //onSearchChanged: notifier.search,
          onAddPressed: () => showServiceRegistrationDialog(context),
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

  Widget _listView(List<HospitalService> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final service = items.elementAt(index);
        return SelectableListTile(
          item: items.elementAt(index),
          onTap: _selectService,
          onDoubleTap: (item, context) {
            _selectService(item);
            context.pop(item);
          },
          isSelected: _selected == service,
        );
      },
    );
  }
}
