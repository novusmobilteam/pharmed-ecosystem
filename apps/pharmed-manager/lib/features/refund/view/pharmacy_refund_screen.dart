import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../notifier/pharmacy_refund_notifier.dart';

part 'table_view.dart';

class PharmacyRefundScreen extends StatelessWidget {
  const PharmacyRefundScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PharmacyRefundNotifier(
        getPharmacyRefundsUseCase: context.read(),
        completePharmacyRefundUseCase: context.read(),
        deletePharmacyRefundUseCase: context.read(),
        getStationsUseCase: context.read(),
        getCompletedPharmacyRefundsUseCase: context.read(),
      )..getStations(),
      child: Consumer<PharmacyRefundNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              isLoading: notifier.isLoading(notifier.completeOp),
              child: TableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}

void showDeleteDescriptionView(BuildContext context, Refund data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<PharmacyRefundNotifier>(),
      child: DeleteDescriptionView(refund: data),
    ),
  );
}

class DeleteDescriptionView extends StatelessWidget {
  const DeleteDescriptionView({super.key, required this.refund});

  final Refund refund;

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmacyRefundNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: 'Açıklama',
          maxHeight: 350,
          saveButtonText: 'Sil',
          onSave: () {
            MessageUtils.showConfirmDeleteDialog(
              context: context,
              onConfirm: () {
                notifier.deleteRefund(
                  refund,
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) {
                    MessageUtils.showSuccessSnackbar(context, msg);
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          },
          child: Column(
            children: [
              MedTextInputField(
                maxLines: 3,
                label: 'Silme nedeninizi açıklayınız',
                onChanged: (value) => notifier.description = value ?? '',
              ),
            ],
          ),
        );
      },
    );
  }
}
