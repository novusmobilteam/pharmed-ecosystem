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
          title: 'Açıklama',
          maxHeight: 350,
          onSave: () {
            if (notifier.deleteDescription.isNotEmpty) {
              MessageUtils.showConfirmDeleteDialog(
                context: context,
                onConfirm: () async {
                  await notifier.deleteBarcode(
                    item,
                    onSuccess: (msg) {
                      MessageUtils.showSuccessSnackbar(context, msg);
                      context.pop();
                    },
                    onFailed: (msg) => MessageUtils.showErrorDialog(context, msg),
                  );
                },
              );
            }
          },
          saveButtonText: 'Sil',
          child: Column(
            children: [
              TextInputField(
                maxLines: 3,
                label: 'Silme nedeninizi açıklayınız',
                onChanged: (value) => notifier.deleteDescription = value ?? '',
              ),
            ],
          ),
        );
      },
    );
  }
}
