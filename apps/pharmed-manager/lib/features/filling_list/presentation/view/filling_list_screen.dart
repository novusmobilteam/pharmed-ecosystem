import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../domain/entity/filling_list.dart';
import '../../../station/domain/entity/station.dart';
import '../../domain/entity/filling_object.dart';
import '../widgets/medicine_filling_card.dart';
import '../notifier/new_filling_list_notifier.dart';
import '../notifier/filling_list_screen_notifier.dart';

part 'new_filling_list_view.dart';

class FillingListScreen extends StatefulWidget {
  const FillingListScreen({super.key});

  @override
  State<FillingListScreen> createState() => _FillingListScreenState();
}

class _FillingListScreenState extends State<FillingListScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FillingListScreenNotifier(
        getStationsUseCase: context.read(),
        getFillingRecordsUseCase: context.read(),
        updateFillingRecordUseCase: context.read(),
        cancelFillingRecordUseCase: context.read(),
      )..getStations(),
      child: Consumer<FillingListScreenNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: 'Dolum Listesi',
              showAddButton: true,
              onAddPressed: () => _onAddPressed(context, notifier, station: notifier.selectedStation!),
              child: _TableView(notifier),
            ),
          );
        },
      ),
    );
  }
}

class _TableView extends StatelessWidget {
  const _TableView(this.notifier);

  final FillingListScreenNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<FillingList>(
      data: notifier.filteredItems,
      isLoading: notifier.isTableLoading,
      enableExcel: true,
      enableSearch: true,
      categories: notifier.tableCategories,
      onSearchChanged: notifier.search,
      categoryTitle: 'İstasyonlar',
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      selectedCategoryId: notifier.selectedStationId,
      cellBuilder: (item, colIndex, value) {
        if (colIndex == 3) {
          final text = value == true ? 'Evet' : 'Hayır';
          return Text(text);
        }
        return null;
      },
      actions: [
        TableActionItem.edit(
          onPressed: (data) =>
              _onAddPressed(context, notifier, fillingList: data, user: data.user, station: notifier.selectedStation!),
        ),
        TableActionItem(
          icon: PhosphorIcons.arrowClockwise(),
          tooltip: 'Durum Güncelle',
          onPressed: (record) => notifier.updateFillingListStatus(
            record,
            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
            onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
          ),
        ),
        TableActionItem(
          icon: PhosphorIcons.x(),
          tooltip: 'İptal',
          onPressed: (record) => notifier.cancelFillingList(
            record,
            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
            onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
          ),
        ),
      ],
    );
  }
}

Future<void> _onAddPressed(
  BuildContext context,
  FillingListScreenNotifier notifier, {
  FillingList? fillingList,
  User? user,
  required Station station,
}) async {
  final result = await showDialog(
    context: context,
    builder: (context) => NewFillingListView(station: station, user: user, fillingList: fillingList),
  );
  if (result == true && context.mounted) {
    notifier.getFillingLists();
  }
}
