import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../../notifier/station_setup_notifier.dart';
import '../notifier/service_notifier.dart';

class ServiceTableView extends StatelessWidget {
  const ServiceTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceNotifier>(
      builder: (context, notifier, _) {
        return UnifiedTableView<HospitalService>(
          data: notifier.filteredItems,
          isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(
              onPressed: (service) => context.read<StationSetupNotifier>().openServicePanel(service: service),
            ),
            TableActionItem.delete(onPressed: (service) => _onDelete(context, notifier, service)),
          ],
        );
      },
    );
  }
}

void _onDelete(BuildContext context, ServiceNotifier notifier, HospitalService service) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      await notifier.deleteService(
        service,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      );
    },
  );
}
