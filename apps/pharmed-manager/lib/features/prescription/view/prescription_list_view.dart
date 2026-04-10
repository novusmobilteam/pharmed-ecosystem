import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/prescription_group_card.dart';

import '../notifier/prescription_detail_notifier.dart';

// Hastaya ait reçetelerin liste olarak gösterildiği view.
// Listeden reçete seçildiğinde reçete detayını gösteren view açılıyor

class PrescriptionListView extends StatelessWidget {
  const PrescriptionListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionDetailNotifier>(
      builder: (context, vm, _) {
        return CustomDialog(
          title: 'Hastaya Ait Reçeteler',
          width: context.width * 0.9,
          maxHeight: context.height * 0.9,
          showSearch: true,
          onSearchChanged: vm.search,
          child: _buildContent(context, vm),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, PrescriptionDetailNotifier notifier) {
    if (notifier.isLoading(notifier.fetchOp) && notifier.groupedPrescriptions.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.groupedPrescriptions.isEmpty) {
      return CommonEmptyStates.generic(
        icon: PhosphorIcons.receipt(),
        message: 'Henüz reçete bulunmuyor',
        subMessage: 'Hastaya ait reçete bulunamadı.',
      );
    }

    final groupedPrescriptions = notifier.groupedPrescriptions;
    final prescriptionIds = groupedPrescriptions.keys.toList();

    return ListView.builder(
      itemCount: notifier.groupedPrescriptions.length,
      itemBuilder: (BuildContext context, int index) {
        final prescriptionId = prescriptionIds[index];
        final items = groupedPrescriptions[prescriptionId] ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: PrescriptionGroupCard(
            prescriptionId: prescriptionId,
            items: items,
            interactive: true,
            onApprove: (items) async {
              await _operation(context, prescriptionId, notifier, items, PrescriptionActionType.approve);
            },
            onCancel: (items) async {
              await _operation(context, prescriptionId, notifier, items, PrescriptionActionType.cancel);
            },
            onReject: (items) async {
              await _operation(context, prescriptionId, notifier, items, PrescriptionActionType.reject);
            },
          ),
        );
      },
    );
  }

  Future<void> _operation(
    BuildContext context,
    int prescriptionId,
    PrescriptionDetailNotifier notifier,
    List<PrescriptionItem> items,
    PrescriptionActionType type,
  ) async {
    return await notifier.submit(
      type,
      prescriptionId,
      items,
      onLoading: () => showLoading(context),
      onFailed: (message) {
        hideLoading(context);
        MessageUtils.showErrorSnackbar(context, message);
      },
      onSuccess: (message) {
        hideLoading(context);
        MessageUtils.showSuccessSnackbar(context, message);
        notifier.getPatientPrescriptionHistory();
      },
    );
  }
}
