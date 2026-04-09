part of 'unscanned_barcodes_screen.dart';

void showDeleteDescriptionView(BuildContext context, PrescriptionItem data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UnscannedBarcodesViewModel>(),
      child: DeleteDescriptionView(item: data),
    ),
  );
}

class DeleteDescriptionView extends StatefulWidget {
  const DeleteDescriptionView({super.key, required this.item});

  final PrescriptionItem item;

  @override
  State<DeleteDescriptionView> createState() => _DeleteDescriptionViewState();
}

class _DeleteDescriptionViewState extends State<DeleteDescriptionView> {
  UnscannedBarcodesViewModel? _viewModel;

  void _setupCallbacks(BuildContext context, UnscannedBarcodesViewModel vm) {
    vm.setCallbacks(
      key: UnscannedBarcodesViewModel.delete,
      onLoading: () => showLoading(context),
      onError: (message) {
        hideLoading(context);
        MessageUtils.showErrorDialog(context, message ?? 'Bir hata oluştu');
      },
      onSuccess: (message) {
        hideLoading(context);
        MessageUtils.showSuccessSnackbar(context, message);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UnscannedBarcodesViewModel>(
      builder: (context, vm, _) {
        if (_viewModel != vm) {
          _viewModel = vm;
          _setupCallbacks(context, vm);
        }

        return RegistrationDialog(
          title: 'Açıklama',
          maxHeight: 350,
          onSave: () {
            if (vm.deleteDescription.isNotEmpty) {
              MessageUtils.showConfirmDeleteDialog(
                context: context,
                onConfirm: () async {
                  await vm.deleteBarcode(widget.item);
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
                onChanged: (value) => vm.deleteDescription = value ?? '',
              ),
            ],
          ),
        );
      },
    );
  }
}
