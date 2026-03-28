import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/station_form_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/station.dart';
import '../notifier/station_table_notifier.dart';
import 'station_registration_dialog.dart';

class StationTableView extends StatelessWidget {
  const StationTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StationTableNotifier>(
      builder: (context, notifier, _) {
        return UnifiedTableView<Station>(
          data: notifier.filteredItems,
          isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(
              onPressed: (station) => showStationRegistrationDialog(context, station: station),
            ),
            TableActionItem.delete(
              onPressed: (station) => _onDelete(context, notifier, station),
            )
          ],
        );
      },
    );
  }
}

void _onDelete(BuildContext context, StationTableNotifier notifier, Station station) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      await notifier.deleteStation(
        station,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      );
    },
  );
}

Future<void> showStationRegistrationDialog(BuildContext context, {Station? station}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => StationFormNotifier(
        station: station,
        createStationUseCase: context.read(),
        updateStationUseCase: context.read(),
        getStationUseCase: context.read(),
      )..initialize(station: station),
      child: StationRegistrationDialog(),
    ),
  );

  if (result == true && context.mounted) {
    context.read<StationTableNotifier>().getStations();
  }
}
