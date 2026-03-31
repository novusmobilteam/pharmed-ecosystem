import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/service_form_notifier.dart';
import '../notifier/service_table_notifier.dart';
import 'service_registration_dialog.dart';

class ServiceTableView extends StatelessWidget {
  const ServiceTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceTableNotifier>(
      builder: (context, notifier, _) {
        return UnifiedTableView<HospitalService>(
          data: notifier.filteredItems,
          isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(onPressed: (service) => showServiceRegistrationDialog(context, service: service)),
            TableActionItem.delete(onPressed: (service) => _onDelete(context, notifier, service)),
          ],
        );
      },
    );
  }
}

void _onDelete(BuildContext context, ServiceTableNotifier notifier, HospitalService service) {
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

Future<void> showServiceRegistrationDialog(BuildContext context, {HospitalService? service}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => ServiceFormNotifier(
        service: service,
        createServiceUseCase: context.read(),
        updateServiceUseCase: context.read(),
      ),
      child: const ServiceRegistrationDialog(),
    ),
  );

  if (result == true && context.mounted) {
    context.read<ServiceTableNotifier>().getServices();
  }
}
