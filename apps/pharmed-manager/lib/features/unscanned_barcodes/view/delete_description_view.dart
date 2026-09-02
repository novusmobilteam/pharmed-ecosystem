part of 'unscanned_barcodes_screen.dart';

void showDeleteDescriptionView(BuildContext context, PrescriptionItem data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UnscannedBarcodesNotifier>(),
      child: DeleteDescriptionView(item: data),
    ),
  );
}

class DeleteDescriptionView extends StatelessWidget {
  const DeleteDescriptionView({super.key, required this.item});

  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    return Consumer<UnscannedBarcodesNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: context.l10n.common_descriptionLabel,
          maxHeight: 300,
          width: 500,
          onSave: () {
            if (notifier.deleteDescription.isNotEmpty) {
              MessageUtils.showConfirmDeleteDialog(
                context: context,
                onConfirm: () async {
                  await notifier.deleteBarcode(
                    item,
                    onSuccess: () {
                      MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                      Navigator.pop(context);
                    },
                    onFailed: (msg) => MessageUtils.showErrorDialog(context, msg),
                  );
                },
              );
            }
          },
          saveButtonText: context.l10n.common_deleteTooltip,
          child: TextFormField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: context.l10n.common_descriptionLabel,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => notifier.deleteDescription = value,
          ),
        );
      },
    );
  }
}
