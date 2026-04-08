import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/station_setup/notifier/station_setup_notifier.dart';
import '../../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../../core/widgets/unified_table/unified_table_view.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';

import '../notifier/station_notifier.dart';

class StationTableView extends StatelessWidget {
  const StationTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StationNotifier>(
      builder: (context, notifier, _) {
        return UnifiedTableView<Station>(
          data: notifier.filteredItems,

          isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(
              onPressed: (station) => context.read<StationSetupNotifier>().openStationPanel(station: station),
            ),
            TableActionItem.delete(onPressed: (station) => _onDelete(context, notifier, station)),
          ],
        );
      },
    );
  }
}

void _onDelete(BuildContext context, StationNotifier notifier, Station station) {
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
